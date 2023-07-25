defmodule MishkaDeveloperTools.Helper.Derive.ValidationDerive do
  def call(input, nil), do: input

  def call(input, actions) do
    Enum.map(actions, &validate(&1, input))
  end

  def validate(:not_empty, input) when is_binary(input) do
    if input == "", do: {:error, :not_empty}, else: {:ok, input}
  end

  def validate(:not_empty, input) when is_list(input) do
    if input == [], do: {:error, :not_empty}, else: {:ok, input}
  end

  def validate(:not_empty, input) when is_map(input) do
    if input == %{}, do: {:error, :not_empty}, else: {:ok, input}
  end

  def validate(:not_empty, _input) do
    {:error, :not_empty}
  end

  def validate({:max_len, _len}, _input) do
  end

  def validate({:min_len, _len}, _input) do
  end

  def validate(:location, _input) do
  end

  def validate(:time, _input) do
  end

  def validate(:url, _input) do
  end
end
