defmodule MishkaDeveloperTools.Helper.Derive.ValidationDerive do
  def call({_field, input}, nil), do: {input, []}

  def call({field, input}, actions) do
    validated = Enum.map(actions, &validate(&1, input, field))

    validated_errors =
      Enum.reduce(validated, [], fn map, acc ->
        if is_tuple(map) and elem(map, 0) == :error do
          [%{field: field, action: elem(map, 2), message: elem(map, 3)}] ++ acc
        else
          acc
        end
      end)

    {List.first(validated), validated_errors}
  end

  def validate(:not_empty, input, field) when is_binary(input) do
    if input == "",
      do: {:error, field, :not_empty, "The #{field} field must not be empty"},
      else: input
  end

  def validate(:not_empty, input, field) when is_list(input) do
    if input == [],
      do: {:error, field, :not_empty, "The #{field} field must not be empty"},
      else: input
  end

  def validate(:not_empty, input, field) when is_map(input) do
    if input == %{},
      do: {:error, field, :not_empty, "The #{field} field must not be empty"},
      else: input
  end

  def validate({:max_len, len}, input, field) when is_binary(input) do
    if String.length(input) >= len,
      do:
        {:error, field, :max_len,
         "The maximum number of characters in the #{field} field is #{len} and you have sent more than this number of entries"},
      else: input
  end

  def validate({:max_len, len}, input, field) when is_integer(input) do
    if input <= len,
      do: input,
      else:
        {:error, field, :max_len,
         "The maximum number the #{field} field is #{len} and you have sent more than this number of entries"}
  end

  def validate({:min_len, len}, input, field) when is_binary(input) do
    if String.length(input) <= len,
      do:
        {:error, field, :min_len,
         "The minimum number of characters in the #{field} field is #{len} and you have sent less than this number of entries"},
      else: input
  end

  def validate({:min_len, len}, input, field) when is_integer(input) do
    if input >= len,
      do: input,
      else:
        {:error, field, :min_len,
         "The minimum number the #{field} field is #{len} and you have sent less than this number of entries"}
  end

  def validate(:location, _input, _field) do
  end

  def validate(:time, _input, field) do
    {:error, field, :time, :not_valid}
  end

  def validate(:url, input, field) when is_binary(input) do
    case URI.parse(input) do
      %URI{scheme: nil} ->
        {:error, field, :url, "Is missing a url scheme (e.g. https) in the #{field} field"}

      %URI{host: nil} ->
        {:error, field, :url, "Is missing a url host in the #{field} field"}

      %URI{port: port, scheme: scheme, host: host}
      when port in [80, 443] and scheme in ["https", "http"] ->
        case :inet.gethostbyname(Kernel.to_charlist(host)) do
          {:ok, _} -> input
          _ -> {:error, field, :url, "Invalid url host in the #{field} field"}
        end

      _ ->
        {:error, field, :url, "Invalid url format in the #{field} field"}
    end
  end

  def validate(:geo_url, input, field) when is_binary(input) do
    if Code.ensure_loaded?(URL) do
      case URL.new("geo:#{input}") do
        {:ok, %URL{scheme: "geo", parsed_path: %URL.Geo{lat: lat, lng: lng}}}
        when not is_nil(lat) and not is_nil(lng) ->
          input

        {:error, {URL.Parser.ParseError, _msg}} ->
          {:error, field, :geo_url,
           "Invalid geo url format in the #{field} field, you should send latitude and longitude"}

        _ ->
          {:error, field, :geo_url,
           "Invalid geo url format in the #{field} field, you should send latitude and longitude"}
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

        {:error, {URL.Parser.ParseError, _msg}} ->
          {:error, field, :tell, "Invalid tell format in the #{field} field"}

        _ ->
          {:error, field, :tell, "Invalid tell format in the #{field} field"}
      end
    else
      raise("For using this validation you need to installe `ex_url`")
    end
  end

  def validate({:tell, len}, input, field) when is_binary(input) do
    if Code.ensure_loaded?(URL) do
      case URL.new("tel:#{input}") do
        {:ok, %URL{scheme: "tel", parsed_path: %URL.Tel{tel: tel}}} ->
          if String.length(tel) === len,
            do: input,
            else: {:error, field, :tell, "You must send #{len} numbers for the #{field} field"}

        {:error, {URL.Parser.ParseError, _msg}} ->
          {:error, field, :tell, "Invalid tell format in the #{field} field"}

        _ ->
          {:error, field, :tell, "Invalid tell format in the #{field} field"}
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
        _ -> {:error, field, :email, "Incorrect email in the #{field} field."}
      end
    else
      case Regex.match?(~r/^[A-Za-z0-9\._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$/, input) do
        true -> input
        _ -> {:error, field, :email, "Invalid email format in the #{field} field"}
      end
    end
  end

  def validate(_, _input, field) do
    {:error, field, :type, "Unexpected type error #{inspect(field)}"}
  end
end
