defmodule MishkaDeveloperTools.Helper.Derive.Parser do
  def parser(input) do
    String.split(String.trim(input), ")")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn x ->
      case Code.string_to_quoted!(String.trim(x) <> ")") do
        {key, _, parameters} ->
          convert_parameters(key, parameters)

        _ ->
          nil
      end
    end)
    |> Enum.reject(&is_nil(&1))
    |> merge_parser_list()
  rescue
    # We do not check the drive in compile time, so we need to pass nil
    _e -> nil
  end

  def convert_to_atom_map(map) when is_map(map) do
    for {key, value} <- map, into: %{}, do: {convert_key(key), convert_value(value)}
  end

  defp convert_key(key) when is_binary(key) do
    String.to_atom(key)
  end

  defp convert_key(key) do
    key
  end

  defp convert_value(%{} = map) do
    convert_to_atom_map(map)
  end

  defp convert_value([]) do
    []
  end

  defp convert_value(list) when is_list(list) do
    Enum.map(list, &convert_value/1)
  end

  defp convert_value(value) do
    value
  end

  defp convert_parameters(key, parameters) do
    converted =
      parameters
      |> Enum.map(fn
        {key, _, nil} ->
          key

        {:=, _, [{key, _, nil}, {value, _, nil}]} when is_atom(value) ->
          {key, Atom.to_string(value)}

        {:=, _, [{key, _, nil}, value]} when is_integer(value) or is_list(value) ->
          {key, value}

        _ ->
          nil
      end)
      |> Enum.reject(&is_nil(&1))

    if converted == [], do: nil, else: Map.put(%{}, key, converted)
  end

  defp merge_parser_list([]), do: nil

  defp merge_parser_list(list_of_maps) do
    Enum.reduce(list_of_maps, %{}, fn map, acc ->
      Map.merge(acc, map)
    end)
  end
end
