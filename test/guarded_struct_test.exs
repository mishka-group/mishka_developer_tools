defmodule MishkaDeveloperToolsTest.GuardedStructTest do
  use ExUnit.Case, async: true

  ############## (▰˘◡˘▰) GuardedStructTest Data (▰˘◡˘▰) ##############
  # Store the bytecode so we can get information from it.
  {:module, _name, bytecode, _exports} =
    defmodule TestStruct do
      use GuardedStruct

      guardedstruct do
        field(:int, integer())
        field(:string, String.t())
        field(:string_with_default, String.t(), default: "default")
        field(:mandatory_int, integer(), enforce: true)
      end

      def enforce_keys, do: @enforce_keys
    end

  {:module, _name, bytecode_opaque, _exports} =
    defmodule OpaqueTestStruct do
      use GuardedStruct

      guardedstruct opaque: true do
        field(:int, integer())
      end
    end

  defmodule EnforcedGuardedStruct do
    use GuardedStruct

    guardedstruct enforce: true do
      field(:enforced_by_default, term())
      field(:not_enforced, term(), enforce: false)
      field(:with_default, integer(), default: 1)
      field(:with_false_default, boolean(), default: false)
      field(:with_nil_default, term(), default: nil)
    end

    def enforce_keys, do: @enforce_keys
  end

  defmodule TestModule do
    use GuardedStruct

    guardedstruct module: Struct do
      field(:field, term())
    end
  end

  {:module, _name, bytecode_noalias, _exports} =
    defmodule TestStructNoAlias do
      use GuardedStruct

      guardedstruct do
        field(:test, TestModule.TestSubModule.t())
      end
    end

  @bytecode bytecode
  @bytecode_opaque bytecode_opaque
  @bytecode_noalias bytecode_noalias

  ############## (▰˘◡˘▰) GuardedStructTest Tests functions (▰˘◡˘▰) ##############
  test "generates the struct with its defaults" do
    assert TestStruct.__struct__() == %TestStruct{
             int: nil,
             string: nil,
             string_with_default: "default",
             mandatory_int: nil
           }
  end

  test "enforces keys for fields with `enforce: true`" do
    assert TestStruct.enforce_keys() == [:mandatory_int]
  end

  test "enforces keys by default if `enforce: true` is set at top-level" do
    assert :enforced_by_default in EnforcedGuardedStruct.enforce_keys()
  end

  test "does not enforce keys for fields explicitely setting `enforce: false" do
    refute :not_enforced in EnforcedGuardedStruct.enforce_keys()
  end

  test "does not enforce keys for fields with a default value" do
    refute :with_default in EnforcedGuardedStruct.enforce_keys()
  end

  test "generates a type for the struct" do
    # Define a second struct with the type expected for TestStruct.
    {:module, _name, bytecode2, _exports} =
      defmodule TestStruct2 do
        defstruct [:int, :string, :string_with_default, :mandatory_int]

        @type t() :: %__MODULE__{
                int: integer() | nil,
                string: String.t() | nil,
                string_with_default: String.t(),
                mandatory_int: integer()
              }
      end

    # the second struct with the name of the first one).
    fields = [:int, :string, :string_with_default, :mandatory_int]

    assert check_type(:t, bytecode2, fields)
    assert check_type(:t, @bytecode, fields)
  end

  test "generates an opaque type if `opaque: true` is set" do
    # Define a second struct with the type expected for TestStruct.
    {:module, _name, bytecode_expected, _exports} =
      defmodule TestStruct3 do
        defstruct [:int]

        @opaque t() :: %__MODULE__{
                  int: integer() | nil
                }
      end

    fields = [:int]

    assert check_type(:t, @bytecode_opaque, fields, :opaque)
    assert check_type(:t, bytecode_expected, fields, :opaque)
  end

  test "generates the struct in a submodule if `module: ModuleName` is set" do
    assert TestModule.Struct.__struct__() == %TestModule.Struct{field: nil}
  end

  test "GuardedStruct macros are available only in the guardedstruct block" do
    assert_raise CompileError, ~r"cannot compile module", fn ->
      defmodule ScopeTest do
        use GuardedStruct

        guardedstruct do
          field(:in_scope, term())
        end

        # Let’s try to use field/2 outside the block.
        field(:out_of_scope, term())
      end
    end
  end

  test "the name of a field must be an atom" do
    assert_raise ArgumentError, "a field name must be an atom, got 3", fn ->
      defmodule InvalidStruct do
        use GuardedStruct

        guardedstruct do
          field(3, integer())
        end
      end
    end
  end

  test "it is not possible to add twice a field with the same name" do
    assert_raise ArgumentError, "the field :name is already set", fn ->
      defmodule InvalidStruct do
        use GuardedStruct

        guardedstruct do
          field(:name, String.t())
          field(:name, integer())
        end
      end
    end
  end

  test "aliases are properly resolved in types" do
    {:module, _name, bytecode_actual, _exports} =
      defmodule TestStructWithAlias do
        use GuardedStruct

        guardedstruct do
          alias TestModule.TestSubModule

          field(:test, TestSubModule.t())
        end
      end

    fields = [:test]

    assert check_type(:t, @bytecode_noalias, fields)
    assert check_type(:t, bytecode_actual, fields)
  end

  test "create builder function to test enforce keys and normal keys" do
    defmodule TestStructBuilder do
      use GuardedStruct

      guardedstruct do
        field(:name, String.t(), enforce: true)
        field(:title, String.t())
      end
    end

    {:error, :required_fields, [:name]} = assert TestStructBuilder.builder(%{title: "user"})

    {:ok, data} = assert TestStructBuilder.builder(%{name: "shahryar", title: "user"})

    assert is_struct(data)

    enforce_keys = TestStructBuilder.enforce_keys()
    enforce_keys_by_field = TestStructBuilder.enforce_keys(:name)
    keys = TestStructBuilder.keys()
    keys_by_field = TestStructBuilder.keys(:name)

    [:name] = assert enforce_keys
    assert enforce_keys_by_field
    [:title, :name] = assert keys
    assert keys_by_field
  end

  test "use builder to test an allowed map as its params" do
    defmodule TestStructBuilderAllowedMap do
      use GuardedStruct

      guardedstruct do
        field(:name, String.t(), enforce: true)
        field(:title, String.t())
      end
    end

    test_map = %{name: "shahryar", title: "user", test: "test"}

    {:ok, _data} = assert TestStructBuilderAllowedMap.builder(test_map)
  end

  test "use builder to get validator inside its module" do
    defmodule TestStructInsideValidatorBuilder do
      use GuardedStruct

      guardedstruct do
        field(:name, String.t(), enforce: true)
        field(:title, String.t())
      end

      def validator(:name, value) do
        if is_binary(value), do: {:ok, :name, value}, else: {:error, :name, "No, never"}
      end

      def validator(name, value) do
        {:ok, name, value}
      end
    end

    {:ok, _data} =
      assert TestStructInsideValidatorBuilder.builder(%{name: "shahryar", title: "user"})

    {:error, :bad_parameters, [%{message: _msg, action: :name}]} =
      assert TestStructInsideValidatorBuilder.builder(%{name: 1, title: "user"})
  end

  test "use builder to get main_validator inside its module" do
    defmodule TestStructInsideMainValidatorBuilder do
      use GuardedStruct

      guardedstruct do
        field(:name, String.t(), enforce: true)
        field(:title, String.t())
      end

      def validator(:name, value) do
        if is_binary(value), do: {:ok, :name, value}, else: {:error, :name, "No, never"}
      end

      def validator(name, value) do
        {:ok, name, value}
      end

      def main_validator(value) do
        {:ok, value}
      end
    end

    {:ok, _data} =
      assert TestStructInsideMainValidatorBuilder.builder(%{name: "mishka", title: "org"})
  end

  test "use builder to get validator inside another module" do
    defmodule GuardedStructTest.AnotherModule do
      def validator(:name, value) do
        if is_binary(value), do: {:ok, :name, value}, else: {:error, :name, "No, never"}
      end
    end

    defmodule TestStructAnotherValidatorBuilder do
      alias GuardedStructTest.AnotherModule
      use GuardedStruct

      guardedstruct do
        field(:name, String.t(), enforce: true, validator: {AnotherModule, :validator})
        field(:title, String.t())
      end

      # You can not use it, but it is mentioned here for test clarity
      def validator(name, value) do
        {:ok, name, value}
      end
    end

    {:ok, _data} =
      assert TestStructAnotherValidatorBuilder.builder(%{name: "mishka", title: "org"})

    {:error, :bad_parameters, [%{message: _msg, action: :name}]} =
      assert TestStructAnotherValidatorBuilder.builder(%{name: 1, title: "user"})
  end

  test "use builder to get main_validator inside another module" do
    defmodule GuardedStructTest.AnotherMainModule do
      def main_validator(value) do
        {:ok, value}
      end
    end

    defmodule TestStructAnotherMainValidatorBuilder do
      alias GuardedStructTest.AnotherMainModule
      use GuardedStruct

      guardedstruct main_validator: {AnotherMainModule, :main_validator} do
        field(:name, String.t(), enforce: true)
        field(:title, String.t())
      end
    end

    {:ok, _data} =
      assert TestStructAnotherMainValidatorBuilder.builder(%{name: "mishka", title: "org"})
  end

  test "use builder to Sanitize - derive: sanitize(trim, lowercase)" do
    defmodule TestStructWithSanitizeDerive do
      use GuardedStruct

      guardedstruct do
        field(:name, String.t(), enforce: true, derive: "sanitize(trim, upcase)")
        field(:title, String.t(), derive: "sanitize(capitalize)")
      end
    end

    {:ok, data} = TestStructWithSanitizeDerive.builder(%{name: " mishka ", title: "org"})
    "MISHKA" = assert data.name
    "Org" = assert data.title
  end

  test "use builder to Validation" do
    defmodule TestStructWithValidationDerive do
      use GuardedStruct

      guardedstruct do
        field(:name, String.t(), enforce: true, derive: "validate(not_empty)")
        field(:title, String.t(), derive: "validate(not_empty, time)")
      end
    end

    {:error, :bad_parameters,
     [
       %{message: :not_empty, action: :name},
       %{message: :time, action: :title},
       %{message: :not_empty, action: :title}
     ]} = assert TestStructWithValidationDerive.builder(%{name: "", title: ""})

    defmodule TestStructWithValidationDerive1 do
      use GuardedStruct

      guardedstruct do
        field(:name, String.t(), enforce: true, derive: "validate(not_empty)")
        field(:title, String.t(), derive: "validate(not_empty)")
      end
    end

    {:ok, _data} =
      assert TestStructWithValidationDerive1.builder(%{name: "mishka", title: "group"})
  end

  test "use builder to Sanitize and Validation" do
    defmodule TestStructWithValidationAndValidationDerive do
      use GuardedStruct

      guardedstruct do
        field(:name, String.t(),
          enforce: true,
          derive: "sanitize(trim, upcase) validate(not_empty)"
        )

        field(:title, String.t(), derive: "validate(not_empty)")
      end
    end

    {:ok, data} =
      TestStructWithValidationAndValidationDerive.builder(%{name: " mishka ", title: "org"})

    "MISHKA" = assert data.name

    {:error, :bad_parameters, [%{message: :not_empty, action: :title}]} =
      assert TestStructWithValidationAndValidationDerive.builder(%{name: " mishka ", title: ""})
  end

  test "use builder to Derive and field validator" do
    defmodule TestStructBuilderWithValidationDeriveAndFieldValidator do
      use GuardedStruct

      guardedstruct do
        field(:name, String.t(),
          enforce: true,
          derive: "sanitize(trim, upcase) validate(not_empty)"
        )

        field(:title, String.t(), derive: "sanitize(trim, capitalize) validate(not_empty)")
      end

      def validator(:name, value) do
        if is_binary(value), do: {:ok, :name, "Mishka   "}, else: {:error, :name, "No, never"}
      end

      def validator(name, value) do
        {:ok, name, value}
      end
    end

    {:ok, data} =
      TestStructBuilderWithValidationDeriveAndFieldValidator.builder(%{
        name: "fake_mishka",
        title: "  org"
      })

    "MISHKA" = assert data.name
    "Org" = assert data.title

    {:error, :bad_parameters, [%{message: "No, never", action: :name}]} =
      assert TestStructBuilderWithValidationDeriveAndFieldValidator.builder(%{
               name: 1,
               title: "  org"
             })
  end

  test "use builder to Derive and main validator" do
    defmodule TestStructBuilderWithValidationDeriveAndMainValidator do
      use GuardedStruct

      guardedstruct do
        field(:name, String.t(),
          enforce: true,
          derive: "sanitize(trim, upcase) validate(not_empty)"
        )

        field(:title, String.t(), derive: "sanitize(trim, capitalize) validate(not_empty)")
      end

      def main_validator(value) do
        {:ok, Map.merge(value, %{title: "    Group"})}
      end
    end

    {:ok, data} =
      TestStructBuilderWithValidationDeriveAndMainValidator.builder(%{
        name: "mishka",
        title: "  org"
      })

    "MISHKA" = assert data.name
    "Group" = assert data.title
  end

  test "use builder to Derive and both validator" do
    defmodule TestStructBuilderWithValidationDeriveAndBothValidator do
      use GuardedStruct

      guardedstruct do
        field(:name, String.t(),
          enforce: true,
          derive: "sanitize(trim, upcase) validate(not_empty)"
        )

        field(:title, String.t(), derive: "sanitize(trim, capitalize) validate(not_empty)")
        field(:nickname, String.t(), derive: "validate(not_empty, time)")
      end

      def validator(:name, value) do
        if is_binary(value), do: {:ok, :name, "Mishka   "}, else: {:error, :name, "No, never"}
      end

      def validator(name, value) do
        {:ok, name, value}
      end

      def main_validator(value) do
        {:ok, Map.merge(value, %{title: "    Group"})}
      end
    end

    {:ok, data} =
      TestStructBuilderWithValidationDeriveAndBothValidator.builder(%{
        name: "fake_mishka",
        title: "  org"
      })

    "MISHKA" = assert data.name
    "Group" = assert data.title

    {:error, :bad_parameters,
     [
       %{message: :time, action: :nickname},
       %{message: :not_empty, action: :nickname}
     ]} =
      assert TestStructBuilderWithValidationDeriveAndBothValidator.builder(%{
               name: "fake_mishka",
               nickname: ""
             })
  end

  ############## (▰˘◡˘▰) GuardedStructTest Tests helper functions (▰˘◡˘▰) ##############
  # Extracts the first type from a module.
  defp types(bytecode) do
    bytecode
    |> Code.Typespec.fetch_types()
    |> elem(1)
    |> Enum.sort()
  end

  # Sample fields
  # [
  #   {:type, _, :map_field_exact, _},
  #   {:type, _, _, [{:atom, _, :int}, _]},
  #   {:type, _, _, [{:atom, _, :mandatory_int}, _]},
  #   {:type, _, _, [{:atom, _, :string}, _]},
  #   {:type, _, _, [{:atom, _, :string_with_default}, _]}
  # ]

  defp check_type(type, bytecode, fields, struct_type \\ :type)

  defp check_type(:t, bytecode, fields, :type) do
    [type: {:t, {:type, _, :map, list}, []}] = types(bytecode)

    all_allowed_fields_exist?(list, fields)
  end

  defp check_type(:t, bytecode, fields, :opaque) do
    [opaque: {:t, {:type, _, :map, list}, []}] = types(bytecode)

    all_allowed_fields_exist?(list, fields)
  end

  defp all_allowed_fields_exist?(list, fields) do
    get_fields =
      list
      |> Enum.filter(fn {:type, _, _, [{:atom, _, f}, _]} -> Enum.member?(fields, f) end)
      |> Enum.map(fn {:type, _, _, [{:atom, _, f}, _]} -> f end)
      |> Enum.sort()

    Enum.sort(fields) == get_fields
  end
end