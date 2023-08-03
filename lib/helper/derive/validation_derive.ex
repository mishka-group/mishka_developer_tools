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
    if input == "", do: {:error, field, :not_valid}, else: input
  end

  def validate(:not_empty, input, field) when is_list(input) do
    if input == [], do: {:error, field, :not_valid}, else: input
  end

  def validate(:not_empty, input, field) when is_map(input) do
    if input == %{}, do: {:error, field, :not_empty}, else: input
  end

  def validate({:max_len, len}, input, field) when is_binary(input) do
    if String.length(input) >= len, do: {:error, field, :not_valid}, else: input
  end

  def validate({:max_len, len}, input, field) when is_integer(input) do
    if input <= len, do: input, else: {:error, field, :not_valid}
  end

  def validate({:min_len, len}, input, field) when is_binary(input) do
    if String.length(input) <= len, do: {:error, field, :not_valid}, else: input
  end

  def validate({:min_len, len}, input, field) when is_integer(input) do
    if input >= len, do: input, else: {:error, field, :not_valid}
  end

  def validate(:location, _input, _field) do
  end

  def validate(:time, _input, field) do
    {:error, field, :time}
  end

  def validate(:url, input, field) when is_binary(input) do
    case URI.parse(input) do
      %URI{scheme: nil} ->
        {:error, field, "is missing a scheme (e.g. https)"}

      %URI{host: nil} ->
        {:error, field, "is missing a host"}

      %URI{port: port, scheme: scheme, host: host}
      when port in [80, 443] and scheme in ["https", "http"] ->
        case :inet.gethostbyname(Kernel.to_charlist(host)) do
          {:ok, _} -> input
          _ -> {:error, field, "invalid host"}
        end

      _ ->
        {:error, field, "invalid url"}
    end
  end

  def validate(:geo_url, input, field) when is_binary(input) do
    if Code.ensure_loaded?(URL) do
      case URL.new("geo:#{input}") do
        {:ok, %URL{scheme: "geo", parsed_path: %URL.Geo{lat: lat, lng: lng}}}
        when not is_nil(lat) and not is_nil(lng) ->
          input

        {:error, {URL.Parser.ParseError, msg}} ->
          {:error, field, msg}

        _ ->
          {:error, field, :not_valid}
      end
    else
      raise("For using this validation you need to installe `ex_url`")
    end
  end

  def validate(:tell, input, field) when is_binary(input) do
    if Code.ensure_loaded?(URL) do
      case URL.new("tel:#{input}") do
        {:ok, %URL{scheme: "tel", parsed_path: %URL.Tel{tel: tel}}} when not is_nil(tel) ->
          input

        {:error, {URL.Parser.ParseError, msg}} ->
          {:error, :tell, msg}

        _ ->
          {:error, field, :not_valid}
      end
    else
      raise("For using this validation you need to installe `ex_url`")
    end
  end

  def validate({:tell, len}, input, field) when is_binary(input) do
    if Code.ensure_loaded?(URL) do
      case URL.new("tel:#{input}") do
        {:ok, %URL{scheme: "tel", parsed_path: %URL.Tel{tel: tel}}} ->
          if String.length(tel) === len, do: input, else: {:error, field, :not_valid_length}

        {:error, {URL.Parser.ParseError, msg}} ->
          {:error, :tell, msg}

        _ ->
          {:error, field, :not_valid}
      end
    else
      raise("For using this validation you need to installe `ex_url`")
    end
  end

  def validate(:email, input, field) when is_binary(input) do
    if Code.ensure_loaded?(EmailChecker) do
      EmailChecker.valid?(input)
      |> case do
        true -> input
        _ -> {:error, field, :not_valid}
      end
    else
      case Regex.match?(~r/^[A-Za-z0-9\._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$/, input) do
        true -> input
        _ -> {:error, field, :not_valid}
      end
    end
  end

  def validate(_, _input, field) do
    {:error, field, :not_allowed_types}
  end
end
