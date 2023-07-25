defmodule MishkaDeveloperTools.Helper.Derive do
  alias MishkaDeveloperTools.Helper.Derive.{Parser, SanitizerDerive, ValidationDerive}

  def derive({:error, _, _} = error, _derive_input), do: error

  def derive({:ok, data}, derive_inputs) do
    Enum.reduce(derive_inputs, %{}, fn map, acc ->
      parsed_derive = Parser.parser(derive_inputs)
      get_field = Map.get(data, map.field)

      if !is_nil(parsed_derive) do
        converted_value =
          get_field
          |> SanitizerDerive.call(Map.get(parsed_derive, :sanitize))
          |> ValidationDerive.call(Map.get(parsed_derive, :validate))

        Map.put(acc, map.field, converted_value)
      else
        acc
      end
    end)
  end
end
