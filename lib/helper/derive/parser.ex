defmodule MishkaDeveloperTools.Helper.Derive.Parser do
  @spec parser(list(String.t()) | String.t()) :: any()
  def parser(inputs) when is_list(inputs) do
    Enum.map(inputs, &parser(&1))
  end

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

  def parser(blocks, :conditional, parent \\ "root") do
    case blocks do
      {:__block__, line, items} ->
        {:__block__, line, elements_unification(items, parent)}

      {:field, line, items} ->
        {:field, line, add_parent_tags(items, parent)}

      {:sub_field, line, items} ->
        {:sub_field, line, add_parent_tags(items, parent)}

      {:conditional_field, line, items} ->
        raise("""
        \n ----------------------------------------------------------\n
        Unfortunately, this macro does not support the nested mode in the conditional_field macro.
        If you can add this feature I would be very happy to send a PR.
        More information: https://github.com/mishka-group/mishka_developer_tools/issues/25
        Parent Issue: https://github.com/mishka-group/mishka_developer_tools/issues/23
        \n ----------------------------------------------------------\n
        """)

        {:conditional_field, line,
         elements_unification(add_parent_tags(items, parent, "conds"), parent)}
    end
  end

  defp elements_unification(blocks, parent) do
    Enum.map(blocks, fn
      {:field, line, items} ->
        {:field, line, add_parent_tags(items, parent)}

      {:sub_field, line, items} ->
        {:sub_field, line, add_parent_tags(items, parent)}

      {:conditional_field, line, items} ->
        raise("""
        \n ----------------------------------------------------------\n
        Unfortunately, this macro does not support the nested mode in the conditional_field macro.
        If you can add this feature I would be very happy to send a PR.
        More information: https://github.com/mishka-group/mishka_developer_tools/issues/25
        Parent Issue: https://github.com/mishka-group/mishka_developer_tools/issues/23
        \n ----------------------------------------------------------\n
        """)

        comverted_items = add_parent_tags(items, parent, "conds")

        recursive_children =
          Enum.map(comverted_items, fn item ->
            if Keyword.keyword?(item) and Keyword.has_key?(item, :do),
              do: [
                do:
                  parser(Keyword.get(item, :do), :conditional, find_node_tags(comverted_items).id)
              ],
              else: item
          end)

        {:conditional_field, line, recursive_children}
    end)
  end

  def find_node_tags([_name, _type, opts | _reset] = _items) do
    %{parent: opts[:__node_parent_tree__], type: opts[:__node_type__], id: opts[:__node_id__]}
  end

  defp add_parent_tags(items, parent, type \\ "normal") do
    id = parent <> "::" <> Helper.Extra.randstring(8)

    Enum.map(items, fn item ->
      if Keyword.keyword?(item) and !Keyword.has_key?(item, :__node_type__) and
           !Keyword.has_key?(item, :do) do
        item ++ [__node_parent_tree__: parent, __node_type__: type, __node_id__: id]
      else
        item
      end
    end)
  end

  @spec convert_to_atom_map({:ok, map()} | {:error, any(), any()} | map()) ::
          {:error, any(), any()} | map()

  def convert_to_atom_map({:error, _, _} = error), do: error

  def convert_to_atom_map({:ok, map}) when is_map(map), do: convert_to_atom_map(map)

  def convert_to_atom_map(map) when is_map(map) do
    for {key, value} <- map, into: %{}, do: {convert_key(key), convert_value(value)}
  end

  defp convert_key(key) when is_binary(key), do: String.to_atom(key)

  defp convert_key(key), do: key

  defp convert_value(%{} = map), do: convert_to_atom_map(map)

  defp convert_value([]), do: []

  defp convert_value(list) when is_list(list), do: Enum.map(list, &convert_value/1)

  defp convert_value(value), do: value

  @spec convert_parameters(atom() | String.t(), any()) :: nil | %{optional(any()) => list()}
  def convert_parameters(derive_key, parameters) do
    converted =
      parameters
      |> Enum.map(fn
        {key, _, nil} ->
          key

        {:=, _, [{key, _, nil}, {value, _, nil}]} when is_atom(value) ->
          {key, Atom.to_string(value)}

        {:=, _, [{key, _, nil}, value]} when is_integer(value) ->
          {key, value}

        {:=, _, [{key, _, nil}, value]} when is_list(value) and key == :custom ->
          case value do
            [{:__aliases__, _, module_list}, {function, _, nil}] ->
              {key, {module_list, function}}

            _ ->
              nil
          end

        {:=, _, [{key, _, nil}, value]} when is_list(value) ->
          if Enum.any?(value, &is_tuple(&1)),
            do: convert_parameters(key, value),
            else: {key, value}

        {:=, _, [{key, _, nil}, {_, _, [{:__aliases__, _, [type]} | _t]} = value]}
        when is_tuple(value) and is_atom(type) ->
          {key, Macro.to_string(value)}

        _ ->
          nil
      end)
      |> Enum.reject(&is_nil(&1))

    if converted == [], do: nil, else: Map.put(%{}, derive_key, converted)
  end

  defp merge_parser_list([]), do: nil

  defp merge_parser_list(list_of_maps) do
    Enum.reduce(list_of_maps, %{}, fn map, acc ->
      Map.merge(acc, map)
    end)
  end

  @spec parse_core_keys_pattern(binary()) :: list()
  def parse_core_keys_pattern(pattern) do
    pattern
    |> String.trim()
    |> String.split("::", trim: true)
    |> Enum.map(&String.to_atom/1)
  end

  @spec is_data?(%{:data => any(), :errors => any(), optional(any()) => any()}) :: boolean()
  @doc false
  def is_data?(%{data: [], errors: []}), do: true

  def is_data?(%{data: [], errors: errors}) when errors != [], do: false

  def is_data?(%{data: data, errors: errors}) when data != [] and errors == [], do: true

  def is_data?(%{data: _data, errors: errors}) when errors != [], do: false

  @spec map_keys(map(), list(atom())) :: any()
  @doc false
  def map_keys(map_data, keys) when is_map(map_data) do
    case List.first(Map.keys(map_data)) do
      nil -> keys
      data when is_atom(data) -> keys
      data when is_binary(data) -> Enum.map(keys, &Atom.to_string(&1))
    end
  end

  def map_keys(_map, keys), do: keys

  @spec field_status?(tuple(), atom()) :: boolean()
  def field_status?({{:error, _, _}, _}, status) when status === :error,
    do: true

  def field_status?({{:error, _, _}, _, _}, status) when status === :error,
    do: true

  def field_status?({{field_status, _, _}, _}, status) when field_status === status,
    do: true

  def field_status?({{field_status, _}, _, _}, status) when field_status === status,
    do: true

  def field_status?(_, _), do: false

  @spec field_value(
          maybe_improper_list()
          | {{:ok, any()} | {:error, any(), any()} | {:ok, any(), any()}, any()}
          | {{:ok, any()} | {:error, any(), any()}, any(), any()}
        ) :: maybe_improper_list() | {any(), any()}
  def field_value({{:error, _, _}, _} = output), do: [output]

  def field_value({{:error, _, _}, _, _} = output), do: [output]

  def field_value({{:ok, _, value}, opts}), do: {value, opts}

  def field_value({{:ok, value}, _, opts}), do: {value, opts}

  def field_value({{:ok, value}, opts}), do: {value, opts}

  def field_value(output) when is_list(output), do: output

  def field_value(nil),
    do:
      raise(
        "Oh no!, I think you have not made all the subfields of a conditional field to the same name"
      )

  @spec conds_list(list(map()) | map(), String.t()) :: any()
  def conds_list(data, parent_key) do
    items_with_parent =
      Enum.filter(data, fn %{opts: opts} -> opts[:__node_parent_tree__] == parent_key end)

    Enum.reduce(items_with_parent, %{}, fn item, acc ->
      children = find_conds_children_recursive(data, item.opts[:__node_id__])
      Map.put(acc, item.opts[:__node_id__], Map.merge(item, %{children: children}))
    end)
  end

  defp find_conds_children_recursive(data, parent_tag) do
    children =
      Enum.filter(data, fn %{opts: opts} -> opts[:__node_parent_tree__] == parent_tag end)

    Enum.reduce(children, %{}, fn item, acc ->
      children = find_conds_children_recursive(data, item.opts[:__node_id__])
      Map.put(acc, item.opts[:__node_id__], Map.merge(item, %{children: children}))
    end)
  end
end
