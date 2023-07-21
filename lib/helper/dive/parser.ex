defmodule MishkaDeveloperTools.Helper.Drive.Parser do
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

  defp convert_parameters(key, parameters) do
    converted =
      parameters
      |> Enum.map(fn
        {key, _, nil} -> key
        {:=, _, [{key, _, nil}, value]} -> {key, value}
        _ -> nil
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
