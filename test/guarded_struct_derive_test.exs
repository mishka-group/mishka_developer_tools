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

  test "sanitize(:tag, input)" do
    "hi shahryar" = assert SanitizerDerive.sanitize({:tag, :strip_tags}, "<p>Hi Shahryar</p>")
  end

  test "sanitize(:not_exist, input)" do
    "<p>Hi Shahryar</p>" = assert SanitizerDerive.sanitize(:not_exist, "<p>Hi Shahryar</p>")
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

  test "validate(:ipv4, input, field)" do
    valid_ip = [
      "192.168.0.1",
      "10.0.0.1",
      "172.16.0.1",
      "192.168.1.255",
      "127.0.0.1",
      "255.255.255.255",
      "8.8.8.8",
      "198.51.100.5",
      "203.0.113.12",
      "100.64.0.1",
      "172.31.255.255",
      "169.254.1.1",
      "192.0.2.1",
      "176.16.0.1",
      "185.25.144.10",
      "20.30.40.50",
      "211.144.45.67",
      "112.42.35.68",
      "132.99.0.55",
      "223.0.0.1",
      "239.255.255.255",
      "240.0.0.0",
      "249.1.2.3",
      "190.201.202.203",
      "203.200.190.180",
      "11.22.33.44",
      "100.200.150.250",
      "150.100.50.200",
      "192.168.10.20",
      "99.99.99.99",
      "46.38.29.59",
      "172.29.150.255",
      "12.34.56.78",
      "88.77.66.55",
      "190.200.210.220",
      "5.10.15.20",
      "67.89.101.121",
      "192.160.170.180",
      "208.67.222.222",
      "130.45.67.89",
      "13.14.15.16",
      "87.65.43.21",
      "16.17.18.19",
      "200.201.202.203",
      "100.101.102.103",
      "77.88.99.100",
      "111.112.113.114",
      "135.136.137.138",
      "89.90.91.92",
      "201.202.203.204"
    ]

    validated_ips =
      Enum.map(valid_ip, fn item ->
        ValidationDerive.validate(:ipv4, item, :test)
        |> case do
          value when is_tuple(value) -> false
          value when is_binary(value) -> true
        end
      end)

    true = assert Enum.all?(validated_ips)

    invalid_ipv4_list = [
      "256.0.0.1",
      "300.200.100.50",
      "192.168.256.1",
      "1.2.3.4.5",
      "500.500.500.500",
      "192.168.0.",
      "192.168.0.256",
      "192.168.0.-1",
      "127.0.0.0.1",
      "256.256.256.256",
      "invalid",
      "300.0.0.0",
      "192.168.0.0.0",
      "192.168.0",
      "192.168.0.300",
      "2001:db8::ff00:42:8329",
      "2001:0db8:0000:0042:0000:8a2e:0370:7334",
      "::1",
      "::ffff:192.168.0.1",
      "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
      "fe80::1ff:fe23:4567:890a",
      "fe80::1ff:fe23:4567:890a%eth0",
      "fe80:::890a",
      "fe80:1ff:fe23:4567:890a",
      "fe80:1ff:fe23:4567:890a%",
      "fe80::1ff:fe23:4567:890a%",
      "fe80::1ff:fe23:4567:890a%1",
      "fe80::1ff:fe23:4567:890a%eth0%1",
      "fe80::1ff:fe23:4567:890a%123",
      "fe80::1ff:fe23:4567:890a%eth0%123",
      "2001:0db8:0000:0042:0000:8a2e:0370:7334%eth0",
      "2001:0db8:0000:0042:0000:8a2e:0370:7334%invalid",
      "2001:0db8:0000:0042:0000:8a2e:0370:7334%eth0%invalid",
      "fe80::1ff:fe23:4567:890a%eth0%1",
      "2001:0db8:0000:0042:0000:8a2e:0370:7334:5678",
      "2001:0db8:0000:0042:0000:8a2e:0370:7334%",
      "2001:0db8:0000:0042:0000:8a2e:0370:7334%%1",
      "2001:0db8:0000:0042:0000:8a2e:0370:7334%%eth0",
      "2001:0db8:0000:0042:0000:8a2e:0370:7334%1%",
      "fe80::1ff:fe23:4567:890a%eth0%%1",
      "fe80::1ff:fe23:4567:890a%eth0%1%",
      "fe80::1ff:fe23:4567:890a%eth0%123%",
      "192.168.0.1.",
      ".192.168.0.1",
      "192.168.0.1..",
      "192.168.0.1...",
      "192.168.0.",
      ".192.168.0.",
      "192.168.",
      ".192.168."
    ]

    invalidated_ips =
      Enum.map(invalid_ipv4_list, fn item ->
        ValidationDerive.validate(:ipv4, item, :test)
        |> case do
          value when is_tuple(value) -> false
          value when is_binary(value) -> true
        end
      end)
      |> Enum.all?()

    true = assert !invalidated_ips
  end

  test "validate(:not_exist, input, field)" do
    {:error, :title, :type, "Unexpected type error in title field"} =
      assert ValidationDerive.validate(:not_exist, "Mishka", :title)
  end

  defmodule TestValidate do
    def validate(:testv1, input, field) do
      if is_binary(input),
        do: input,
        else: {:error, field, :testv1, "The #{field} field must not be empty"}
    end
  end

  defmodule TestValidate2 do
    def validate(:testv2, input, field) do
      if is_binary(input),
        do: input,
        else: {:error, field, :testv1, "The #{field} field must not be empty"}
    end
  end

  defmodule TestSanitize do
    def sanitize(:capitalize_v1, input) do
      if is_binary(input), do: String.capitalize(input), else: input
    end
  end

  defmodule TestSanitize2 do
    def sanitize(:capitalize_v2, input) do
      if is_binary(input), do: String.capitalize(input), else: input
    end
  end

  defmodule TestExistCustomValidateDerive do
    use GuardedStruct

    guardedstruct validate_derive: TestValidate, sanitize_derive: TestSanitize do
      field(:id, integer(), derive: "validate(not_exist)")
      field(:title, String.t(), derive: "validate(string)")
      field(:name, String.t(), derive: "sanitize(capitalize_v2)")
    end
  end

  defmodule TestCustomeDerive do
    use GuardedStruct

    guardedstruct validate_derive: TestValidate, sanitize_derive: TestSanitize do
      field(:id, integer())
      field(:title, String.t(), derive: "validate(not_empty, testv1)")
      field(:name, String.t(), derive: "validate(string, not_empty) sanitize(trim, capitalize)")
      field(:last_name, String.t(), derive: "sanitize(capitalize_v1")
      field(:nikname, String.t(), derive: "sanitize(not_exist")
    end
  end

  test "validate(:not_exist, input, field) in custom validate" do
    {:error, :bad_parameters,
     [%{message: "Unexpected type error in id field", field: :id, action: :type}]} =
      assert TestExistCustomValidateDerive.builder(%{id: 1, title: "Mishka"})
  end

  test "validate(:custom_validate_derive, input, field) in custom validate" do
    {:ok,
     %MishkaDeveloperToolsTest.GuardedStructDeriveTest.TestCustomeDerive{
       title: "Mishka",
       id: 1,
       name: "Shahryar",
       last_name: "Tavakkoli",
       nikname: "test"
     }} =
      assert TestCustomeDerive.builder(%{
               id: 1,
               title: "Mishka",
               name: " shahryar ",
               last_name: "tavakkoli",
               nikname: "test"
             })

    {:error, :bad_parameters,
     [
       %{message: _msg, field: :title, action: :testv1},
       %{message: _msg1, field: :title, action: :not_empty}
     ]} = assert TestCustomeDerive.builder(%{id: 1, title: 1})
  end

  Application.put_env(:guarded_struct, :validate_derive, nil)
  Application.put_env(:guarded_struct, :sanitize_derive, nil)

  defmodule TestCustomListDerive do
    use GuardedStruct

    guardedstruct validate_derive: [TestValidate, TestValidate2],
                  sanitize_derive: [TestSanitize, TestSanitize2] do
      field(:id, integer())
      field(:title, String.t(), derive: "validate(not_empty, testv2)")

      field(:name, String.t(),
        derive: "validate(string, not_empty) sanitize(trim, capitalize_v2)"
      )

      field(:last_name, String.t(), derive: "sanitize(capitalize_v1")
      field(:nikname, String.t(), derive: "sanitize(not_exist")
    end
  end

  test "test custom validate and sanitize list derive" do
    {:ok,
     %MishkaDeveloperToolsTest.GuardedStructDeriveTest.TestCustomListDerive{
       title: "Mishka",
       id: 1,
       name: "Shahryar",
       last_name: "Tavakkoli",
       nikname: "test"
     }} =
      assert TestCustomListDerive.builder(%{
               id: 1,
               title: "Mishka",
               name: " shahryar ",
               last_name: "tavakkoli",
               nikname: "test"
             })
  end
end
