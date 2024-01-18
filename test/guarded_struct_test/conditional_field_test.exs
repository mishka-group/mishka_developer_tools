defmodule MishkaDeveloperToolsTest.GuardedStruct.ConditionalFieldTest do
  use ExUnit.Case, async: true

  ############# (▰˘◡˘▰) ConditionalFieldTest GuardedStructTest Data (▰˘◡˘▰) ##############
  # TODO: We need to support derive and validator on conditional field macro, as like children
  defmodule ExtrenalConditional do
    use GuardedStruct

    guardedstruct do
      field(:post_id, integer(), derive: "validate(integer)")
      field(:like, boolean(), enforce: true)
    end
  end

  defmodule ConditionalProfileFieldStructs do
    use GuardedStruct
    alias ConditionalFieldValidatorTestValidators, as: VAL

    guardedstruct do
      field(:nickname, String.t())

      # For domain
      sub_field(:identity, struct()) do
        field(:action, String.t())
        field(:type, String.t())
      end

      conditional_field(:social, any()) do
        sub_field(:social, struct(), hint: "social1", validator: {VAL, :is_map_data}) do
          field(:address, String.t(), enforce: true)
          field(:provider, String.t(), enforce: true)
        end

        field(:social, String.t(), hint: "social2", validator: {VAL, :is_string_data})
      end

      conditional_field(:location, any()) do
        sub_field(:location, struct(), validator: {VAL, :is_map_data}, hint: "location1") do
          field(:address, String.t())

          field(:city, String.t(),
            enforce: true,
            derive: "sanitize(trim) validate(string, not_empty)"
          )
        end

        field(:location, String.t(),
          validator: {VAL, :is_string_data},
          derive: "sanitize(trim) validate(string, location)",
          hint: "location2"
        )
      end

      conditional_field(:auth, any()) do
        sub_field(:auth, struct(), hint: "auth1", structs: true, validator: {VAL, :is_list_data}) do
          field(:username, String.t(), enforce: true)
          field(:provider, String.t(), enforce: true)
        end

        sub_field(:auth, struct(), hint: "auth2", structs: true) do
          field(:username, String.t(), enforce: true)
          field(:provider, String.t(), enforce: true)
        end

        field(:auth, String.t(), hint: "auth3", validator: {VAL, :is_string_data})
      end

      conditional_field(:auth2, any()) do
        sub_field(:auth2, struct(),
          hint: "auth1",
          structs: true,
          validator: {VAL, :is_list_data},
          derive: "validate(not_flatten_empty_item)"
        ) do
          field(:username, String.t(), enforce: true)
          field(:provider, String.t(), enforce: true)
        end

        field(:auth2, String.t(), hint: "auth3", validator: {VAL, :is_string_data})
      end

      conditional_field(:post_activity, any()) do
        field(:post_activity, struct(), struct: ExtrenalConditional, hint: "post_activity1")

        field(:post_activity, String.t(),
          hint: "post_activity2",
          validator: {VAL, :is_string_data}
        )
      end

      conditional_field(:post_activities, any(), default: []) do
        field(:post_activities, struct(), structs: ExtrenalConditional, hint: "post_activities1")

        field(:post_activities, String.t(),
          hint: "post_activities2",
          validator: {VAL, :is_list_data}
        )
      end

      conditional_field(:author, any()) do
        sub_field(:author, struct(), enforce: true, validator: {VAL, :is_map_data}) do
          field(:name, String.t())
          field(:family, String.t())
        end

        field(:author, String.t(), validator: {VAL, :is_string_data})
      end

      conditional_field(:information, any(), domain: "?identity.type=Atom[female]") do
        sub_field(:information, struct(), validator: {VAL, :is_map_data}) do
          field(:name, String.t())

          field(:gender, String.t(), domain: "!identity.action=String[admin, user]")
        end

        field(:information, String.t(), validator: {VAL, :is_string_data})
      end

      # On core key has strict error, it should support !, ? as optional stuff
      field(:sub_identity, String.t(), on: "root::nickname")

      field(:second_username, String.t(), from: "root::information::name")

      field(:record_id, String.t(), auto: {Ecto.UUID, :generate})

      conditional_field(:profile, any(), priority: true) do
        field(:profile, String.t(), hint: "profile1", validator: {VAL, :is_string_data})

        sub_field(:profile, struct(), hint: "profile2", validator: {VAL, :is_map_data}) do
          field(:name, String.t(), enforce: true, derive: "validate(not_empty)")
          field(:family, String.t(), enforce: true, derive: "validate(not_empty)")
        end
      end

      conditional_field(:activity, any()) do
        field(:activity, struct(),
          structs: ExtrenalConditional,
          hint: "activity1",
          validator: {VAL, :is_list_data}
        )

        field(:activity, String.t(),
          hint: "activity2",
          validator: {VAL, :is_string_data}
        )
      end

      conditional_field(:address, any(), structs: true) do
        sub_field(:address, struct(),
          derive: "sanitize(trim, upcase)",
          validator: {VAL, :is_map_data},
          hint: "address1"
        ) do
          field(:lat, String.t(), enforce: true)
          field(:lan, String.t(), enforce: true)
        end

        field(:address, String.t(),
          derive: "sanitize(trim) validate(not_empty)",
          hint: "address2",
          validator: {VAL, :is_string_data}
        )
      end

      conditional_field(:extera_auth, any(), structs: true) do
        sub_field(:extera_auth, struct(), validator: {VAL, :is_map_data}) do
          field(:username, String.t(),
            enforce: true,
            validator: {VAL, :is_string_data},
            derive: "sanitize(trim) validate(string)"
          )

          field(:provider, String.t(), enforce: true)
        end

        field(:extera_auth, String.t(), derive: "sanitize(trim) validate(string, not_empty)")
      end

      conditional_field(:extera_auth2, any(), structs: true) do
        sub_field(:extera_auth2, struct(), validator: {VAL, :is_map_data}, hint: "extera_auth1") do
          field(:username, String.t(),
            enforce: true,
            validator: {VAL, :is_string_data},
            derive: "sanitize(trim) validate(string)"
          )

          field(:provider, String.t(), enforce: true)
        end

        field(:extera_auth2, String.t(),
          derive: "sanitize(trim) validate(string, not_empty)",
          hint: "extera_auth2",
          validator: {VAL, :is_string_data}
        )
      end

      conditional_field(:activities, any(), structs: true) do
        field(:activities, struct(),
          struct: ExtrenalConditional,
          validator: {VAL, :is_map_data},
          hint: "activities1"
        )

        field(:activities, struct(),
          structs: ExtrenalConditional,
          validator: {VAL, :is_list_data},
          hint: "activities2"
        )

        field(:activities, String.t(),
          hint: "activities3",
          validator: {VAL, :is_string_data}
        )
      end

      conditional_field(:activities2, any(), structs: true) do
        field(:activities2, struct(),
          struct: ExtrenalConditional,
          validator: {VAL, :is_map_data},
          hint: "activities1"
        )

        sub_field(:activities2, struct(),
          structs: true,
          validator: {VAL, :is_list_data},
          hint: "activities2"
        ) do
          field(:role, String.t(),
            enforce: true,
            derive: "sanitize(trim) validate(string, not_empty)"
          )

          field(:action, String.t(), enforce: true)
        end

        field(:activities2, String.t(),
          hint: "activities3",
          validator: {VAL, :is_string_data}
        )
      end

      conditional_field(:activities3, any(), structs: true, priority: true) do
        field(:activities3, struct(),
          struct: ExtrenalConditional,
          validator: {VAL, :is_map_data},
          hint: "activities1"
        )

        sub_field(:activities3, struct(),
          structs: true,
          validator: {VAL, :is_flat_list_data},
          hint: "activities2",
          derive: "validate(not_flatten_empty_item)"
        ) do
          field(:role, String.t(),
            enforce: true,
            derive: "sanitize(trim) validate(string, not_empty)"
          )

          field(:action, String.t(), enforce: true)
        end

        field(:activities3, String.t(),
          hint: "activities3",
          validator: {VAL, :is_string_data}
        )
      end

      conditional_field(:author2, any(), structs: true) do
        sub_field(:author2, struct(), enforce: true, validator: {VAL, :is_map_data}) do
          field(:name, String.t())
          field(:family, String.t())
        end

        field(:author2, String.t(), validator: {VAL, :is_string_data})
      end

      conditional_field(:author3, any(), structs: true) do
        sub_field(:author3, struct(), validator: {VAL, :is_map_data}, hint: "author1") do
          field(:name, String.t())
          field(:family, String.t(), enforce: true)
        end

        sub_field(:author3, struct(),
          structs: true,
          enforce: true,
          validator: {VAL, :is_flat_list_data},
          derive: "validate(not_flatten_empty_item)",
          hint: "author2"
        ) do
          field(:name, String.t())
          field(:family, String.t())
        end

        field(:author3, String.t(), validator: {VAL, :is_string_data}, hint: "author3")
      end

      conditional_field(:information2, any(),
        structs: true,
        domain: "?identity.type=Atom[female]"
      ) do
        sub_field(:information2, struct(), validator: {VAL, :is_map_data}, hint: "information1") do
          field(:name, String.t())
          field(:gender, String.t(), domain: "!identity.action=String[admin, user]")
        end

        sub_field(:information2, struct(),
          validator: {VAL, :is_flat_list_data},
          hint: "information2"
        ) do
          field(:name, String.t())
          field(:gender, String.t(), domain: "!identity.action=String[admin, user]")
        end

        field(:information2, String.t(), validator: {VAL, :is_string_data}, hint: "information3")
      end

      field(:sub_field_on_header, String.t())

      conditional_field(:activity3, any()) do
        sub_field(:activity3, struct(),
          on: "root::nickname",
          validator: {VAL, :is_map_data},
          hint: "activity3"
        ) do
          field(:action, String.t())
          field(:type, String.t(), on: "root::sub_field_on_header")
        end

        field(:activity3, String.t(),
          validator: {VAL, :is_string_data},
          hint: "activity2"
        )
      end

      field(:from_test_field, String.t())

      conditional_field(:activity4, any(), structs: true, on: "root::list_sub_field_on_header") do
        sub_field(:activity4, struct(),
          on: "root::nickname",
          validator: {VAL, :is_map_data},
          hint: "activity3"
        ) do
          field(:action, String.t())
          field(:type, String.t(), on: "root::sub_field_on_header")
          field(:from_test, String.t(), from: "root::from_test_field")
          field(:auto_test, String.t(), auto: {Ecto.UUID, :generate})
        end

        field(:activity4, String.t(),
          validator: {VAL, :is_string_data},
          hint: "activity2"
        )
      end
    end
  end

  test "Conditional field as a map" do
    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       social: "https://github.com/mishka-group",
       nickname: "Mishka"
     }} =
      assert __MODULE__.ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               social: "https://github.com/mishka-group"
             })

    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       social: %__MODULE__.ConditionalProfileFieldStructs.Social1{
         provider: "github",
         address: "https://github.com/mishka-group"
       },
       nickname: "Mishka"
     }} =
      assert __MODULE__.ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               social: %{address: "https://github.com/mishka-group", provider: "github"}
             })
  end

  test "Conditional field as a map with validator" do
    {:error, %{message: "Your input must be a map or list of maps", action: :bad_parameters}} =
      assert __MODULE__.ConditionalProfileFieldStructs.builder([
               %{
                 nickname: "Mishka",
                 list_sub_field_on_header: "Mishka",
                 social: "https://github.com/mishka-group"
               }
             ])

    {:error,
     [
       %{
         field: :social,
         errors: [
           %{message: "It is not map", field: :social, action: :validator, __hint__: "social1"},
           %{message: "It is not string", field: :social, action: :validator, __hint__: "social2"}
         ],
         action: :conditionals
       }
     ]} =
      assert __MODULE__.ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               social: ["https://github.com/mishka-group"]
             })
  end

  test "Conditional field as a map with derive" do
    {:error,
     [
       %{
         field: :location,
         errors: [
           %{
             message: "It is not map",
             field: :location,
             action: :validator,
             __hint__: "location1"
           },
           %{
             message:
               "Invalid geo url format in the location field, you should send latitude and longitude",
             field: :location,
             action: :location,
             __hint__: "location2"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert __MODULE__.ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               location: "bad_location"
             })

    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       location: "48.198634,-16.371648,3.4;crs=wgs84;u=40.0",
       social: nil,
       nickname: "Mishka"
     }} =
      assert __MODULE__.ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               location: "48.198634,-16.371648,3.4;crs=wgs84;u=40.0"
             })
  end

  test "Conditional field as a map with list sub_field" do
    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       auth: [
         %__MODULE__.ConditionalProfileFieldStructs.Auth1{
           provider: "github",
           username: "Mishka"
         },
         %__MODULE__.ConditionalProfileFieldStructs.Auth1{
           provider: "google",
           username: "Mishka"
         },
         %__MODULE__.ConditionalProfileFieldStructs.Auth1{
           provider: "yahoo",
           username: "Mishka"
         }
       ],
       location: nil,
       social: nil,
       nickname: "Mishka"
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               auth: [
                 %{username: "Mishka", provider: "github"},
                 %{username: "Mishka", provider: "google"},
                 %{username: "Mishka", provider: "yahoo"}
               ]
             })

    {:error,
     [
       %{
         field: :auth,
         errors: [
           %{message: "It is not list", field: :auth, action: :validator, __hint__: "auth1"},
           %{
             message: "Your input must be a list of items",
             field: :auth,
             action: :type,
             __hint__: "auth2"
           },
           %{message: "It is not string", field: :auth, action: :validator, __hint__: "auth3"}
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               auth: %{username: "Mishka", provider: "github"}
             })

    {:error,
     [
       %{
         field: :auth2,
         errors: [
           %{
             message: "The auth2 field item must not be empty",
             field: :auth2,
             action: :not_flatten_empty_item,
             __hint__: "auth1"
           },
           %{message: "It is not string", field: :auth2, action: :validator, __hint__: "auth3"}
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               auth2: [
                 [],
                 %{username: "Mishka", provider: "github"},
                 %{username: "Mishka", provider: "google"},
                 %{username: "Mishka", provider: "yahoo"}
               ]
             })

    {:error,
     [
       %{
         field: :auth2,
         errors: [
           %{
             message: "Please submit required fields.",
             fields: [:provider, :username],
             action: :required_fields,
             __hint__: "auth1"
           },
           %{message: "It is not string", field: :auth2, action: :validator, __hint__: "auth3"}
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               auth2: [
                 [[]],
                 %{username: "Mishka", provider: "github"},
                 %{username: "Mishka", provider: "google"},
                 %{username: "Mishka", provider: "yahoo"}
               ]
             })
  end

  test "Conditional field as a map with external field" do
    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       post_activity: %__MODULE__.ExtrenalConditional{
         like: true,
         post_id: 1
       },
       nickname: "Mishka"
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               post_activity: %{post_id: 1, like: true}
             })

    {:error,
     [
       %{
         field: :post_activity,
         errors: [
           %{
             message: "Please submit required fields.",
             fields: [:like],
             action: :required_fields,
             __hint__: "post_activity1"
           },
           %{
             message: "It is not string",
             field: :post_activity,
             action: :validator,
             __hint__: "post_activity2"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               post_activity: %{post_id: 1, provider: true}
             })

    {:error,
     [
       %{
         field: :post_activity,
         errors: [
           %{
             message: "Your input must be a map or list of maps",
             action: :bad_parameters,
             __hint__: "post_activity1"
           },
           %{
             message: "It is not string",
             field: :post_activity,
             action: :validator,
             __hint__: "post_activity2"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               post_activity: [%{post_id: 1, like: true}]
             })
  end

  test "Conditional field as a map with external list field" do
    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       post_activities: [
         %__MODULE__.ExtrenalConditional{like: true, post_id: 1},
         %__MODULE__.ExtrenalConditional{like: false, post_id: 2}
       ],
       nickname: "Mishka"
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               post_activities: [%{post_id: 1, like: true}, %{post_id: 2, like: false}]
             })

    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       post_activities: [1, 2],
       nickname: "Mishka"
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               post_activities: [1, 2]
             })

    {:error,
     [
       %{
         field: :post_activities,
         errors: [
           %{
             message: "Your input must be a list of items",
             field: :post_activities,
             action: :type,
             __hint__: "post_activities1"
           },
           %{
             message: "It is not list",
             field: :post_activities,
             action: :validator,
             __hint__: "post_activities2"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               post_activities: :test
             })
  end

  test "Conditional field as a map with enforce as a parent" do
    {:error,
     [
       %{
         field: :author,
         errors: [
           %{
             message: "Please submit required fields.",
             fields: [:family],
             action: :required_fields
           },
           %{message: "It is not string", field: :author, action: :validator}
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               author: %{name: "Mishka"}
             })

    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       author: %__MODULE__.ConditionalProfileFieldStructs.Author1{
         family: "Group",
         name: "Mishka"
       },
       post_activities: [],
       post_activity: nil,
       auth: nil,
       location: nil,
       social: nil,
       nickname: "Mishka"
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               author: %{name: "Mishka", family: "Group"}
             })
  end

  test "Conditional field as a map with enforce as a child" do
    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       location: %__MODULE__.ConditionalProfileFieldStructs.Location1{
         city: "melbourne",
         address: "Melbourne"
       },
       nickname: "Mishka"
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               location: %{
                 city: "melbourne",
                 address: "Melbourne"
               }
             })

    {:error,
     [
       %{
         field: :location,
         errors: [
           %{
             message: "Please submit required fields.",
             fields: [:city],
             action: :required_fields,
             __hint__: "location1"
           },
           %{
             message: "It is not string",
             field: :location,
             action: :validator,
             __hint__: "location2"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               location: %{
                 address: "Melbourne"
               }
             })
  end

  test "Conditional field as a map with domain core key" do
    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       information: %__MODULE__.ConditionalProfileFieldStructs.Information1{
         gender: "female",
         name: "Mishka"
       },
       identity: %__MODULE__.ConditionalProfileFieldStructs.Identity{
         type: :female,
         action: "user"
       },
       nickname: "Mishka"
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               identity: %{action: "user", type: :female},
               information: %{name: "Mishka", gender: "female"}
             })

    {:error,
     [
       %{
         message: "Based on field information input you have to send authorized data",
         field: :information,
         action: :domain_parameters,
         field_path: "identity.type"
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               identity: %{action: "user", type: :test},
               information: %{name: "Mishka", gender: "female"}
             })

    {:error,
     [
       %{
         message: "Based on field information input you have to send authorized data",
         field: :information,
         action: :domain_parameters,
         field_path: "identity.type"
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               identity: %{action: "user", type: :female1},
               information: %{name: "Mishka", gender: "female"}
             })
  end

  test "Conditional field as a map with on core key" do
    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       sub_identity: "@github",
       information: %__MODULE__.ConditionalProfileFieldStructs.Information1{
         gender: "female",
         name: "Mishka"
       },
       identity: %__MODULE__.ConditionalProfileFieldStructs.Identity{
         type: :female,
         action: "user"
       },
       nickname: "Mishka"
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               identity: %{action: "user", type: :female},
               information: %{name: "Mishka", gender: "female"},
               sub_identity: "@github"
             })

    {:error,
     [
       %{
         message:
           "The required dependency for field sub_identity has not been submitted.\nYou must have field nickname in your input\n",
         field: :sub_identity,
         action: :dependent_keys
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               identity: %{action: "user", type: :female},
               list_sub_field_on_header: "Mishka",
               information: %{name: "Mishka", gender: "female"},
               sub_identity: "@github"
             })

    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       activity3: %__MODULE__.ConditionalProfileFieldStructs.Activity31{
         type: "normal",
         action: "admin:edit"
       },
       sub_field_on_header: "activity",
       nickname: "Mishka"
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               sub_field_on_header: "activity",
               activity3: %{action: "admin:edit", type: "normal"}
             })

    {:error,
     [
       %{
         field: :activity3,
         errors: [
           %{
             message:
               "The required dependency for field type has not been submitted.\nYou must have field sub_field_on_header in your input\n",
             field: :type,
             action: :dependent_keys,
             __hint__: "activity3"
           },
           %{
             message: "It is not string",
             field: :activity3,
             action: :validator,
             __hint__: "activity2"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               activity3: %{action: "admin:edit", type: "normal"}
             })
  end

  test "Conditional field as a map with from core key" do
    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       second_username: "Mishka",
       sub_identity: nil,
       information: %__MODULE__.ConditionalProfileFieldStructs.Information1{
         gender: "female",
         name: "Mishka"
       },
       nickname: "Mishka"
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               identity: %{action: "admin", type: :female},
               information: %{name: "Mishka", gender: "female"},
               second_username: "mishka2"
             })

    {:error,
     [
       %{
         message: "Based on field information input you have to send authorized data",
         field: :information,
         action: :domain_parameters,
         field_path: "identity.type"
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               identity: %{action: "admin", type: :test},
               information: %{name: "Mishka", gender: "female"}
             })

    {:error,
     [
       %{
         field: :information,
         errors: [
           %{
             message: "Based on field gender input you have to send authorized data",
             field: :gender,
             action: :domain_parameters,
             field_path: "identity.action"
           },
           %{message: "It is not string", field: :information, action: :validator}
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               identity: %{action: "test", type: :female},
               information: %{name: "Mishka", gender: "female"}
             })
  end

  test "Conditional field as a map with auto core key" do
    {:ok, %__MODULE__.ConditionalProfileFieldStructs{record_id: record_id}} =
      ConditionalProfileFieldStructs.builder(%{
        nickname: "Mishka",
        list_sub_field_on_header: "Mishka",
        information: %{name: "Mishka", gender: "female"},
        identity: %{action: "admin", type: :female},
        second_username: "mishka2"
      })

    assert !is_nil(record_id)
  end

  test "Conditional field as a map level/priority" do
    {:error,
     [
       %{
         field: :profile,
         errors: [
           %{
             message: "It is not string",
             field: :profile,
             action: :validator,
             __hint__: "profile1"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               profile: %{name: "", family: ""}
             })
  end

  test "Conditional field as a map with list values" do
    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       address: nil,
       activity: [
         %__MODULE__.ExtrenalConditional{
           like: true,
           post_id: 2
         },
         %__MODULE__.ExtrenalConditional{
           like: false,
           post_id: 1
         }
       ]
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               activity: [%{post_id: 2, like: true}, %{post_id: 1, like: false}]
             })

    {:error,
     [
       %{
         field: :activity,
         errors: [
           %{
             message: "The post_id field must be integer",
             field: :post_id,
             action: :integer,
             __hint__: "activity1"
           },
           %{
             message: "It is not string",
             field: :activity,
             action: :validator,
             __hint__: "activity2"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               activity: [%{post_id: "2", like: true}, %{post_id: 1, like: false}]
             })
  end

  ############# (▰˘◡˘▰) List ConditionalFieldTest GuardedStructTest Data (▰˘◡˘▰) ##############

  test "Conditional field as a list on top level" do
    {:error,
     [
       %{
         field: :address,
         errors: [
           %{message: "It is not map", field: :address, action: :validator, __hint__: "address1"},
           %{
             message: "The address field must not be empty",
             field: :address,
             action: :not_empty,
             __hint__: "address2"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               address: [%{lat: "2021", lan: "202"}, ""]
             })

    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       address: [
         %__MODULE__.ConditionalProfileFieldStructs.Address1{
           lan: "202",
           lat: "2021"
         },
         "https://github.com"
       ]
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               address: [%{lat: "2021", lan: "202"}, "https://github.com"]
             })
  end

  test "Conditional field as a list on top level with validator" do
    {:error,
     [
       %{
         field: :address,
         errors: [
           %{message: "It is not map", field: :address, action: :validator, __hint__: "address1"},
           %{
             message: "It is not string",
             field: :address,
             action: :validator,
             __hint__: "address2"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               address: [%{lat: "2021", lan: "202"}, 1]
             })
  end

  test "Conditional field as a list on top level with derive" do
    {:error,
     [
       %{
         field: :address,
         errors: [
           %{message: "It is not map", field: :address, action: :validator, __hint__: "address1"},
           %{
             message: "The address field must not be empty",
             field: :address,
             action: :not_empty,
             __hint__: "address2"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               address: [%{lat: "2021", lan: "202"}, ""]
             })

    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       address: [
         %__MODULE__.ConditionalProfileFieldStructs.Address1{
           lan: "202",
           lat: "2021"
         },
         "2024"
       ],
       profile: nil,
       nickname: "Mishka"
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               address: [%{lat: "2021", lan: "202"}, "2024"]
             })
  end

  test "Conditional field as a list on top level and subfield children validator/derive" do
    {:error,
     [
       %{
         field: :extera_auth,
         errors: [
           %{message: "It is not string", field: :username, action: :validator},
           %{
             message: "The extera_auth field must be string",
             field: :extera_auth,
             action: :string
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               extera_auth: [
                 %{username: :test, provider: :test},
                 %{username: :test, provider: :test}
               ]
             })

    {:error,
     [
       %{
         field: :extera_auth,
         errors: [
           %{message: "It is not string", field: :username, action: :validator},
           %{
             message: "The extera_auth field must be string",
             field: :extera_auth,
             action: :string
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               extera_auth: [
                 %{username: "Mishka", provider: "Github"},
                 %{username: :test, provider: :test}
               ]
             })

    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       extera_auth: [
         %__MODULE__.ConditionalProfileFieldStructs.ExteraAuth1{
           provider: "Github",
           username: "Mishka"
         },
         %__MODULE__.ConditionalProfileFieldStructs.ExteraAuth1{
           provider: "Github",
           username: "Mishka1"
         }
       ]
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               extera_auth: [
                 %{username: "Mishka", provider: "Github"},
                 %{username: "Mishka1", provider: "Github"}
               ]
             })

    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       extera_auth: [
         %__MODULE__.ConditionalProfileFieldStructs.ExteraAuth1{
           provider: "Github",
           username: "Mishka"
         },
         %__MODULE__.ConditionalProfileFieldStructs.ExteraAuth1{
           provider: "Github",
           username: "Mishka1"
         },
         "mishka@github"
       ]
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               extera_auth: [
                 %{username: "Mishka", provider: "Github"},
                 %{username: "Mishka1", provider: "Github"},
                 "mishka@github"
               ]
             })
  end

  test "Conditional field as a list on top level and subfield children derive/validator __hint__" do
    {:error,
     [
       %{
         field: :extera_auth,
         errors: [
           %{message: "It is not string", field: :username, action: :validator},
           %{
             message: "The extera_auth field must be string",
             field: :extera_auth,
             action: :string
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               extera_auth: [
                 %{username: :test, provider: :test},
                 %{username: :test, provider: :test}
               ]
             })

    {:error,
     [
       %{
         field: :extera_auth2,
         errors: [
           %{
             message: "It is not string",
             field: :username,
             action: :validator,
             __hint__: "extera_auth1"
           },
           %{
             message: "It is not string",
             field: :extera_auth2,
             action: :validator,
             __hint__: "extera_auth2"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               extera_auth2: [
                 %{username: :test, provider: "@github"},
                 %{username: :test, provider: "@github"},
                 "mishka@github"
               ]
             })

    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       extera_auth2: [
         %__MODULE__.ConditionalProfileFieldStructs.ExteraAuth21{
           provider: "@github",
           username: "Mishka"
         },
         %__MODULE__.ConditionalProfileFieldStructs.ExteraAuth21{
           provider: "@github",
           username: "Mishka1"
         },
         "mishka@github"
       ]
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               extera_auth2: [
                 %{username: "Mishka", provider: "@github"},
                 %{username: "Mishka1", provider: "@github"},
                 "mishka@github"
               ]
             })
  end

  test "Conditional field as a list on top level/external field" do
    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       activities: [
         %__MODULE__.ExtrenalConditional{like: true, post_id: 1},
         %__MODULE__.ExtrenalConditional{like: false, post_id: 2},
         "mishka@github"
       ]
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               activities: [
                 %{post_id: 1, like: true},
                 %{post_id: 2, like: false},
                 "mishka@github"
               ]
             })

    {:error,
     [
       %{
         field: :activities,
         errors: [
           %{
             message: "The post_id field must be integer",
             field: :post_id,
             action: :integer,
             __hint__: "activities1"
           },
           %{
             message: "It is not list",
             field: :activities,
             action: :validator,
             __hint__: "activities2"
           },
           %{
             message: "It is not string",
             field: :activities,
             action: :validator,
             __hint__: "activities3"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               activities: [
                 %{post_id: "1", like: true},
                 %{post_id: 2, like: false},
                 "mishka@github"
               ]
             })
  end

  test "Conditional field as a list on top level/external list field" do
    {:error,
     [
       %{
         field: :activities,
         errors: [
           %{
             message: "The post_id field must be integer",
             field: :post_id,
             action: :integer,
             __hint__: "activities1"
           },
           %{
             message: "It is not list",
             field: :activities,
             action: :validator,
             __hint__: "activities2"
           },
           %{
             message: "It is not string",
             field: :activities,
             action: :validator,
             __hint__: "activities3"
           },
           %{
             message: "It is not map",
             field: :activities,
             action: :validator,
             __hint__: "activities1"
           },
           %{
             message: "The post_id field must be integer",
             field: :post_id,
             action: :integer,
             __hint__: "activities2"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               activities: [
                 %{post_id: "1", like: true},
                 %{post_id: "2", like: false},
                 [%{post_id: "3", like: false}, %{post_id: 4, like: true}],
                 "mishka@github",
                 1,
                 [[]]
               ]
             })

    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       activities: [
         %__MODULE__.ExtrenalConditional{like: true, post_id: 1},
         %__MODULE__.ExtrenalConditional{like: false, post_id: 2},
         [
           %__MODULE__.ExtrenalConditional{like: false, post_id: 3},
           %__MODULE__.ExtrenalConditional{like: true, post_id: 4}
         ],
         "mishka@github"
       ]
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               activities: [
                 %{post_id: 1, like: true},
                 %{post_id: 2, like: false},
                 [%{post_id: 3, like: false}, %{post_id: 4, like: true}],
                 "mishka@github"
               ]
             })

    {:error,
     [
       %{
         field: :activities,
         errors: [
           %{
             message: "Please submit required fields.",
             fields: [:like],
             action: :required_fields,
             __hint__: "activities1"
           },
           %{
             message: "It is not list",
             field: :activities,
             action: :validator,
             __hint__: "activities2"
           },
           %{
             message: "It is not string",
             field: :activities,
             action: :validator,
             __hint__: "activities3"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               activities: [
                 %{post_id: 1},
                 %{post_id: 2, like: false},
                 [%{post_id: 3, like: false}, %{post_id: 4, like: true}],
                 "mishka@github"
               ]
             })
  end

  test "Conditional field as a list on top level/external list field and sub_field as a list" do
    {:error,
     [
       %{
         field: :activities2,
         errors: [
           %{
             message: "The post_id field must be integer",
             field: :post_id,
             action: :integer,
             __hint__: "activities1"
           },
           %{
             message: "It is not list",
             field: :activities2,
             action: :validator,
             __hint__: "activities2"
           },
           %{
             message: "It is not string",
             field: :activities2,
             action: :validator,
             __hint__: "activities3"
           },
           %{
             message: "It is not map",
             field: :activities2,
             action: :validator,
             __hint__: "activities1"
           },
           %{
             message:
               "Invalid NotEmpty format in the role field, you must pass data which is string, list or map.",
             field: :role,
             action: :not_empty,
             __hint__: "activities2"
           },
           %{
             message: "The role field must be string",
             field: :role,
             action: :string,
             __hint__: "activities2"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               activities2: [
                 %{post_id: "1", like: true},
                 %{post_id: "2", like: false},
                 [%{role: 3, action: false}, %{role: 4, action: true}],
                 "mishka@github",
                 1,
                 [[]]
               ]
             })

    {:error,
     [
       %{
         field: :activities2,
         errors: [
           %{
             message: "Please submit required fields.",
             fields: [:like],
             action: :required_fields,
             __hint__: "activities1"
           },
           %{
             message: "It is not list",
             field: :activities2,
             action: :validator,
             __hint__: "activities2"
           },
           %{
             message: "It is not string",
             field: :activities2,
             action: :validator,
             __hint__: "activities3"
           },
           %{
             message: "It is not map",
             field: :activities2,
             action: :validator,
             __hint__: "activities1"
           },
           %{
             message:
               "Invalid NotEmpty format in the role field, you must pass data which is string, list or map.",
             field: :role,
             action: :not_empty,
             __hint__: "activities2"
           },
           %{
             message: "The role field must be string",
             field: :role,
             action: :string,
             __hint__: "activities2"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               activities2: [
                 %{post_id: 1},
                 %{post_id: 2, like: false},
                 [%{role: 3, action: false}, %{role: 4, action: true}],
                 "mishka@github"
               ]
             })

    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       activities2: [
         %__MODULE__.ExtrenalConditional{like: true, post_id: 1},
         %__MODULE__.ExtrenalConditional{like: false, post_id: 2},
         [
           %__MODULE__.ConditionalProfileFieldStructs.Activities21{action: "add", role: "3"},
           %__MODULE__.ConditionalProfileFieldStructs.Activities21{action: "delete", role: "4"}
         ],
         "mishka@github"
       ]
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               activities2: [
                 %{post_id: 1, like: true},
                 %{post_id: 2, like: false},
                 [%{role: "3", action: "add"}, %{role: "4", action: "delete"}],
                 "mishka@github"
               ]
             })

    {:error,
     [
       %{
         field: :activities2,
         errors: [
           %{
             message: "It is not map",
             field: :activities2,
             action: :validator,
             __hint__: "activities1"
           },
           %{
             message: "Please submit required fields.",
             fields: [:action],
             action: :required_fields,
             __hint__: "activities2"
           },
           %{
             message: "It is not string",
             field: :activities2,
             action: :validator,
             __hint__: "activities3"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               activities2: [
                 %{post_id: 1, like: true},
                 %{post_id: 2, like: false},
                 [%{role: 3}, %{role: 4, action: "delete"}],
                 "mishka@github"
               ]
             })

    {:error,
     [
       %{
         field: :activities2,
         errors: [
           %{
             message: "It is not map",
             field: :activities2,
             action: :validator,
             __hint__: "activities1"
           },
           %{
             message: "The role field must not be empty",
             field: :role,
             action: :not_empty,
             __hint__: "activities2"
           },
           %{
             message: "It is not string",
             field: :activities2,
             action: :validator,
             __hint__: "activities3"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               activities2: [
                 %{post_id: 1, like: true},
                 %{post_id: 2, like: false},
                 [%{role: "", action: "delete"}, %{role: 4, action: "delete"}],
                 "mishka@github"
               ]
             })
  end

  test "Conditional field as a list on top level/priority" do
    {:error,
     [
       %{
         field: :activities3,
         errors: [
           %{
             message: "The post_id field must be integer",
             field: :post_id,
             action: :integer,
             __hint__: "activities1"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               activities3: [
                 %{post_id: "1", like: true},
                 %{post_id: "2", like: false},
                 [%{role: 3, action: false}, %{role: 4, action: true}],
                 "mishka@github",
                 1,
                 [[]]
               ]
             })

    {:error,
     [
       %{
         field: :activities3,
         errors: [
           %{
             message: "Please submit required fields.",
             fields: [:like],
             action: :required_fields,
             __hint__: "activities1"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               activities3: [
                 %{post_id: 1},
                 %{post_id: 2, like: false},
                 [%{role: 3, action: false}, %{role: 4, action: true}],
                 "mishka@github"
               ]
             })

    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       activities3: [
         %__MODULE__.ExtrenalConditional{like: true, post_id: 1},
         %__MODULE__.ExtrenalConditional{like: false, post_id: 2},
         [
           %__MODULE__.ConditionalProfileFieldStructs.Activities31{action: "add", role: "3"},
           %__MODULE__.ConditionalProfileFieldStructs.Activities31{action: "delete", role: "4"}
         ],
         "mishka@github"
       ]
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               activities3: [
                 %{post_id: 1, like: true},
                 %{post_id: 2, like: false},
                 [%{role: "3", action: "add"}, %{role: "4", action: "delete"}],
                 "mishka@github"
               ]
             })

    {:error,
     [
       %{
         field: :activities3,
         errors: [
           %{
             message: "It is not map",
             field: :activities3,
             action: :validator,
             __hint__: "activities1"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               activities3: [
                 %{post_id: 1, like: true},
                 %{post_id: 2, like: false},
                 [%{role: 3}, %{role: 4, action: "delete"}],
                 "mishka@github"
               ]
             })

    {:error,
     [
       %{
         field: :activities3,
         errors: [
           %{
             message: "It is not map",
             field: :activities3,
             action: :validator,
             __hint__: "activities1"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               activities3: [
                 %{post_id: 1, like: true},
                 %{post_id: 2, like: false},
                 [%{role: "", action: "delete"}, %{role: 4, action: "delete"}],
                 "mishka@github"
               ]
             })

    {:error,
     [
       %{
         field: :activities3,
         errors: [
           %{
             message: "It is not map",
             field: :activities3,
             action: :validator,
             __hint__: "activities1"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               activities3: [
                 [[]]
               ]
             })

    {:error,
     [
       %{
         field: :activities3,
         errors: [
           %{
             message: "It is not map",
             field: :activities3,
             action: :validator,
             __hint__: "activities1"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               activities3: [
                 [],
                 [[], %{role: "1", action: "delete"}, []]
               ]
             })

    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       activities3: [
         [
           %__MODULE__.ConditionalProfileFieldStructs.Activities31{
             action: "delete",
             role: "1"
           }
         ]
       ]
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               activities3: [
                 [[], %{role: "1", action: "delete"}, []]
               ]
             })
  end

  test "Conditional field as a list with enforce as a parent" do
    {:error,
     [
       %{
         field: :author2,
         errors: [
           %{
             message: "Please submit required fields.",
             fields: [:family],
             action: :required_fields
           },
           %{message: "It is not string", field: :author2, action: :validator},
           %{message: "It is not map", field: :author2, action: :validator}
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               author2: [%{name: "Mishka"}, 1]
             })

    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       author2: [
         %__MODULE__.ConditionalProfileFieldStructs.Author21{
           family: "Group",
           name: "Mishka"
         },
         "Mishka"
       ]
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               author2: [%{name: "Mishka", family: "Group"}, "Mishka"]
             })
  end

  test "Conditional field as a list with enforce as a child" do
    {:error,
     [
       %{
         field: :author3,
         errors: [
           %{
             message: "Please submit required fields.",
             fields: [:family],
             action: :required_fields,
             __hint__: "author1"
           },
           %{message: "It is not list", field: :author3, action: :validator, __hint__: "author2"},
           %{
             message: "It is not string",
             field: :author3,
             action: :validator,
             __hint__: "author3"
           },
           %{message: "It is not map", field: :author3, action: :validator, __hint__: "author1"}
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               author3: [%{name: "Mishka"}, 1]
             })

    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       author3: [
         %__MODULE__.ConditionalProfileFieldStructs.Author31{
           family: "Group",
           name: "Mishka"
         },
         "Mishka"
       ]
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               author3: [%{name: "Mishka", family: "Group"}, "Mishka"]
             })

    {:error,
     [
       %{
         field: :author3,
         errors: [
           %{message: "It is not map", field: :author3, action: :validator, __hint__: "author1"},
           %{
             message: "Please submit required fields.",
             fields: [:family],
             action: :required_fields,
             __hint__: "author2"
           },
           %{
             message: "It is not string",
             field: :author3,
             action: :validator,
             __hint__: "author3"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               author3: [
                 %{name: "Mishka", family: "Group"},
                 "Mishka",
                 [%{name: "Mishka"}]
               ]
             })

    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       author3: [
         %__MODULE__.ConditionalProfileFieldStructs.Author31{
           family: "Group",
           name: "Mishka"
         },
         "Mishka",
         [
           %__MODULE__.ConditionalProfileFieldStructs.Author32{family: "Group", name: "Mishka"},
           %__MODULE__.ConditionalProfileFieldStructs.Author32{family: "Group2", name: "Mishka1"}
         ]
       ]
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               author3: [
                 %{name: "Mishka", family: "Group"},
                 "Mishka",
                 [%{name: "Mishka", family: "Group"}, %{name: "Mishka1", family: "Group2"}]
               ]
             })
  end

  test "Conditional field as a list with domain core key" do
    {:error,
     [
       %{
         field: :information2,
         errors: [
           %{
             message: "Based on field gender input you have to send authorized data",
             field: :gender,
             action: :domain_parameters,
             __hint__: "information1",
             field_path: "identity.action"
           },
           %{
             message: "It is not list",
             field: :information2,
             action: :validator,
             __hint__: "information2"
           },
           %{
             message: "It is not string",
             field: :information2,
             action: :validator,
             __hint__: "information3"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               identity: %{action: "test", type: :female},
               information2: [%{name: "Mishka", gender: "female"}]
             })

    {:error,
     [
       %{
         message: "Based on field information2 input you have to send authorized data",
         field: :information2,
         action: :domain_parameters,
         field_path: "identity.type"
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               identity: %{action: "user", type: :test},
               information2: [%{name: "Mishka", gender: "female"}]
             })

    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       information2: [
         %__MODULE__.ConditionalProfileFieldStructs.Information21{
           gender: "female",
           name: "Mishka"
         }
       ],
       identity: %__MODULE__.ConditionalProfileFieldStructs.Identity{
         type: :female,
         action: "user"
       },
       nickname: "Mishka"
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "Mishka",
               identity: %{action: "user", type: :female},
               information2: [%{name: "Mishka", gender: "female"}]
             })
  end

  test "Conditional field as a list with on core key" do
    {:error,
     [
       %{
         field: :activity4,
         errors: [
           %{
             message:
               "The required dependency for field type has not been submitted.\nYou must have field sub_field_on_header in your input\n",
             field: :type,
             action: :dependent_keys,
             __hint__: "activity3"
           },
           %{
             message: "It is not string",
             field: :activity4,
             action: :validator,
             __hint__: "activity2"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               list_sub_field_on_header: "activity",
               activity4: [%{action: "admin:edit", type: "normal"}]
             })

    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       activity4: [
         %__MODULE__.ConditionalProfileFieldStructs.Activity41{
           type: "normal",
           action: "admin:edit"
         }
       ]
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               sub_field_on_header: "activity",
               list_sub_field_on_header: "activity",
               activity4: [%{action: "admin:edit", type: "normal"}]
             })

    {:error,
     [
       %{
         message:
           "The required dependency for field activity4 has not been submitted.\nYou must have field list_sub_field_on_header in your input\n",
         field: :activity4,
         action: :dependent_keys
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               sub_field_on_header: "activity",
               activity4: [%{action: "admin:edit", type: "normal"}]
             })
  end

  test "Conditional field as a list with from core key" do
    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       activity4: [
         %__MODULE__.ConditionalProfileFieldStructs.Activity41{
           from_test: "from_test_field",
           type: "normal",
           action: "admin:edit"
         },
         %__MODULE__.ConditionalProfileFieldStructs.Activity41{
           from_test: "from_test_field",
           type: "high",
           action: "admin:view"
         }
       ]
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               from_test_field: "from_test_field",
               sub_field_on_header: "activity",
               list_sub_field_on_header: "activity",
               activity4: [
                 %{action: "admin:edit", type: "normal"},
                 %{action: "admin:view", type: "high"}
               ]
             })

    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       activity4: [
         %__MODULE__.ConditionalProfileFieldStructs.Activity41{
           from_test: nil,
           type: "normal",
           action: "admin:edit"
         },
         %__MODULE__.ConditionalProfileFieldStructs.Activity41{
           from_test: nil,
           type: "high",
           action: "admin:view"
         }
       ]
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               sub_field_on_header: "activity",
               list_sub_field_on_header: "activity",
               activity4: [
                 %{action: "admin:edit", type: "normal"},
                 %{action: "admin:view", type: "high"}
               ]
             })
  end

  test "Conditional field as a list with auto core key" do
    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       activity4: [
         %__MODULE__.ConditionalProfileFieldStructs.Activity41{
           auto_test: auto_test,
           from_test: "from_test_field",
           type: "normal",
           action: "admin:edit"
         },
         %__MODULE__.ConditionalProfileFieldStructs.Activity41{
           auto_test: auto_test1,
           from_test: "from_test_field",
           type: "high",
           action: "admin:view"
         }
       ]
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               from_test_field: "from_test_field",
               sub_field_on_header: "activity",
               list_sub_field_on_header: "activity",
               activity4: [
                 %{action: "admin:edit", type: "normal"},
                 %{action: "admin:view", type: "high"}
               ]
             })

    uuid = auto_test != auto_test1
    assert uuid

    {:error,
     [
       %{
         message:
           "The required dependency for field activity4 has not been submitted.\nYou must have field list_sub_field_on_header in your input\n",
         field: :activity4,
         action: :dependent_keys
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               activity4: [
                 %{action: "admin:edit", type: "normal"},
                 %{action: "admin:view", type: "high"}
               ]
             })

    {:error,
     [
       %{
         field: :activity3,
         errors: [
           %{
             message:
               "The required dependency for field type has not been submitted.\nYou must have field sub_field_on_header in your input\n",
             field: :type,
             action: :dependent_keys,
             __hint__: "activity3"
           },
           %{
             message: "It is not string",
             field: :activity3,
             action: :validator,
             __hint__: "activity2"
           }
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               activity3: %{action: "admin:edit", type: "normal"}
             })
  end
end
