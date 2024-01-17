defmodule MishkaDeveloperTools.Helper.Derive do
  alias MishkaDeveloperTools.Helper.Derive.{Parser, SanitizerDerive, ValidationDerive}

  @spec derive(
          {:error, any(), any()}
          | {:ok, any(), list(String.t() | map())}
          | {:error, any(), :halt}
          | {:error, :nested, list(), any(), [binary()]}
        ) :: {:ok, map()} | {:error, any()}
  def derive({:error, type, message, :halt}) do
    {:error, type, message}
  end

  def derive({:error, :nested, builders_errors, data, derive_inputs}),
    do: derive({:ok, data, derive_inputs}, builders_errors)

  def derive({:error, _, _} = error), do: error

  def derive({:error, _} = error), do: error

  @spec derive({:ok, any(), list(String.t() | map())}, list()) ::
          {:ok, map()} | {:error, list()}
  def derive({:ok, data, derive_inputs}, extra_error \\ []) do
    reduced_fields =
      Enum.reduce(derive_inputs, %{}, fn map, acc ->
        derives = Parser.parser(map.derive)
        field = Map.get(data, map.field)
        hint = Map.get(map, :hint) || []

        update_reduced_fields(field, derives, hint, map, acc)
      end)

    {:error, get_error} = error = error_handler(reduced_fields, extra_error)

    if length(get_error) == 0, do: {:ok, Map.merge(data, reduced_fields)}, else: error
  end

  defp update_reduced_fields(nil, _parsed_derive, _hint, _map, acc), do: acc

  defp update_reduced_fields(get_field, parsed_derive, hints, map, acc)
       when is_list(parsed_derive) and parsed_derive != [] do
    # Temporary way to find it is list conditional or not
    list_data? = is_list(get_field) and length(get_field) == length(parsed_derive)

    get_field =
      if list_data? do
        get_field
      else
        stream = Stream.duplicate(get_field, length(parsed_derive))
        Enum.to_list(stream)
      end

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

    {errors, data} = derive_list_values_and_errors_divider(converted_validated_values)

    if list_data? do
      Map.put(acc, map.field, if(length(errors) > 0, do: {:error, errors}, else: data))
    else
      Map.put(acc, map.field, if(length(data) > 0, do: List.first(data), else: {:error, errors}))
    end
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

  defp derive_list_values_and_errors_divider(data) do
    {error, no_error} =
      data
      |> Enum.split_with(&(is_tuple(&1) and elem(&1, 0) == :error))

    converted_error = Enum.map(error, fn {:error, errors} -> errors end) |> Enum.concat()

    {converted_error, no_error}
  end

  @spec error_handler(map(), list(any())) :: {:error, any()}
  def error_handler(reduced_fields, extra_error \\ []) do
    errors =
      Enum.find(extra_error, fn %{field: _, errors: errorMap} ->
        !is_list(errorMap) and errorMap.action == :required_fields
      end)
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

    {:error, errors}
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
        case Keyword.keyword?(opts) do
          true ->
            get_derive = Keyword.get(opts, :derive, [])
            get_hint = Keyword.get(opts, :hint, [])
            acc ++ [Map.new([{:derive, get_derive}, {:field, field}, {:hint, get_hint}])]

          false when is_list(opts) ->
            %{derive: derives, hint: hints} =
              Enum.reduce(opts, %{derive: [], hint: []}, fn item, acc ->
                get_derive = Keyword.get(item, :derive, [])
                get_hint = Keyword.get(item, :hint, [])

                Map.merge(acc, %{derive: acc.derive ++ [get_derive], hint: acc.hint ++ [get_hint]})
              end)

            acc ++ [Map.new([{:derive, derives}, {:field, field}, {:hint, hints}])]

          _ ->
            # We do not cover this setuation
            acc
        end

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

  def pre_derives_check({{:ok, _, data}, _} = result, opts, field) do
    run_pre_derives_check(data, opts[:derive], result, field, opts)
  end

  def pre_derives_check({{:ok, data}, _, _} = result, opts, field) do
    run_pre_derives_check(data, opts[:derive], result, field, opts)
  end

  def pre_derives_check({{:error, _, _}, _} = result, _opts, _field), do: result

  def pre_derives_check({{:error, _}, _, _} = result, _opts, _field), do: result

  def pre_derives_check({{:error, _}, _} = result, _opts, _field), do: result

  defp run_pre_derives_check(_, nil, validator_result, _field, _opts), do: validator_result

  defp run_pre_derives_check(value, derive, _, field, opts) do
    {:ok, Map.new([{field, value}]), [%{derive: derive, field: field}]}
    |> derive()
    |> case do
      {:ok, data} -> {{:ok, field, Map.get(data, field)}, opts}
      {:error, _} = error -> {error, field, opts}
    end
  end
end
