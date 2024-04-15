defmodule MishkaDeveloperTools.Helper.Extra do
  @alphabet Enum.concat([?0..?9, ?A..?Z, ?a..?z])
  @username_start ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "_"]
  @username_alphabet Enum.concat([?0..?9, ?A..?Z, ?a..?z, ~c"_"])

  # Do not use for security and sensitive cases
  @spec randstring(integer) :: binary
  def randstring(count) do
    :rand.seed(:exsplus, :os.timestamp())

    Stream.repeatedly(&random_char_from_alphabet/0)
    |> Enum.take(count)
    |> List.to_string()
    |> String.upcase()
  end

  defp random_char_from_alphabet() do
    Enum.random(@alphabet)
  end

  def app_started?(name) do
    Application.started_applications()
    |> Enum.map(fn {app, _, _} -> app end)
    |> Enum.member?(name)
  end

  # based on: https://www.erlang.org/doc/apps/erts/match_spec
  def erlang_guard(:or), do: :orelse
  def erlang_guard(:and), do: :andalso
  def erlang_guard(:xor), do: :xor
  def erlang_guard(:<=), do: :"=<"
  def erlang_guard(:!=), do: :"/="
  def erlang_guard(:===), do: :"=:="
  def erlang_guard(:!==), do: :"=/="
  def erlang_guard(term), do: term

  def erlang_result(:all), do: [:"$_"]
  def erlang_result(:selected), do: [:"$$"]
  def erlang_result(term), do: term

  def timestamp() do
    DateTime.utc_now()
    |> DateTime.truncate(:microsecond)
  end

  def validated_user?(username) when is_binary(username) do
    username_regex = ~r/^[a-zA-Z][a-zA-Z0-9_]{4,34}$/
    username_length = String.length(username)
    start_status = String.starts_with?(username, @username_start)
    characters? = check_specific_characters?(username, @username_alphabet)

    if username_length > 4 and username_length < 35 and List.ascii_printable?(~c"#{username}") and
         !start_status and characters? do
      username
      |> String.trim()
      |> then(&Regex.match?(username_regex, &1))
    else
      false
    end
  end

  def validated_user?(_username), do: false

  defp check_specific_characters?(input, allowed_chars) do
    input
    |> String.to_charlist()
    |> Enum.all?(&(&1 in allowed_chars))
  end

  def get_unix_time() do
    DateTime.utc_now() |> DateTime.to_unix()
  end

  def get_unix_time_with_shift(number, type \\ :second)
      when type in [:day, :hour, :minute, :second] do
    DateTime.utc_now()
    |> DateTime.add(number, type)
    |> DateTime.to_unix()
  end
end
