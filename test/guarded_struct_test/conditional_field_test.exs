defmodule MishkaDeveloperToolsTest.GuardedStruct.ConditionalFieldTest do
  use ExUnit.Case, async: true

  ############# (▰˘◡˘▰) ConditionalFieldTest GuardedStructTest Data (▰˘◡˘▰) ##############
  defmodule ExtrenalConditiona do
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

      conditional_field(:post_activity, any()) do
        field(:post_activity, struct(), struct: ExtrenalConditiona, hint: "post_activity1")

        field(:post_activity, String.t(),
          hint: "post_activity2",
          validator: {VAL, :is_string_data}
        )
      end

      conditional_field(:post_activities, any(), default: []) do
        field(:post_activities, struct(), structs: ExtrenalConditiona, hint: "post_activities1")

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

      # For domain
      sub_field(:identity, struct()) do
        field(:action, String.t())
        field(:type, String.t())
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
          structs: ExtrenalConditiona,
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
          struct: ExtrenalConditiona,
          validator: {VAL, :is_map_data},
          hint: "activities1"
        )

        field(:activities, struct(),
          structs: ExtrenalConditiona,
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
          struct: ExtrenalConditiona,
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
          struct: ExtrenalConditiona,
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
               social: %{address: "https://github.com/mishka-group", provider: "github"}
             })
  end

  test "Conditional field as a map with validator" do
    {:error, :bad_parameters, "Your input must be a map or list of maps"} =
      assert __MODULE__.ConditionalProfileFieldStructs.builder([
               %{nickname: "Mishka", social: "https://github.com/mishka-group"}
             ])

    {:error, :bad_parameters,
     [
       %{
         field: :social,
         action: :conditionals,
         errors: [
           {:social, "It is not map", [__hint__: "social1"]},
           {:social, "It is not string", [__hint__: "social2"]}
         ]
       }
     ]} =
      assert __MODULE__.ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               social: ["https://github.com/mishka-group"]
             })
  end

  test "Conditional field as a map with derive" do
    {:error, :bad_parameters,
     [
       %{
         message:
           "Invalid geo url format in the location field, you should send latitude and longitude",
         field: :location,
         action: :location,
         __hint__: "location2"
       }
     ]} =
      assert __MODULE__.ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
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
               auth: [
                 %{username: "Mishka", provider: "github"},
                 %{username: "Mishka", provider: "google"},
                 %{username: "Mishka", provider: "yahoo"}
               ]
             })

    {:error, :bad_parameters,
     [
       %{
         field: :auth,
         action: :conditionals,
         errors: [
           {:auth, "It is not list", [__hint__: "auth1"]},
           {:bad_parameters, "Your input must be a list of items", [__hint__: "auth2"]},
           {:auth, "It is not string", [__hint__: "auth3"]}
         ]
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               auth: %{username: "Mishka", provider: "github"}
             })
  end

  test "Conditional field as a map with external field" do
    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       post_activity: %__MODULE__.ExtrenalConditiona{
         like: true,
         post_id: 1
       },
       nickname: "Mishka"
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               post_activity: %{post_id: 1, like: true}
             })

    {:error, :bad_parameters,
     [
       %{
         field: :post_activity,
         action: :conditionals,
         errors: [
           {:required_fields, [:like], [__hint__: "post_activity1"]},
           {:post_activity, "It is not string", [__hint__: "post_activity2"]}
         ]
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               post_activity: %{post_id: 1, provider: true}
             })

    {:error, :bad_parameters,
     [
       %{
         field: :post_activity,
         action: :conditionals,
         errors: [
           {:bad_parameters, "Your input must be a map or list of maps",
            [__hint__: "post_activity1"]},
           {:post_activity, "It is not string", [__hint__: "post_activity2"]}
         ]
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               post_activity: [%{post_id: 1, like: true}]
             })
  end

  test "Conditional field as a map with external list field" do
    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       post_activities: [
         %__MODULE__.ExtrenalConditiona{like: true, post_id: 1},
         %__MODULE__.ExtrenalConditiona{like: false, post_id: 2}
       ],
       nickname: "Mishka"
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               post_activities: [%{post_id: 1, like: true}, %{post_id: 2, like: false}]
             })

    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       post_activities: [1, 2],
       nickname: "Mishka"
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               post_activities: [1, 2]
             })

    {:error, :bad_parameters,
     [
       %{
         field: :post_activities,
         action: :conditionals,
         errors: [
           {:bad_parameters, "Your input must be a list of items",
            [__hint__: "post_activities1"]},
           {:post_activities, "It is not list", [__hint__: "post_activities2"]}
         ]
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               post_activities: :test
             })
  end

  test "Conditional field as a map with enforce as a parent" do
    {:error, :bad_parameters,
     [
       %{
         field: :author,
         action: :conditionals,
         errors: [required_fields: [:family], author: "It is not string"]
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
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
               location: %{
                 city: "melbourne",
                 address: "Melbourne"
               }
             })

    {:error, :bad_parameters,
     [
       %{
         field: :location,
         action: :conditionals,
         errors: [
           {:required_fields, [:city], [__hint__: "location1"]},
           {:location, "It is not string", [__hint__: "location2"]}
         ]
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
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
               identity: %{action: "user", type: :female},
               information: %{name: "Mishka", gender: "female"}
             })

    {:error, :domain_parameters,
     [
       %{
         message: "Based on field information input you have to send authorized data",
         field: :information,
         field_path: "identity.type"
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               identity: %{action: "user", type: :test},
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
               identity: %{action: "user", type: :female},
               information: %{name: "Mishka", gender: "female"},
               sub_identity: "@github"
             })

    {:error, :dependent_keys,
     [
       %{
         message:
           "The required dependency for field sub_identity has not been submitted.\nYou must have field nickname in your input\n",
         field: :sub_identity
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               identity: %{action: "user", type: :female},
               information: %{name: "Mishka", gender: "female"},
               sub_identity: "@github"
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
               information: %{name: "Mishka", gender: "female"},
               second_username: "mishka2"
             })

    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       second_username: "Mishka",
       sub_identity: nil,
       information: %__MODULE__.ConditionalProfileFieldStructs.Information1{
         gender: "female",
         name: "Mishka"
       },
       identity: nil,
       author: nil,
       post_activities: [],
       post_activity: nil,
       auth: nil,
       location: nil,
       social: nil,
       nickname: "Mishka"
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               information: %{name: "Mishka", gender: "female"}
             })
  end

  test "Conditional field as a map with auto core key" do
    {:ok, %__MODULE__.ConditionalProfileFieldStructs{record_id: record_id}} =
      ConditionalProfileFieldStructs.builder(%{
        nickname: "Mishka",
        information: %{name: "Mishka", gender: "female"},
        second_username: "mishka2"
      })

    assert !is_nil(record_id)
  end

  test "Conditional field as a map level/priority" do
    {:error, :bad_parameters,
     [
       %{
         field: :profile,
         action: :conditionals,
         errors: [{:profile, "It is not string", [__hint__: "profile1"]}]
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               profile: %{name: "", family: ""}
             })
  end

  test "Conditional field as a map with list values" do
    {:ok,
     %__MODULE__.ConditionalProfileFieldStructs{
       address: nil,
       activity: [
         %__MODULE__.ExtrenalConditiona{
           like: true,
           post_id: 2
         },
         %__MODULE__.ExtrenalConditiona{
           like: false,
           post_id: 1
         }
       ]
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               activity: [%{post_id: 2, like: true}, %{post_id: 1, like: false}]
             })

    {:error, :bad_parameters,
     [
       %{
         field: :activity,
         errors: [
           {:bad_parameters,
            [
              %{
                message: "The post_id field must be integer",
                field: :post_id,
                action: :integer
              }
            ], [__hint__: "activity1"]},
           {:activity, "It is not string", [__hint__: "activity2"]}
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               activity: [%{post_id: "2", like: true}, %{post_id: 1, like: false}]
             })
  end

  ############# (▰˘◡˘▰) List ConditionalFieldTest GuardedStructTest Data (▰˘◡˘▰) ##############

  test "Conditional field as a list on top level" do
    {:error, :bad_parameters,
     [
       %{
         message: "The address field must not be empty",
         field: :address,
         action: :not_empty,
         __hint__: "address2"
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
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
               address: [%{lat: "2021", lan: "202"}, "https://github.com"]
             })
  end

  test "Conditional field as a list on top level with validator" do
    {:error, :bad_parameters,
     [
       %{
         field: :address,
         errors: [
           {:address, "It is not map", [__hint__: "address1"]},
           {:address, "It is not string", [__hint__: "address2"]}
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               address: [%{lat: "2021", lan: "202"}, 1]
             })
  end

  test "Conditional field as a list on top level with derive" do
    {:error, :bad_parameters,
     [
       %{
         message: "The address field must not be empty",
         field: :address,
         action: :not_empty,
         __hint__: "address2"
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
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
               address: [%{lat: "2021", lan: "202"}, "2024"]
             })
  end

  test "Conditional field as a list on top level and subfield children validator/derive" do
    {:error, :bad_parameters,
     [
       %{
         message: "The extera_auth field must be string",
         field: :extera_auth,
         action: :string
       },
       %{
         message: "The extera_auth field must be string",
         field: :extera_auth,
         action: :string
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               extera_auth: [
                 %{username: :test, provider: :test},
                 %{username: :test, provider: :test}
               ]
             })

    {:error, :bad_parameters,
     [
       %{
         message: "The extera_auth field must be string",
         field: :extera_auth,
         action: :string
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
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
               extera_auth: [
                 %{username: "Mishka", provider: "Github"},
                 %{username: "Mishka1", provider: "Github"},
                 "mishka@github"
               ]
             })
  end

  test "Conditional field as a list on top level and subfield children derive/validator __hint__" do
    {:error, :bad_parameters,
     [
       %{message: "The extera_auth field must be string", field: :extera_auth, action: :string},
       %{message: "The extera_auth field must be string", field: :extera_auth, action: :string}
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               extera_auth: [
                 %{username: :test, provider: :test},
                 %{username: :test, provider: :test}
               ]
             })

    {:error, :bad_parameters,
     [
       %{
         field: :extera_auth2,
         errors: [
           {:bad_parameters, [%{message: "It is not string", field: :username}],
            [__hint__: "extera_auth1"]},
           {:extera_auth2, "It is not string", [__hint__: "extera_auth2"]}
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
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
         %__MODULE__.ExtrenalConditiona{like: true, post_id: 1},
         %__MODULE__.ExtrenalConditiona{like: false, post_id: 2},
         "mishka@github"
       ]
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               activities: [
                 %{post_id: 1, like: true},
                 %{post_id: 2, like: false},
                 "mishka@github"
               ]
             })

    {:error, :bad_parameters,
     [
       %{
         field: :activities,
         errors: [
           {:bad_parameters,
            [%{message: "The post_id field must be integer", field: :post_id, action: :integer}],
            [__hint__: "activities1"]},
           {:activities, "It is not list", [__hint__: "activities2"]},
           {:activities, "It is not string", [__hint__: "activities3"]}
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               activities: [
                 %{post_id: "1", like: true},
                 %{post_id: 2, like: false},
                 "mishka@github"
               ]
             })
  end

  test "Conditional field as a list on top level/external list field" do
    {:error, :bad_parameters,
     [
       %{
         field: :activities,
         errors: [
           {:bad_parameters,
            [
              %{
                message: "The post_id field must be integer",
                field: :post_id,
                action: :integer
              }
            ], [__hint__: "activities1"]},
           {:activities, "It is not list", [__hint__: "activities2"]},
           {:activities, "It is not string", [__hint__: "activities3"]},
           {:activities, "It is not map", [__hint__: "activities1"]},
           {:bad_parameters,
            [
              %{
                message: "The post_id field must be integer",
                field: :post_id,
                action: :integer
              }
            ], [__hint__: "activities2"]}
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
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
         %__MODULE__.ExtrenalConditiona{like: true, post_id: 1},
         %__MODULE__.ExtrenalConditiona{like: false, post_id: 2},
         [
           %__MODULE__.ExtrenalConditiona{like: false, post_id: 3},
           %__MODULE__.ExtrenalConditiona{like: true, post_id: 4}
         ],
         "mishka@github"
       ]
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               activities: [
                 %{post_id: 1, like: true},
                 %{post_id: 2, like: false},
                 [%{post_id: 3, like: false}, %{post_id: 4, like: true}],
                 "mishka@github"
               ]
             })

    {:error, :bad_parameters,
     [
       %{
         field: :activities,
         errors: [
           {:required_fields, [:like], [__hint__: "activities1"]},
           {:activities, "It is not list", [__hint__: "activities2"]},
           {:activities, "It is not string", [__hint__: "activities3"]}
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               activities: [
                 %{post_id: 1},
                 %{post_id: 2, like: false},
                 [%{post_id: 3, like: false}, %{post_id: 4, like: true}],
                 "mishka@github"
               ]
             })
  end

  test "Conditional field as a list on top level/external list field and sub_field as a list" do
    {:error, :bad_parameters,
     [
       %{
         field: :activities2,
         errors: [
           {:bad_parameters,
            [%{message: "The post_id field must be integer", field: :post_id, action: :integer}],
            [__hint__: "activities1"]},
           {:activities2, "It is not list", [__hint__: "activities2"]},
           {:activities2, "It is not string", [__hint__: "activities3"]},
           {:activities2, "It is not map", [__hint__: "activities1"]},
           {:bad_parameters,
            [
              %{
                message:
                  "Invalid NotEmpty format in the role field, you must pass data which is string, list or map.",
                field: :role,
                action: :not_empty
              },
              %{message: "The role field must be string", field: :role, action: :string}
            ], [__hint__: "activities2"]}
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               activities2: [
                 %{post_id: "1", like: true},
                 %{post_id: "2", like: false},
                 [%{role: 3, action: false}, %{role: 4, action: true}],
                 "mishka@github",
                 1,
                 [[]]
               ]
             })

    {:error, :bad_parameters,
     [
       %{
         field: :activities2,
         errors: [
           {:required_fields, [:like], [__hint__: "activities1"]},
           {:activities2, "It is not list", [__hint__: "activities2"]},
           {:activities2, "It is not string", [__hint__: "activities3"]},
           {:activities2, "It is not map", [__hint__: "activities1"]},
           {:bad_parameters,
            [
              %{
                message:
                  "Invalid NotEmpty format in the role field, you must pass data which is string, list or map.",
                field: :role,
                action: :not_empty
              },
              %{message: "The role field must be string", field: :role, action: :string}
            ], [__hint__: "activities2"]}
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
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
         %__MODULE__.ExtrenalConditiona{like: true, post_id: 1},
         %__MODULE__.ExtrenalConditiona{like: false, post_id: 2},
         [
           %__MODULE__.ConditionalProfileFieldStructs.Activities21{action: "add", role: "3"},
           %__MODULE__.ConditionalProfileFieldStructs.Activities21{action: "delete", role: "4"}
         ],
         "mishka@github"
       ]
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               activities2: [
                 %{post_id: 1, like: true},
                 %{post_id: 2, like: false},
                 [%{role: "3", action: "add"}, %{role: "4", action: "delete"}],
                 "mishka@github"
               ]
             })

    {:error, :bad_parameters,
     [
       %{
         field: :activities2,
         errors: [
           {:activities2, "It is not map", [__hint__: "activities1"]},
           {:required_fields, [:action], [__hint__: "activities2"]},
           {:activities2, "It is not string", [__hint__: "activities3"]}
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               activities2: [
                 %{post_id: 1, like: true},
                 %{post_id: 2, like: false},
                 [%{role: 3}, %{role: 4, action: "delete"}],
                 "mishka@github"
               ]
             })

    {:error, :bad_parameters,
     [
       %{
         field: :activities2,
         errors: [
           {:activities2, "It is not map", [__hint__: "activities1"]},
           {:bad_parameters,
            [
              %{
                message: "The role field must not be empty",
                field: :role,
                action: :not_empty
              }
            ], [__hint__: "activities2"]},
           {:activities2, "It is not string", [__hint__: "activities3"]}
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               activities2: [
                 %{post_id: 1, like: true},
                 %{post_id: 2, like: false},
                 [%{role: "", action: "delete"}, %{role: 4, action: "delete"}],
                 "mishka@github"
               ]
             })
  end

  test "Conditional field as a list on top level/priority" do
    {:error, :bad_parameters,
     [
       %{
         field: :activities3,
         errors: [
           {:bad_parameters,
            [
              %{
                message: "The post_id field must be integer",
                field: :post_id,
                action: :integer
              }
            ], [__hint__: "activities1"]}
         ],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               activities3: [
                 %{post_id: "1", like: true},
                 %{post_id: "2", like: false},
                 [%{role: 3, action: false}, %{role: 4, action: true}],
                 "mishka@github",
                 1,
                 [[]]
               ]
             })

    {:error, :bad_parameters,
     [
       %{
         field: :activities3,
         errors: [{:required_fields, [:like], [__hint__: "activities1"]}],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
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
         %__MODULE__.ExtrenalConditiona{like: true, post_id: 1},
         %__MODULE__.ExtrenalConditiona{like: false, post_id: 2},
         [
           %__MODULE__.ConditionalProfileFieldStructs.Activities31{action: "add", role: "3"},
           %__MODULE__.ConditionalProfileFieldStructs.Activities31{action: "delete", role: "4"}
         ],
         "mishka@github"
       ]
     }} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               activities3: [
                 %{post_id: 1, like: true},
                 %{post_id: 2, like: false},
                 [%{role: "3", action: "add"}, %{role: "4", action: "delete"}],
                 "mishka@github"
               ]
             })

    {:error, :bad_parameters,
     [
       %{
         field: :activities3,
         errors: [{:activities3, "It is not map", [__hint__: "activities1"]}],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               activities3: [
                 %{post_id: 1, like: true},
                 %{post_id: 2, like: false},
                 [%{role: 3}, %{role: 4, action: "delete"}],
                 "mishka@github"
               ]
             })

    {:error, :bad_parameters,
     [
       %{
         field: :activities3,
         errors: [{:activities3, "It is not map", [__hint__: "activities1"]}],
         action: :conditionals
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               activities3: [
                 %{post_id: 1, like: true},
                 %{post_id: 2, like: false},
                 [%{role: "", action: "delete"}, %{role: 4, action: "delete"}],
                 "mishka@github"
               ]
             })

    # TODO: non of condition we want does not exist for this [[]]
    {:error, :bad_parameters,
     [
       %{
         message: "The activities3 field item must not be empty",
         field: :activities3,
         action: :not_empty,
         __hint__: "activities2"
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
               activities3: [
                 [[]]
               ]
             })

    {:error, :bad_parameters,
     [
       %{
         message: "The activities3 field item must not be empty",
         field: :activities3,
         action: :not_empty,
         __hint__: "activities2"
       }
     ]} =
      assert ConditionalProfileFieldStructs.builder(%{
               nickname: "Mishka",
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
               activities3: [
                 [[], %{role: "1", action: "delete"}, []]
               ]
             })
  end

  test "Conditional field as a list with enforce as a parent" do
  end

  test "Conditional field as a list with enforce as a child" do
  end

  test "Conditional field as a list with domain core key" do
  end

  test "Conditional field as a list with on core key" do
  end

  test "Conditional field as a list with from core key" do
  end

  test "Conditional field as a list with auto core key" do
  end
end
