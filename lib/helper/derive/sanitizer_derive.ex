defmodule MishkaDeveloperTools.Helper.Derive.SanitizerDerive do
  def call({field, input}, nil), do: {field, input}

  def call({field, input}, actions) do
    converted_input = Enum.reduce(actions, input, fn i, acc -> sanitize(i, acc) end)
    {field, converted_input}
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
