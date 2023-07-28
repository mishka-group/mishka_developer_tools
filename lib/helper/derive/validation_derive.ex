defmodule MishkaDeveloperTools.Helper.Derive.ValidationDerive do
  def call({_field, input}, nil), do: {input, []}

  def call({field, input}, actions) do
    validated = Enum.map(actions, &validate(&1, input, field))

    validated_errors =
      Enum.reduce(validated, [], fn map, acc ->
        if is_tuple(map) and elem(map, 0) == :error do
          [%{message: elem(map, 2), action: field}] ++ acc
        else
          acc
        end
      end)

    {List.first(validated), validated_errors}
  end

  def validate(:not_empty, input, field) when is_binary(input) do
    if input == "", do: {:error, field, :not_empty}, else: input
  end

  def validate(:not_empty, input, field) when is_list(input) do
    if input == [], do: {:error, field, :not_empty}, else: input
  end

  def validate(:not_empty, input, field) when is_map(input) do
    if input == %{}, do: {:error, field, :not_empty}, else: input
  end

  def validate({:max_len, len}, input, field) when is_binary(input) do
    if String.length(input) >= len, do: {:error, field, :max_len}, else: input
  end

  def validate({:max_len, len}, input, field) when is_integer(input) do
    if input <= len, do: input, else: {:error, field, :max_len}
  end

  def validate({:min_len, len}, input, field) when is_binary(input) do
    if String.length(input) <= len, do: {:error, field, :min_len}, else: input
  end

  def validate({:min_len, len}, input, field) when is_integer(input) do
    if input >= len, do: input, else: {:error, field, :max_len}
  end

  def validate(:location, _input, _field) do
  end

  def validate(:time, _input, field) do
    {:error, field, :time}
  end

  def validate(:url, input, field) when is_binary(input) do
    {:error, field, :time}
  end

  def validate(:email, input, field) when is_binary(input) do
    {:error, field, :email}
  end

  def validate(_, _input, field) do
    {:error, field, :not_allowed_types}
  end
end
