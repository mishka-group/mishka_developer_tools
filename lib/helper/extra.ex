defmodule Helper.Extra do
  @alphabet Enum.concat([?0..?9, ?A..?Z, ?a..?z])

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
end
