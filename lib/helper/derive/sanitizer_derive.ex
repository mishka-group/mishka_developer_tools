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

  if Code.ensure_loaded?(HtmlSanitizeEx) do
    def sanitize(:basic_html, input), do: HtmlSanitizeEx.basic_html(input)

    def sanitize(:html5, input), do: HtmlSanitizeEx.html5(input)

    def sanitize(:markdown_html, input), do: HtmlSanitizeEx.markdown_html(input)

    def sanitize(:strip_tags, input), do: HtmlSanitizeEx.strip_tags(input)
  end
end
