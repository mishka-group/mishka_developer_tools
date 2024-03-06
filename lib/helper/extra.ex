defmodule MishkaDeveloperTools.Helper.Extra do
  @alphabet Enum.concat([?0..?9, ?A..?Z, ?a..?z])

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

  def elixir_to_erlang_guard(:or), do: :orelse
  def elixir_to_erlang_guard(:and), do: :andalso
  def elixir_to_erlang_guard(:<=), do: :"=<"
  def elixir_to_erlang_guard(:!=), do: :"/="
  def elixir_to_erlang_guard(:===), do: :"=:="
  def elixir_to_erlang_guard(:!==), do: :"=/="
  def elixir_to_erlang_guard(term), do: term
end
