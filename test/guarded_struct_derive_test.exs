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
end
