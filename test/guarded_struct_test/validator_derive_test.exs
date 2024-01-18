defmodule MishkaDeveloperToolsTest.GuardedStruct.ValidatorDeriveTest do
  use ExUnit.Case, async: true

  ############# (▰˘◡˘▰) ValidatorDeriveTest GuardedStructTest Data (▰˘◡˘▰) ##############
  defmodule TestAuthStruct do
    use GuardedStruct

    guardedstruct do
      field(:action, String.t(), derive: "validate(not_empty)")

      sub_field(:path, struct(), main_validator: {TestAuthStruct, :main_validator}) do
        field(:role, String.t(), validator: {TestAuthStruct, :validator})
        field(:custom_path, String.t(), derive: "validate(not_empty)")

        sub_field(:rel, struct()) do
          field(:social, String.t(), derive: "validate(not_empty)")
        end
      end

      field(:changed, String.t(),
        derive: "validate(not_empty)",
        validator: {__MODULE__, :test_validator}
      )
    end

    def test_validator(:changed, value) do
      if is_binary(value),
        do: {:ok, :changed, value <> "::Changed"},
        else: {:error, :changed, "No, never"}
    end

    def validator(:role, value) do
      if is_binary(value), do: {:ok, :role, value}, else: {:error, :role, "No, never"}
    end

    def validator(field, value) do
      {:ok, field, value}
    end

    def main_validator(value) do
      {:ok, value}
    end
  end

  defmodule TestUserAuthStruct do
    use GuardedStruct

    guardedstruct do
      field(:name, String.t(), derive: "validate(not_empty)")
      field(:auth_path, struct(), structs: TestAuthStruct)

      sub_field(:profile, list(struct()), structs: true) do
        field(:github, String.t(), enforce: true, derive: "validate(url)")
        field(:nickname, String.t(), derive: "validate(not_empty)")
      end
    end

    def validator(:name, value) do
      if is_binary(value), do: {:ok, :name, value}, else: {:error, :name, "No, never"}
    end

    def validator(field, value) do
      {:ok, field, value}
    end
  end

  ############# (▰˘◡˘▰) ValidatorDeriveTest GuardedStructTest Tests (▰˘◡˘▰) ##############
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

    {:error, [%{message: _msg, field: :name}]} =
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

    {:error, [%{message: _msg, field: :name}]} =
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

  test "use builder to Validation and Lack of validation" do
    defmodule TestStructWithValidationDerive do
      use GuardedStruct

      guardedstruct do
        field(:name, String.t(), enforce: true, derive: "validate(not_empty)")
        field(:title, String.t(), derive: "validate(not_empty, time)")
      end
    end

    {:error,
     [
       %{message: _msg1, field: :name, action: :not_empty},
       %{message: _msg2, field: :title, action: :type},
       %{message: _msg3, field: :title, action: :not_empty}
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

    {:error, [%{message: "The title field must not be empty", field: :title, action: :not_empty}]} =
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

    {:error, [%{message: "No, never", field: :name}]} =
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

  test "use builder to Derive and both validator and Lack of validation" do
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

    {:error,
     [
       %{message: _msg1, field: :nickname, action: :type},
       %{message: _msg2, field: :nickname, action: :not_empty}
     ]} =
      assert TestStructBuilderWithValidationDeriveAndBothValidator.builder(%{
               name: "fake_mishka",
               nickname: ""
             })
  end

  test "Call struct from another module with validator, derive and main_validator and list attrs" do
    {:ok, _nested_struct} =
      assert TestUserAuthStruct.builder(%{
               name: "mishka",
               auth_path: [
                 %{action: "*:admin", path: %{role: "1"}},
                 %{action: "*:user", path: %{role: "3"}}
               ]
             })

    {:error,
     [
       %{
         field: :auth_path,
         errors: [%{field: :path, errors: [%{message: "No, never", field: :role}]}]
       }
     ]} =
      assert TestUserAuthStruct.builder(%{
               name: "mishka",
               auth_path: [
                 %{action: "*:admin", path: %{role: 1}},
                 %{action: "*:user", path: %{role: "3"}}
               ]
             })

    {:error,
     [
       %{
         field: :auth_path,
         errors: [%{field: :path, errors: [%{message: "No, never", field: :role}]}]
       }
     ]} =
      assert TestUserAuthStruct.builder(%{
               name: "mishka",
               auth_path: [
                 %{action: "*:user", path: %{role: 2, custom_path: "/user"}},
                 %{action: "*:admin", path: %{role: "2"}}
               ]
             })
  end

  test "Call sub_field struct with list attrs and validator, derive and main_validator" do
    {:error,
     [
       %{
         field: :profile,
         errors: %{
           message: "Please submit required fields.",
           fields: [:github],
           action: :required_fields
         }
       }
     ]} =
      assert TestUserAuthStruct.builder(%{
               name: "mishka",
               auth_path: [
                 %{action: "*:admin", path: %{role: "1", rel: %{social: "github"}}},
                 %{action: "*:user", path: %{role: "3", rel: %{social: "github"}}}
               ],
               profile: [%{nickname: "mishka"}, %{nickname: "mishka1"}]
             })

    {:ok, _nested_struct} =
      assert TestUserAuthStruct.builder(%{
               name: "mishka",
               auth_path: [
                 %{action: "*:admin", path: %{role: "1"}},
                 %{action: "*:user", path: %{role: "3", rel: %{social: "github"}}}
               ],
               profile: [%{github: "https://github.com/mishka-group"}]
             })
  end

  test "custom change data in true state" do
    {:error, [%{message: "No, never", field: :changed, action: :validator}]} =
      TestAuthStruct.builder(%{changed: 1})

    {:ok,
     %MishkaDeveloperToolsTest.GuardedStruct.ValidatorDeriveTest.TestAuthStruct{
       changed: "https://github.com/mishka-group::Changed",
       path: nil,
       action: nil
     }} =
      TestAuthStruct.builder(%{changed: "https://github.com/mishka-group"})
  end
end
