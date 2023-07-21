defmodule MishkaDeveloperTools.Helper.Derive.SanitizerDerive do
  # "sanitize(trim, lowercase)"
  #
  def call(input, nil), do: input

  def call(input, action) do
    sanitize(action, input)
  end

  def sanitize(:trim, _input) do
  end

  def sanitize(:upcase, _input) do
  end

  def sanitize(:downcase, _input) do
  end
end
