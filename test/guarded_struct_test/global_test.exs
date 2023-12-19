# TODO: these tests needs to re-check
# test validate(:url, input, field) - 3393.6ms
# test validate(:email, input, field) - 1646.2ms
# test validate(:email, input, field) - 1646.2ms
# test validate({:tell, country_code}, input, field) -> country_code - 49.4ms
defmodule MishkaDeveloperToolsTest.GuardedStruct.GlobalTest do
  use ExUnit.Case, async: true

  ############# (▰˘◡˘▰) GlobalTest GuardedStructTest Data (▰˘◡˘▰) ##############
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

  test "nested string map to atom with derive and validation" do
    {:ok,
     %MishkaDeveloperToolsTest.GuardedStruct.GlobalTest.TestUserAuthStruct{
       profile: nil,
       auth_path: [
         %{path: %{role: "1"}, action: "*:admin"},
         %{path: %{role: "3"}, action: "*:user"}
       ],
       name: "mishka"
     }} =
      assert TestUserAuthStruct.builder(%{
               "name" => "mishka",
               "auth_path" => [
                 %{"action" => "*:admin", "path" => %{"role" => "1"}},
                 %{"action" => "*:user", "path" => %{"role" => "3"}}
               ]
             })
  end
end
