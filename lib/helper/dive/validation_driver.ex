defmodule MishkaDeveloperTools.Helper.Derive.ValidationDeriver do
  # "validate(not_empty, max_len = 20)"
  def call(input, nil), do: input

  def call(input, action) do
    validate(action, input)
  end

  def validate(:not_empty, _input) do
  end

  def validate({:max_len, _len}, _input) do
  end

  def validate({:min_len, _len}, _input) do
  end
end
