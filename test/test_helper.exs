ExUnit.start()

defmodule User do
  defstruct name: "Shahryar"
end

defmodule ConditionalFieldValidatorTestValidators do
  def is_string_data(field, value) do
    if is_binary(value), do: {:ok, field, value}, else: {:error, field, "It is not string"}
  end

  def is_map_data(field, value) do
    if is_map(value), do: {:ok, field, value}, else: {:error, field, "It is not map"}
  end

  def is_list_data(field, value) do
    if is_list(value), do: {:ok, field, value}, else: {:error, field, "It is not list"}
  end

  def is_flat_list_data(field, value) do
    if is_list(value),
      do: {:ok, field, List.flatten(value)},
      else: {:error, field, "It is not list"}
  end

  def is_int_data(field, value) do
    if is_integer(value), do: {:ok, field, value}, else: {:error, field, "It is not integer"}
  end
end
