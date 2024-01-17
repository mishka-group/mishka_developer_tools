# TODO: these tests needs to re-check
# test validate(:url, input, field) - 3393.6ms
# test validate(:email, input, field) - 1646.2ms
# test validate(:email, input, field) - 1646.2ms
# test validate({:tell, country_code}, input, field) -> country_code - 49.4ms
defmodule MishkaDeveloperToolsTest.GuardedStruct.GlobalTest do
  use ExUnit.Case, async: true
  alias MishkaDeveloperTools.Helper.Derive.ValidationDerive

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

  defmodule TestNestedStruct do
    use GuardedStruct

    guardedstruct do
      field(:name, String.t(),
        derive:
          "sanitize(strip_tags, trim, capitalize) validate(string, not_empty, max_len=20, min_len=3)"
      )

      field(:family, String.t(),
        derive:
          "sanitize(basic_html, trim, capitalize) validate(string, not_empty, max_len=20, min_len=3)"
      )

      field(:age, integer(), enforce: true, derive: "validate(integer, max_len=110, min_len=18)")

      sub_field(:auth, struct(), enforce: true) do
        field(:server, String.t(), derive: "validate(regex='^[a-zA-Z]+@mishka\.group$')")

        field(:identity_provider, String.t(),
          derive: "sanitize(strip_tags, trim, lowercase) validate(not_empty)"
        )

        sub_field(:role, struct(), enforce: true) do
          field(:name, String.t(),
            derive:
              "sanitize(strip_tags, trim, lowercase) validate(enum=Atom[admin::user::banned])"
          )

          field(:action, String.t(), derive: "validate(string_boolean)")

          field(:status, String.t(),
            derive: "validate(enum=Map[%{status: 1}::%{status: 2}::%{status: 3}])"
          )
        end

        field(:last_activity, String.t(), derive: "sanitize(strip_tags, trim) validate(datetime)")
      end

      sub_field(:profile, struct()) do
        field(:site, String.t(), derive: "validate(url)")

        field(:nickname, String.t(), validator: {TestNestedStruct, :validator})
      end

      field(:username, String.t(),
        enforce: true,
        derive: "sanitize(tag=strip_tags) validate(not_empty, max_len=20, min_len=3)"
      )
    end

    def validator(:nickname, value) do
      if is_binary(value),
        do: {:ok, :nickname, value},
        else: {:error, :nickname, "Invalid nickname"}
    end

    def validator(field, value) do
      {:ok, field, value}
    end
  end

  defmodule TestAutoValueStruct do
    use GuardedStruct

    guardedstruct do
      field(:username, String.t(), derive: "validate(not_empty)")
      field(:user_id, String.t(), auto: {Ecto.UUID, :generate})
      field(:parent_id, String.t(), auto: {Ecto.UUID, :generate})

      sub_field(:profile, struct()) do
        field(:id, String.t(), auto: {Ecto.UUID, :generate})
        field(:nickname, String.t(), derive: "validate(not_empty)")

        sub_field(:social, struct()) do
          field(:id, String.t(), auto: {TestAutoValueStruct, :create_uuid, "test-path"})
          field(:skype, String.t(), derive: "validate(string)")
          field(:username, String.t(), from: "root::username")
        end
      end

      sub_field(:items, struct(), structs: true) do
        field(:id, String.t(), auto: {Ecto.UUID, :generate})
        field(:something, String.t(), derive: "validate(string)", from: "root::username")
      end
    end

    def create_uuid(default) do
      Ecto.UUID.generate() <> "-#{default}"
    end
  end

  defmodule TestOnValueStruct do
    use GuardedStruct

    guardedstruct do
      field(:name, String.t(), derive: "validate(string)")

      sub_field(:profile, struct()) do
        field(:id, String.t(), auto: {Ecto.UUID, :generate})
        field(:nickname, String.t(), on: "root::name", derive: "validate(string)")
        field(:github, String.t(), derive: "validate(string)")

        sub_field(:identity, struct()) do
          field(:provider, String.t(), on: "root::profile::github", derive: "validate(string)")
          field(:id, String.t(), auto: {Ecto.UUID, :generate})
          field(:rel, String.t(), on: "sub_identity::auth_path::action")

          sub_field(:sub_identity, struct()) do
            field(:id, String.t(), auto: {Ecto.UUID, :generate})
            field(:auth_path, struct(), struct: TestAuthStruct)
          end
        end
      end

      sub_field(:last_activity, list(struct()), structs: true) do
        field(:action, String.t(), enforce: true, derive: "validate(string)", on: "root::name")
      end
    end
  end

  ############# (▰˘◡˘▰) GlobalTest GuardedStructTest Tests (▰˘◡˘▰) ##############
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

  test "nested macro field" do
    [:username, :profile, :auth, :age, :family, :name] = assert TestNestedStruct.keys()
    [:username, :auth, :age] = assert TestNestedStruct.enforce_keys()

    {:error,
     %{
       message: "Please submit required fields.",
       fields: [:username, :auth, :age],
       action: :required_fields
     }} = assert TestNestedStruct.builder(%{})

    {:ok,
     %__MODULE__.TestNestedStruct{
       username: "Mishka",
       profile: %__MODULE__.TestNestedStruct.Profile{
         nickname: "mishka",
         site: "https://elixir-lang.org"
       },
       auth: %__MODULE__.TestNestedStruct.Auth{
         last_activity: "2023-08-20 16:54:07.841434Z",
         role: %__MODULE__.TestNestedStruct.Auth.Role{
           action: "true",
           name: :user,
           status: %{status: 2}
         },
         identity_provider: "google",
         server: "users@mishka.group"
       },
       age: 18,
       family: "Group",
       name: "Mishka"
     }} =
      assert TestNestedStruct.builder(%{
               username: " <p>Mishka   </p>",
               auth: %{
                 server: "users@mishka.group",
                 identity_provider: "google",
                 role: %{
                   name: :user,
                   action: "true",
                   status: %{status: 2}
                 },
                 last_activity: "2023-08-20 16:54:07.841434Z"
               },
               age: 18,
               family: "group",
               name: "mishka",
               profile: %{
                 site: "https://elixir-lang.org",
                 nickname: "mishka"
               }
             })

    {:error,
     [
       %{field: :profile, errors: [%{message: "Invalid nickname", field: :nickname}]},
       %{
         field: :auth,
         errors: [
           %{
             message: "Invalid DateTime format in the last_activity field",
             field: :last_activity,
             action: :datetime
           },
           %{
             field: :role,
             errors: [
               %{
                 message: "Invalid boolean format in the action field",
                 field: :action,
                 action: :string_boolean
               }
             ]
           }
         ]
       }
     ]} =
      assert TestNestedStruct.builder(%{
               username: "mishka",
               auth: %{
                 server: "users@mishka.group",
                 identity_provider: "google",
                 role: %{
                   name: :admin,
                   action: "test",
                   status: %{status: 2}
                 },
                 last_activity: "20213-08-20 16:54:07.841434Z"
               },
               age: 18,
               family: "group",
               name: "mishka",
               profile: %{
                 site: "https://elixir-lang.org",
                 nickname: :test
               }
             })
  end

  test "call nested keys with :all" do
    defmodule TestCallNestedKeys do
      use GuardedStruct

      guardedstruct do
        field(:name, String.t(), enforce: true, derive: "sanitize(trim, upcase)")
        field(:title, String.t(), derive: "sanitize(trim, capitalize) validate(not_empty)")
        field(:nickname, String.t(), derive: "validate(not_empty, time)")

        sub_field(:auth, struct(), enforce: true) do
          field(:role, String.t(), derive: "validate(enum=Atom[admin, user])")
          field(:action, String.t(), derive: "validate(not_empty)")

          sub_field(:path, struct()) do
            field(:name, String.t())
            field(:mobile, String.t())
          end
        end
      end
    end

    [%{auth: [%{path: [:mobile, :name]}, :action, :role]}, :nickname, :title, :name] =
      assert TestCallNestedKeys.keys(:all)

    [%{auth: [%{path: [:mobile, :name]}, :action, :role]}, :name] =
      assert TestCallNestedKeys.enforce_keys(:all)
  end

  test "call nested struct with error true" do
    defmodule TestCallNestedStructWithError do
      use GuardedStruct

      guardedstruct error: true do
        field(:name, String.t(), derive: "validate(string)")

        sub_field(:auth, struct(), error: true) do
          field(:action, String.t(), derive: "validate(not_empty)")

          sub_field(:path, struct(), error: true) do
            field(:name, String.t())
          end
        end
      end
    end

    assert_raise TestCallNestedStructWithError.Error, fn ->
      TestCallNestedStructWithError.builder(%{name: 1}, true)
    end
  end

  test "test Only authorized data" do
    defmodule TestAuthorizeKeys do
      use GuardedStruct

      guardedstruct authorized_fields: true do
        field(:name, String.t(), derive: "validate(string)")

        sub_field(:auth, struct(), authorized_fields: true) do
          field(:action, String.t(), derive: "validate(not_empty)")

          sub_field(:path, struct()) do
            field(:name, String.t())
          end
        end
      end
    end

    {:error,
     %{
       message: "Unauthorized keys are present in the sent data.",
       fields: [:test],
       action: :authorized_fields
     }} =
      assert TestAuthorizeKeys.builder(%{name: "Shahryar", test: "test"})

    {:error,
     [
       %{
         field: :auth,
         errors: %{
           message: "Unauthorized keys are present in the sent data.",
           fields: [:test],
           action: :authorized_fields
         }
       }
     ]} =
      assert TestAuthorizeKeys.builder(%{name: "Shahryar", auth: %{action: "admin", test: "test"}})
  end

  test "auto generate value nested and root map" do
    {:ok,
     %__MODULE__.TestAutoValueStruct{
       profile: %__MODULE__.TestAutoValueStruct.Profile{
         social: %__MODULE__.TestAutoValueStruct.Profile.Social{
           skype: "mishka_skype",
           id: social_UUID,
           username: "mishka"
         },
         nickname: "Mishka",
         id: profile_UUID
       },
       user_id: user_UUID,
       username: "mishka",
       parent_id: _parent_id
     }} =
      TestAutoValueStruct.builder(%{
        username: "mishka",
        user_id: "test_to_be_replaced",
        profile: %{nickname: "Mishka", social: %{skype: "mishka_skype", username: "none_to_test"}}
      })

    assert String.contains?(social_UUID, "test-path")

    assert ValidationDerive.validate(:uuid, profile_UUID, :test)
           |> is_binary()

    assert ValidationDerive.validate(:uuid, user_UUID, :test)
           |> is_binary()

    assert social_UUID != profile_UUID != user_UUID

    {:ok,
     %__MODULE__.TestAutoValueStruct{
       parent_id: _edit_parent_id,
       user_id: "test_not_to_be_replaced"
     }} =
      assert TestAutoValueStruct.builder(
               {:root,
                %{
                  username: "mishka",
                  user_id: "test_not_to_be_replaced"
                }, :edit}
             )
  end

  test "call on value in a nested struct and extra module" do
    {:ok,
     %__MODULE__.TestOnValueStruct{
       profile: %__MODULE__.TestOnValueStruct.Profile{
         identity: %__MODULE__.TestOnValueStruct.Profile.Identity{
           id: id1,
           provider: "git",
           sub_identity: %{id: _id}
         },
         github: "test",
         nickname: "Mishka",
         id: id2
       },
       name: "mishka"
     }} =
      assert TestOnValueStruct.builder(%{
               name: "mishka",
               profile: %{
                 nickname: "Mishka",
                 github: "test",
                 identity: %{
                   provider: "git",
                   sub_identity: %{id: "test", auth_path: %{action: "admin/edit"}}
                 }
               }
             })

    assert id1 != id2
    assert !is_nil(id1)
    assert !is_nil(id1)

    {:error,
     [
       %{
         field: :profile,
         errors: [
           %{
             field: :identity,
             errors: [
               %{
                 message:
                   "The required dependency for field provider has not been submitted.\nYou must have field github in your input\n",
                 field: :provider,
                 action: :dependent_keys
               }
             ]
           }
         ]
       }
     ]} =
      assert TestOnValueStruct.builder(%{
               name: "mishka",
               profile: %{
                 nickname: "Mishka",
                 identity: %{provider: "git"}
               }
             })
  end

  test "check list struct depend on a key in another struct" do
    {:ok,
     %__MODULE__.TestOnValueStruct{
       last_activity: [
         %__MODULE__.TestOnValueStruct.LastActivity{
           action: "login"
         },
         %__MODULE__.TestOnValueStruct.LastActivity{
           action: "logout"
         }
       ],
       profile: nil,
       name: "mishka"
     }} =
      assert TestOnValueStruct.builder(%{
               name: "mishka",
               last_activity: [%{action: "login"}, %{action: "logout"}]
             })
  end

  test "call from value in a nested struct and extra module" do
    {:ok,
     %__MODULE__.TestAutoValueStruct{
       profile: %__MODULE__.TestAutoValueStruct.Profile{
         social: %__MODULE__.TestAutoValueStruct.Profile.Social{
           username: "user_mishka"
         }
       }
     }} =
      assert TestAutoValueStruct.builder(%{
               username: "user_mishka",
               user_id: "test_to_be_replaced",
               profile: %{
                 nickname: "Mishka",
                 social: %{skype: "mishka_skype", username: "none_to_test"}
               }
             })

    {:ok,
     %__MODULE__.TestAutoValueStruct{
       profile: %__MODULE__.TestAutoValueStruct.Profile{
         social: %__MODULE__.TestAutoValueStruct.Profile.Social{
           username: "user_mishka"
         }
       }
     }} =
      assert TestAutoValueStruct.builder(%{
               username: "user_mishka",
               user_id: "test_to_be_replaced",
               profile: %{nickname: "Mishka", social: %{skype: "mishka_skype"}}
             })
  end

  test "check list struct from a key in another struct" do
    {:ok,
     %__MODULE__.TestAutoValueStruct{
       items: [
         %__MODULE__.TestAutoValueStruct.Items{
           something: "mishka",
           id: _
         },
         %__MODULE__.TestAutoValueStruct.Items{
           something: "mishka",
           id: _
         },
         %__MODULE__.TestAutoValueStruct.Items{
           something: "mishka",
           id: _
         }
       ],
       profile: nil,
       parent_id: _,
       user_id: _,
       username: "mishka"
     }} =
      assert TestAutoValueStruct.builder(%{
               username: "mishka",
               items: [
                 %{id: "test", something: "test"},
                 %{something: "test"},
                 %{}
               ]
             })
  end
end
