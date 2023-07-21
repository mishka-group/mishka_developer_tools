defmodule MishkaDeveloperTools.Helper.Derive do
  alias MishkaDeveloperTools.Helper.Derive.{Parser, SanitizerDeriver, ValidationDeriver}

  def derive({:error, _, _} = error, _derive_input), do: error

  def derive({:ok, data} = okey, derive_input) do
    case Parser.parser(derive_input) do
      nil ->
        okey

      parsed_derive ->
        data
        |> SanitizerDeriver.call(Map.get(parsed_derive, :sanitize))
        |> ValidationDeriver.call(Map.get(parsed_derive, :validate))
    end
  end
end
