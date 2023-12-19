defmodule MishkaDeveloperTools.Helper.Derive.SanitizerDerive do
  @spec call({atom(), any()}, list(any())) :: {any(), any()}
  def call({field, input}, nil), do: {field, input}

  def call({field, input}, actions) do
    converted_input = Enum.reduce(actions, input, fn i, acc -> sanitize(i, acc) end)
    {field, converted_input}
  end

  @spec sanitize(atom() | tuple(), any()) :: any()
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
    def sanitize(:basic_html, input) when is_binary(input), do: HtmlSanitizeEx.basic_html(input)

    def sanitize(:html5, input) when is_binary(input), do: HtmlSanitizeEx.html5(input)

    def sanitize(:markdown_html, input) when is_binary(input),
      do: HtmlSanitizeEx.markdown_html(input)

    def sanitize(:strip_tags, input) when is_binary(input), do: HtmlSanitizeEx.strip_tags(input)

    def sanitize({:tag, type}, input) when is_binary(input) do
      sanitize(:trim, input)
      |> then(&sanitize(if(is_binary(type), do: String.to_atom(type), else: type), &1))
      |> then(&sanitize(:trim, &1))
    end

    def sanitize(:string_float, input) when is_binary(input) do
      sanitize(:strip_tags, input)
      |> Float.parse()
      |> case do
        :error -> 0.0
        {converted_float, _} -> converted_float
      end
    rescue
      _ -> 0.0
    end

    def sanitize(:string_integer, input) when is_binary(input) do
      sanitize(:strip_tags, input)
      |> Integer.parse()
      |> case do
        :error -> 0
        {converted_integer, _} -> converted_integer
      end
    rescue
      _ -> 0
    end
  else
    def sanitize(:string_float, input) when is_binary(input) do
      Float.parse(input)
      |> case do
        :error -> 0.0
        {converted_float, _} -> converted_float
      end
    rescue
      _ -> 0.0
    end

    def sanitize(:string_integer, input) when is_binary(input) do
      Integer.parse(input)
      |> case do
        :error -> 0
        {converted_integer, _} -> converted_integer
      end
    rescue
      _ -> 0
    end
  end

  def sanitize(action, input) do
    case Application.get_env(:guarded_struct, :sanitize_derive) do
      nil ->
        input

      derive_module when is_list(derive_module) ->
        custom_derive(derive_module, action, input)

      derive_module ->
        derive_module.sanitize(action, input)
    end
  rescue
    _ -> input
  end

  defp custom_derive(derive_list, action, input) do
    Enum.reduce_while(derive_list, nil, fn item, _acc ->
      case validate_pattern(item, action, input) do
        nil -> {:cont, input}
        ouput -> {:halt, if(is_nil(ouput), do: input, else: ouput)}
      end
    end)
  end

  @spec validate_pattern(module(), list(any()), any()) :: any()
  def validate_pattern(module, action, input) do
    apply(module, :sanitize, [action, input])
  rescue
    _ -> nil
  end
end
