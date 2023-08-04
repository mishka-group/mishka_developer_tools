defmodule MishkaDeveloperToolsTest.GuardedStructDeriveTest do
  use ExUnit.Case, async: true
  alias MishkaDeveloperTools.Helper.Derive.{SanitizerDerive, ValidationDerive}

  ############## (▰˘◡˘▰) Sanitizer Derive (▰˘◡˘▰) ##############
  test "sanitize(:trim, input)" do
    "Mishka Group" = assert SanitizerDerive.sanitize(:trim, "  Mishka Group  ")
  end

  test "sanitize(:upcase, input)" do
    "MISHKA GROUP" = assert SanitizerDerive.sanitize(:upcase, "Mishka Group")
  end

  test "sanitize(:downcase, input)" do
    "mishka group" = assert SanitizerDerive.sanitize(:downcase, "MISHKA GROUP")
  end

  test "sanitize(:capitalize, input)" do
    "Mishka group" = assert SanitizerDerive.sanitize(:capitalize, "mishka group")
  end

  test "sanitize(:basic_html, input)" do
    "<p>Hi Shahryar</p>" = assert SanitizerDerive.sanitize(:basic_html, "<p>Hi Shahryar</p>")
  end

  test "sanitize(:html5, input)" do
    "<section>Hi Shahryar</section>" =
      assert SanitizerDerive.sanitize(:html5, "<section>Hi Shahryar</section>")
  end

  test "sanitize(:markdown_html, input)" do
    "[Mishka Group](https://mishka.group)" =
      assert SanitizerDerive.sanitize(:markdown_html, "[Mishka Group](https://mishka.group)")
  end

  test "sanitize(:strip_tags, input)" do
    "Hi Shahryar" = assert SanitizerDerive.sanitize(:strip_tags, "<p>Hi Shahryar</p>")
  end

  ############## (▰˘◡˘▰) Validation Derive (▰˘◡˘▰) ##############
  test "validate(:string, input, field)" do
    "Mishka" = assert ValidationDerive.validate(:string, "Mishka", :title)
    {:error, :title, :string, _msg} = assert ValidationDerive.validate(:string, :test, :title)
  end

  test "validate(:integer, input, field)" do
    2 = assert ValidationDerive.validate(:integer, 2, :age)
    {:error, :age, :integer, _msg} = assert ValidationDerive.validate(:integer, :test, :age)
  end

  test "validate(:list, input, field)" do
    ["Mishka"] = assert ValidationDerive.validate(:list, ["Mishka"], :app_list)
    {:error, :app_list, :list, _msg} = assert ValidationDerive.validate(:list, :test, :app_list)
  end

  test "validate(:atom, input, field)" do
    :mishka = assert ValidationDerive.validate(:atom, :mishka, :app_atom)
    {:error, :app_atom, :atom, _msg} = assert ValidationDerive.validate(:atom, [:test], :app_atom)
  end

  test "validate(:bitstring, input, field)" do
    <<1::3>> = assert ValidationDerive.validate(:bitstring, <<1::3>>, :app_bitstring)

    {:error, :app_bitstring, :bitstring, _msg} =
      assert ValidationDerive.validate(:bitstring, [:test], :app_bitstring)
  end

  test "validate(:boolean, input, field)" do
    true = assert ValidationDerive.validate(:atom, true, :status)

    {:error, :status, :boolean, _msg} =
      assert ValidationDerive.validate(:boolean, [:test], :status)
  end

  test "validate(:exception, input, field)" do
    %RuntimeError{} = assert ValidationDerive.validate(:exception, %RuntimeError{}, :status)

    {:error, :status, :exception, _msg} =
      assert ValidationDerive.validate(:exception, [:test], :status)
  end

  test "validate(:float, input, field)" do
    1.233 = assert ValidationDerive.validate(:float, 1.233, :status)

    {:error, :status, :float, _msg} =
      assert ValidationDerive.validate(:float, 1, :status)
  end

  test "validate(:function, input, field)" do
    getfn = ValidationDerive.validate(:function, fn x -> x + x end, :status)
    true = assert is_function(getfn)

    {:error, :status, :function, _msg} =
      assert ValidationDerive.validate(:function, "not a function", :status)
  end

  test "validate(:map, input, field)" do
    %{name: "Shahryar"} = assert ValidationDerive.validate(:map, %{name: "Shahryar"}, :status)

    {:error, :status, :map, _msg} =
      assert ValidationDerive.validate(:map, 1, :status)
  end

  test "validate(:nil_value, input, field)" do
    get_nil = ValidationDerive.validate(:nil_value, nil, :status)
    true = assert is_nil(get_nil)

    {:error, :status, :nil_value, _msg} =
      assert ValidationDerive.validate(:nil_value, 1, :status)
  end

  test "validate(:not_nil_value, input, field)" do
    1 = assert ValidationDerive.validate(:not_nil_value, 1, :status)

    {:error, :status, :not_nil_value, _msg} =
      assert ValidationDerive.validate(:not_nil_value, nil, :status)
  end

  test "validate(:number, input, field)" do
    2 = assert ValidationDerive.validate(:number, 2, :age)
    {:error, :age, :number, _msg} = assert ValidationDerive.validate(:number, :test, :age)
  end

  test "validate(:pid, input, field)" do
    get_pid = ValidationDerive.validate(:pid, self(), :node)
    true = assert is_pid(get_pid)

    {:error, :node, :pid, _msg} = assert ValidationDerive.validate(:pid, :test, :node)
  end

  test "validate(:port, input, field)" do
    get_port = ValidationDerive.validate(:port, Port.open(:name, []), :node)
    true = assert is_port(get_port)

    {:error, :node, :port, _msg} = assert ValidationDerive.validate(:port, :test, :node)
  end

  test "validate(:reference, input, field)" do
    get_reference = ValidationDerive.validate(:reference, :erlang.make_ref(), :node)
    true = assert is_reference(get_reference)

    {:error, :node, :reference, _msg} = assert ValidationDerive.validate(:reference, :test, :node)
  end

  test "validate(:struct, input, field)" do
    %User{} = assert ValidationDerive.validate(:struct, %User{}, :node)

    {:error, :node, :struct, _msg} = assert ValidationDerive.validate(:struct, :test, :node)
  end

  test "validate(:tuple, input, field)" do
    {:ok} = assert ValidationDerive.validate(:tuple, {:ok}, :node)

    {:error, :node, :tuple, _msg} = assert ValidationDerive.validate(:tuple, :test, :node)
  end

  test "validate(:not_empty, input, field) -> string" do
    "Shahryar" = assert ValidationDerive.validate(:not_empty, "Shahryar", :name)
    {:error, :name, :not_empty, _msg} = assert ValidationDerive.validate(:not_empty, "", :name)
  end

  test "validate(:not_empty, input, field) -> list" do
    ["Shahryar"] = assert ValidationDerive.validate(:not_empty, ["Shahryar"], :name)
    {:error, :name, :not_empty, _msg} = assert ValidationDerive.validate(:not_empty, [], :name)
  end

  test "validate(:not_empty, input, field) -> map" do
    %{name: "Shahryar"} = assert ValidationDerive.validate(:not_empty, %{name: "Shahryar"}, :name)
    {:error, :name, :not_empty, _msg} = assert ValidationDerive.validate(:not_empty, %{}, :name)
  end

  test "validate({:max_len, len}, input, field) -> string" do
    "Shahryar" = assert ValidationDerive.validate({:max_len, 15}, "Shahryar", :name)

    {:error, :name, :max_len, _msg} =
      assert ValidationDerive.validate({:max_len, 2}, "Mishka", :name)
  end

  test "validate({:max_len, len}, input, field) -> integer" do
    14 = assert ValidationDerive.validate({:max_len, 15}, 14, :name)

    {:error, :name, :max_len, _msg} =
      assert ValidationDerive.validate({:max_len, 2}, 15, :name)
  end

  test "validate({:max_len, len}, input, field) -> range" do
    1..14 = assert ValidationDerive.validate({:max_len, 15}, 1..14, :name)

    {:error, :name, :max_len, _msg} =
      assert ValidationDerive.validate({:max_len, 2}, 1..3, :name)
  end

  test "validate({:min_len, len}, input, field) -> string" do
    "Shahryar" = assert ValidationDerive.validate({:min_len, 8}, "Shahryar", :name)

    {:error, :name, :min_len, _msg} =
      assert ValidationDerive.validate({:min_len, 15}, "Mishka", :name)
  end

  test "validate({:min_len, len}, input, field) -> integer" do
    15 = assert ValidationDerive.validate({:min_len, 14}, 15, :name)

    {:error, :name, :min_len, _msg} =
      assert ValidationDerive.validate({:min_len, 13}, 12, :name)
  end

  test "validate({:min_len, len}, input, field) -> range" do
    14..20 = assert ValidationDerive.validate({:min_len, 14}, 14..20, :name)

    {:error, :name, :min_len, _msg} =
      assert ValidationDerive.validate({:min_len, 13}, 12..16, :name)
  end

  test "validate(:url, input, field)" do
    "https://github.com/mishka-group/" =
      assert ValidationDerive.validate(:url, "https://github.com/mishka-group/", :name)

    "http://github.com/mishka-group/" =
      assert ValidationDerive.validate(:url, "http://github.com/mishka-group/", :name)

    {:error, :name, :url, _msg} =
      assert ValidationDerive.validate(:url, "www.github.com/mishka-group/", :name)

    {:error, :name, :url, _msg1} =
      assert ValidationDerive.validate(:url, :test, :name)
  end

  test "validate(:geo_url, input, field)" do
    {:error, :map, :geo_url, _msg1} =
      assert ValidationDerive.validate(:geo_url, :test, :map)

    "geo:48.198634,-16.371648,3.4;crs=wgs84;u=40.0" =
      assert ValidationDerive.validate(
               :geo_url,
               "48.198634,-16.371648,3.4;crs=wgs84;u=40.0",
               :map
             )

    {:error, :map, :geo_url, _msg2} =
      assert ValidationDerive.validate(
               :geo_url,
               "48.198634,--16.371648,3.4",
               :map
             )
  end

  test "validate(:tell, input, field)" do
    "09368090000" = assert ValidationDerive.validate(:tell, "09368090000", :mobile)

    {:error, :mobile, :tell, _msg} =
      assert ValidationDerive.validate(:tell, "09368090000ABC", :mobile)
  end

  test "validate({:tell, country_code}, input, field) -> country_code" do
    "+989368090000" = assert ValidationDerive.validate({:tell, 98}, "+989368090000", :mobile)

    {:error, :mobile, :tell, _msg} =
      assert ValidationDerive.validate({:tell, 98}, "09368090000ABC", :mobile)

    {:error, :mobile, :tell, _msg1} =
      assert ValidationDerive.validate({:tell, 98}, "00989368090000", :mobile)
  end

  test "validate(:email, input, field)" do
    "info@gmail.com" = assert ValidationDerive.validate(:email, "info@gmail.com", :email)

    {:error, :email, :email, _msg} =
      assert ValidationDerive.validate(:email, "info@gmailtestabcd2569.com", :email)

    {:error, :email, :email, _msg1} =
      assert ValidationDerive.validate(:email, :test, :email)
  end

  test "validate(:location, input, field)" do
    "geo:48.198634,-16.371648,3.4;crs=wgs84;u=40.0" =
      assert ValidationDerive.validate(
               :location,
               "48.198634,-16.371648,3.4;crs=wgs84;u=40.0",
               :location
             )

    "geo:48.198634,-16.371648" =
      assert ValidationDerive.validate(
               :location,
               "48.198634, -16.371648",
               :location
             )

    {:error, :location, :location, _msg1} =
      assert ValidationDerive.validate(
               :location,
               "48.198634, --16.371648",
               :location
             )
  end

  test "validate(:string_boolean, input, field)" do
    "true" = assert ValidationDerive.validate(:string_boolean, "true", :status)
    "false" = assert ValidationDerive.validate(:string_boolean, "false", :status)

    {:error, :status, :string_boolean, _msg} =
      assert ValidationDerive.validate(:string_boolean, "test", :status)
  end

  test "validate(:datetime, input, field)" do
    "2023-08-04 13:46:53.419944Z" =
      assert ValidationDerive.validate(:datetime, "2023-08-04 13:46:53.419944Z", :exp)

    "2023-07-15T12:00:00Z" =
      assert ValidationDerive.validate(:datetime, "2023-07-15T12:00:00Z", :exp)

    "2023-07-16T15:00:00Z" =
      assert ValidationDerive.validate(:datetime, "2023-07-16T15:00:00Z", :exp)

    "2023-07-16T15:00:00Z" =
      assert ValidationDerive.validate(:datetime, "2023-07-16T15:00:00Z", :exp)

    "2023-07-25T18:15:00Z" =
      assert ValidationDerive.validate(:datetime, "2023-07-25T18:15:00Z", :exp)

    {:error, :exp, :datetime, _msg} =
      assert ValidationDerive.validate(:datetime, "2023-08-04", :exp)
  end

  test "validate(:date, input, field)" do
    "2023-08-04" = assert ValidationDerive.validate(:date, "2023-08-04", :exp)

    {:error, :exp, :date, _msg} =
      assert ValidationDerive.validate(:date, "2023-07-25T18:15:00Z", :exp)
  end

  test "validate(:range, input, field)" do
    1..3 = assert ValidationDerive.validate(:range, 1..3, :age)
    {:error, :age, :range, _msg} = assert ValidationDerive.validate(:range, :test, :age)
  end

  test "validate({:regex, pattern_str}, input, field)" do
    "footer" = assert ValidationDerive.validate({:regex, ~c"foo"}, "footer", :element)

    "info@gmail.com" =
      assert ValidationDerive.validate(
               {:regex, ~c"^[A-Za-z0-9\._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$"},
               "info@gmail.com",
               :email
             )

    {:error, :email, :regex, _msg} =
      assert ValidationDerive.validate({:regex, ~c"1"}, "info@gmail.com", :email)
  end
end
