defmodule MishkaDeveloperTools.Helper.Derive do
  alias MishkaDeveloperTools.Helper.Derive.{Parser, SanitizerDerive, ValidationDerive}

  @spec derive(
          {:error, any(), any()}
          | {:ok, any(), [binary()]}
          | {:error, any(), any(), :halt}
          | {:error, any(), :nested, list(), any(), [binary()]}
        ) :: {:ok, map()} | {:error, any(), any()}
  def derive({:error, type, message, :halt}) do
    {:error, type, message}
  end

  def derive({:error, _, :nested, builders_errors, data, derive_inputs}),
    do: derive({:ok, data, derive_inputs}, builders_errors)

  def derive({:error, _, _} = error), do: error

  @spec derive({:ok, any(), list(String.t())}, list()) ::
          {:ok, map()} | {:error, :bad_parameters, list()}
  def derive({:ok, data, derive_inputs}, extra_error \\ []) do
    reduced_fields =
      Enum.reduce(derive_inputs, %{}, fn map, acc ->
        derives = Parser.parser(map.derive)
        field = Map.get(data, map.field)
        hint = Map.get(map, :hint) || []

        update_reduced_fields(field, derives, hint, map, acc)
      end)

    {:error, :bad_parameters, get_error} = error = error_handler(reduced_fields, extra_error)

    if length(get_error) == 0, do: {:ok, Map.merge(data, reduced_fields)}, else: error
  end

  defp update_reduced_fields(nil, _parsed_derive, _hint, _map, acc), do: acc

  defp update_reduced_fields(get_field, parsed_derive, hints, map, acc)
       when is_list(parsed_derive) and parsed_derive != [] do
    converted_validated_values =
      Enum.zip([parsed_derive, get_field, hints])
      |> Enum.map(fn {derive, value, hint} ->
        derive = if(derive == [], do: nil, else: derive)

        {all_data, validated_errors} =
          {map.field, value}
          |> SanitizerDerive.call(Map.get(derive || %{}, :sanitize))
          |> ValidationDerive.call(Map.get(derive || %{}, :validate), hint)

        if length(validated_errors) > 0, do: {:error, validated_errors}, else: all_data
      end)

    errors =
      converted_validated_values
      |> Enum.filter(&(is_tuple(&1) and elem(&1, 0) == :error))
      |> Enum.map(fn {:error, errors} -> errors end)
      |> Enum.concat()

    Map.put(
      acc,
      map.field,
      if(length(errors) > 0, do: {:error, errors}, else: converted_validated_values)
    )
  end

  defp update_reduced_fields(get_field, parsed_derive, hint, map, acc) do
    # destruct because we consider empty list default value when there is no derive
    parsed_derive = if(parsed_derive == [], do: nil, else: parsed_derive)

    {all_data, validated_errors} =
      {map.field, get_field}
      |> SanitizerDerive.call(Map.get(parsed_derive || %{}, :sanitize))
      |> ValidationDerive.call(Map.get(parsed_derive || %{}, :validate), hint)

    converted_validated_values =
      if length(validated_errors) > 0, do: {:error, validated_errors}, else: all_data

    Map.put(acc, map.field, converted_validated_values)
  end

  @spec error_handler(map(), list(any())) :: {:error, :bad_parameters, any()}
  def error_handler(reduced_fields, extra_error \\ []) do
    errors =
      Enum.find(extra_error, fn %{field: _, errors: {type, _}} -> type == :required_fields end)
      |> case do
        nil ->
          get_error =
            reduced_fields
            |> Map.values()
            |> Enum.filter(&(is_tuple(&1) && elem(&1, 0) == :error))
            |> Enum.map(fn {:error, errors} -> errors end)
            |> Enum.concat()
            |> halt_errors()

          get_error ++ extra_error

        _ ->
          extra_error
      end

    {:error, :bad_parameters, errors}
  end

  defp halt_errors(errors_list) do
    errors_list
    |> Enum.reduce_while([], fn item, acc ->
      if Map.get(item, :status) == :halt,
        do: {:halt, acc ++ [Map.delete(item, :status)]},
        else: {:cont, acc ++ [item]}
    end)
  end

  @spec get_derives_from_success_conditional_data(list(any())) :: any()
  @doc false
  def get_derives_from_success_conditional_data(conds) do
    Enum.reduce(conds, [], fn
      {field, {{:ok, _data}, opts}}, acc ->
        get_derive = Keyword.get(opts, :derive, [])
        get_hint = Keyword.get(opts, :hint, [])

        acc ++ [Map.new([{:derive, get_derive}, {:field, field}, {:hint, get_hint}])]

      {field, values}, acc ->
        %{derive: derives, hint: hints} =
          Enum.reduce(values, %{derive: [], hint: []}, fn {{:ok, _value}, opts}, acc ->
            get_derive = Keyword.get(opts, :derive, [])
            get_hint = Keyword.get(opts, :hint, [])

            Map.merge(acc, %{derive: acc.derive ++ [get_derive], hint: acc.hint ++ [get_hint]})
          end)

        acc ++ [Map.new([{:derive, derives}, {:field, field}, {:hint, hints}])]
    end)
  end
end
