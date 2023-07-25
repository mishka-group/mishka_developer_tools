defmodule MishkaDeveloperTools.Helper.Derive.SanitizerDerive do
  def call(input, nil), do: input

  def call(input, actions) do
    Enum.reduce(actions, input, fn i, acc -> sanitize(i, acc) end)
  end

  def sanitize(:trim, input) do
    if is_binary(input), do: String.trim(input), else: input
  end

  def sanitize(:upcase, input) do
    if is_binary(input), do: String.upcase(input), else: input
  end

  def sanitize(:downcase, input) do
    if is_binary(input), do: String.downcase(input), else: input
  end

  def sanitize(:capitalize, input) do
    if is_binary(input), do: String.capitalize(input), else: input
  end
end
