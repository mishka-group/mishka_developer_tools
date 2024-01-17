defmodule MishkaDeveloperToolsTest.GuardedStruct.CoreKeysTest do
  use ExUnit.Case, async: true

  ############# (▰˘◡˘▰) CoreKeysTest GuardedStructTest Data (▰˘◡˘▰) ##############
  defmodule CoreKeysStructs do
    use GuardedStruct
    alias ConditionalFieldValidatorTestValidators, as: VAL

    guardedstruct do
      field(:provider, String.t())
      field(:provider2, String.t())

      field(:provider_path, String.t(), on: "root::provider")

      field(:from_nothing, String.t(), from: "root::test")

      field(:from_provider2, String.t(), from: "root::provider2")

      sub_field(:projects, struct(), structs: true, on: "root::provider") do
        field(:action, String.t())
        field(:type, String.t(), on: "root::provider_path")
        field(:record_id, String.t(), auto: {Ecto.UUID, :generate})
        field(:from_provider, String.t(), from: "root::provider")
        field(:from_nothing, String.t(), from: "root::nothing")
      end

      sub_field(:project, struct(), on: "root::provider") do
        field(:action, String.t())
        field(:type, String.t(), on: "root::provider_path")
        field(:record_id, String.t(), auto: {Ecto.UUID, :generate})
        field(:from_provider, String.t(), from: "root::provider")
        field(:from_nothing, String.t(), from: "root::nothing")
      end

      conditional_field(:different_projects, any(), structs: true, on: "root::project::type") do
        sub_field(:different_projects, struct(),
          validator: {VAL, :is_map_data},
          hint: "different_projects1"
        ) do
          field(:action, String.t())
          field(:type, String.t(), on: "root::provider2")
          field(:record_id, String.t(), auto: {Ecto.UUID, :generate})
          field(:from_provider, String.t(), from: "root::provider")
          field(:from_nothing, String.t(), from: "root::nothing")
          field(:on_nothing, String.t(), on: "root::project::test")
          field(:on_provider, String.t(), on: "root::provider")
        end

        sub_field(:different_projects, struct(),
          structs: true,
          validator: {VAL, :is_list_data},
          hint: "different_projects2"
        ) do
          field(:action, String.t())
          field(:type, String.t())
          field(:record_id, String.t(), auto: {Ecto.UUID, :generate})
          field(:from_provider, String.t(), from: "root::provider")
          field(:from_nothing, String.t(), from: "root::nothing")
          field(:on_nothing, String.t(), on: "root::projects::test")
          field(:on_provider, String.t(), on: "root::provider")
        end

        field(:different_projects, String.t(),
          validator: {VAL, :is_string_data},
          hint: "different_projects3"
        )
      end

      sub_field(:code_base, struct()) do
        field(:repo, String.t())
        field(:type, String.t())
        field(:record_id, String.t(), auto: {Ecto.UUID, :generate})
        field(:from_provider, String.t(), from: "root::provider")
        field(:from_nothing, String.t(), from: "root::nothing")
        field(:on_nothing, String.t(), on: "root::projects::test")
        field(:on_provider, String.t(), on: "root::provider")
      end

      conditional_field(:different_code_bases, any(), on: "root::code_base::type") do
        sub_field(:different_code_bases, struct(),
          validator: {VAL, :is_map_data},
          hint: "different_code_bases1"
        ) do
          field(:action, String.t())
          field(:type, String.t())
          field(:record_id, String.t(), auto: {Ecto.UUID, :generate})
          field(:from_provider, String.t(), from: "root::provider")
          field(:from_nothing, String.t(), from: "root::nothing")
          field(:on_nothing, String.t(), on: "root::projects::test")
          field(:on_provider, String.t(), on: "root::provider")
        end

        field(:different_code_bases, String.t(),
          validator: {VAL, :is_string_data},
          hint: "different_code_bases2"
        )
      end
    end
  end

  defmodule AllowedParentDomain do
    use GuardedStruct

    guardedstruct authorized_fields: true do
      field(:username, String.t(),
        domain: "!auth.action=String[admin, user]::?auth.social=Atom[banned]",
        derive: "validate(string)"
      )

      field(:type_social, String.t(),
        domain: "?auth.type=Map[%{name: \"mishka\"}, %{name: \"mishka2\"}]",
        derive: "validate(string)"
      )

      field(:social_equal, atom(),
        domain: "?auth.equal=Equal[Atom>>name]",
        derive: "validate(atom)"
      )

      field(:social_either, atom(),
        domain: "?auth.either=Either[string, enum>>Integer[1>>2>>3]]",
        derive: "validate(atom)"
      )

      sub_field(:auth, struct(), authorized_fields: true) do
        field(:action, String.t(), derive: "validate(not_empty)")
        field(:social, atom(), derive: "validate(atom)")
        field(:type, map(), derive: "validate(map)")
        field(:equal, atom(), derive: "validate(atom)")
        field(:either, atom())
      end
    end
  end

  defmodule AllowedParentCustomDomain do
    use GuardedStruct
    @module_path "MishkaDeveloperToolsTest.GuardedStruct.CoreKeysTest.AllowedParentCustomDomain"

    guardedstruct authorized_fields: true do
      field(:username, String.t(),
        domain: "!auth.action=Custom[#{@module_path}, is_stuff?]",
        derive: "validate(string)"
      )

      sub_field(:auth, struct(), authorized_fields: true) do
        field(:action, String.t(), derive: "validate(not_empty)")
      end

      conditional_field(:id, String.t(), auto: {Ecto.UUID, :generate}) do
        field(:id, String.t(),
          derive: "sanitize(tag=strip_tags) validate(url, max_len=160)",
          hint: "url_id"
        )

        field(:id, any(),
          derive: "sanitize(tag=strip_tags) validate(not_empty_string, uuid)",
          hint: "uuid_id"
        )
      end
    end

    def is_stuff?(data) when data == "ok", do: true
    def is_stuff?(_data), do: false
  end

  ############# (▰˘◡˘▰) Core Key GuardedStructTest Tests (▰˘◡˘▰) ##############

  test "normal on core key" do
    {:ok, %__MODULE__.CoreKeysStructs{provider_path: "https://mishka.life", provider: "mishka"}} =
      assert CoreKeysStructs.builder(%{provider: "mishka", provider_path: "https://mishka.life"})

    {:error, :dependent_keys,
     [
       %{
         message:
           "The required dependency for field provider_path has not been submitted.\nYou must have field provider in your input\n",
         field: :provider_path
       }
     ]} =
      assert CoreKeysStructs.builder(%{provider_path: "https://mishka.life"})

    {:ok, _struct} = assert CoreKeysStructs.builder(%{})
  end

  test "list sub field on core key" do
    {:ok,
     %__MODULE__.CoreKeysStructs{
       projects: [
         %__MODULE__.CoreKeysStructs.Projects{
           from_nothing: nil,
           from_provider: "Mishka",
           type: "normal",
           action: "admin"
         }
       ],
       provider_path: "https://mishka.life",
       provider: "Mishka"
     }} =
      assert CoreKeysStructs.builder(%{
               provider: "Mishka",
               provider_path: "https://mishka.life",
               projects: [
                 %{
                   action: "admin",
                   type: "normal"
                 }
               ]
             })

    {:error, :dependent_keys,
     [
       %{
         message:
           "The required dependency for field projects has not been submitted.\nYou must have field provider in your input\n",
         field: :projects
       },
       %{
         message:
           "The required dependency for field provider_path has not been submitted.\nYou must have field provider in your input\n",
         field: :provider_path
       }
     ]} =
      assert CoreKeysStructs.builder(%{
               provider_path: "https://mishka.life",
               projects: [
                 %{
                   action: "admin",
                   type: "normal"
                 }
               ]
             })

    {:error, :bad_parameters,
     [
       %{
         field: :projects,
         errors:
           {:dependent_keys,
            [
              %{
                message:
                  "The required dependency for field type has not been submitted.\nYou must have field provider_path in your input\n",
                field: :type
              }
            ]}
       }
     ]} =
      assert CoreKeysStructs.builder(%{
               provider: "Mishka",
               projects: [
                 %{
                   action: "admin",
                   type: "normal"
                 }
               ]
             })

    {:ok,
     %__MODULE__.CoreKeysStructs{
       projects: [
         %__MODULE__.CoreKeysStructs.Projects{from_provider: "Mishka", action: "admin"}
       ],
       provider: "Mishka"
     }} =
      assert CoreKeysStructs.builder(%{
               provider: "Mishka",
               projects: [
                 %{
                   action: "admin"
                 }
               ]
             })
  end

  test "map conditional field core key" do
    {:ok,
     %__MODULE__.CoreKeysStructs{
       different_code_bases: %__MODULE__.CoreKeysStructs.DifferentCodeBases1{
         from_provider: "Mishka",
         action: "admin"
       },
       code_base: %__MODULE__.CoreKeysStructs.CodeBase{
         from_provider: "Mishka",
         type: "develop",
         repo: "github"
       },
       provider: "Mishka"
     }} =
      assert CoreKeysStructs.builder(%{
               provider: "Mishka",
               code_base: %{
                 repo: "github",
                 type: "develop"
               },
               different_code_bases: %{
                 action: "admin"
               }
             })

    {:error, :dependent_keys,
     [
       %{
         message:
           "The required dependency for field different_code_bases has not been submitted.\nYou must have field type in your input\n",
         field: :different_code_bases
       }
     ]} =
      assert CoreKeysStructs.builder(%{
               provider: "Mishka",
               code_base: %{
                 repo: "github"
               },
               different_code_bases: %{
                 action: "admin"
               }
             })

    {:error, :bad_parameters,
     [
       %{
         field: :different_code_bases,
         errors: [
           {:dependent_keys,
            [
              %{
                message:
                  "The required dependency for field on_provider has not been submitted.\nYou must have field provider in your input\n",
                field: :on_provider
              }
            ], [__hint__: "different_code_bases1"]},
           {:different_code_bases, "It is not string", [__hint__: "different_code_bases2"]}
         ],
         action: :conditionals
       }
     ]} =
      assert CoreKeysStructs.builder(%{
               code_base: %{
                 repo: "github",
                 type: "develop"
               },
               different_code_bases: %{
                 action: "admin",
                 type: "develop",
                 on_provider: "mishka"
               }
             })

    {:ok,
     %__MODULE__.CoreKeysStructs{
       different_code_bases: %__MODULE__.CoreKeysStructs.DifferentCodeBases1{
         on_provider: "mishka",
         type: "develop",
         action: "admin"
       },
       code_base: %__MODULE__.CoreKeysStructs.CodeBase{
         type: "develop",
         repo: "github"
       },
       provider: "Mishka"
     }} =
      assert CoreKeysStructs.builder(%{
               provider: "Mishka",
               code_base: %{
                 repo: "github",
                 type: "develop"
               },
               different_code_bases: %{
                 action: "admin",
                 type: "develop",
                 on_provider: "mishka"
               }
             })

    {:error, :bad_parameters,
     [
       %{
         field: :different_code_bases,
         errors: [
           {:dependent_keys,
            [
              %{
                message:
                  "The required dependency for field on_nothing has not been submitted.\nYou must have field test in your input\n",
                field: :on_nothing
              }
            ], [__hint__: "different_code_bases1"]},
           {:different_code_bases, "It is not string", [__hint__: "different_code_bases2"]}
         ],
         action: :conditionals
       }
     ]} =
      assert CoreKeysStructs.builder(%{
               provider: "Mishka",
               code_base: %{
                 repo: "github",
                 type: "develop"
               },
               different_code_bases: %{
                 action: "admin",
                 type: "develop",
                 on_nothing: "mishka"
               }
             })
  end

  test "list conditional field core key" do
    {:ok,
     %__MODULE__.CoreKeysStructs{
       different_projects: [
         %__MODULE__.CoreKeysStructs.DifferentProjects1{
           from_provider: "mishka",
           type: "normal",
           action: "installer"
         }
       ],
       project: %__MODULE__.CoreKeysStructs.Project{
         from_nothing: nil,
         type: "develop",
         action: "github"
       },
       projects: nil,
       provider_path: "https://mishka.life",
       provider: "mishka"
     }} =
      assert CoreKeysStructs.builder(%{
               provider: "mishka",
               provider2: "mishka",
               provider_path: "https://mishka.life",
               project: %{
                 action: "github",
                 type: "develop"
               },
               different_projects: [%{action: "installer", type: "normal"}]
             })

    {:error, :dependent_keys,
     [
       %{
         message:
           "The required dependency for field project has not been submitted.\nYou must have field provider in your input\n",
         field: :project
       },
       %{
         message:
           "The required dependency for field provider_path has not been submitted.\nYou must have field provider in your input\n",
         field: :provider_path
       }
     ]} =
      assert CoreKeysStructs.builder(%{
               provider_path: "https://mishka.life",
               project: %{
                 action: "github",
                 type: "develop"
               },
               different_projects: [%{action: "installer", type: "normal"}]
             })

    {:error, :bad_parameters,
     [
       %{
         field: :project,
         errors:
           {:dependent_keys,
            [
              %{
                message:
                  "The required dependency for field type has not been submitted.\nYou must have field provider_path in your input\n",
                field: :type
              }
            ]}
       }
     ]} =
      assert CoreKeysStructs.builder(%{
               provider: "Mishka",
               provider2: "Mishka",
               project: %{
                 action: "github",
                 type: "develop"
               },
               different_projects: [%{action: "installer", type: "normal"}]
             })

    {:ok,
     %__MODULE__.CoreKeysStructs{
       different_code_bases: nil,
       code_base: nil,
       different_projects: [
         %__MODULE__.CoreKeysStructs.DifferentProjects1{
           type: nil,
           action: "installer"
         }
       ],
       project: %__MODULE__.CoreKeysStructs.Project{
         type: "develop",
         action: "github"
       },
       provider_path: "https://mishka.life",
       provider: "Mishka"
     }} =
      assert CoreKeysStructs.builder(%{
               provider: "Mishka",
               provider_path: "https://mishka.life",
               project: %{
                 action: "github",
                 type: "develop"
               },
               different_projects: [%{action: "installer"}]
             })

    {:error, :bad_parameters,
     [
       %{
         field: :different_projects,
         errors: [
           {:dependent_keys,
            [
              %{
                message:
                  "The required dependency for field type has not been submitted.\nYou must have field provider2 in your input\n",
                field: :type
              }
            ], [__hint__: "different_projects1"]},
           {:different_projects, "It is not list", [__hint__: "different_projects2"]},
           {:different_projects, "It is not string", [__hint__: "different_projects3"]}
         ],
         action: :conditionals
       }
     ]} =
      assert CoreKeysStructs.builder(%{
               provider: "Mishka",
               provider_path: "https://mishka.life",
               project: %{
                 action: "github",
                 type: "develop"
               },
               different_projects: [%{action: "installer", type: "test"}, %{action: "installer"}]
             })
  end

  test "normal from core key" do
    {:ok,
     %__MODULE__.CoreKeysStructs{
       from_nothing: "nothing"
     }} =
      assert CoreKeysStructs.builder(%{from_nothing: "nothing"})

    {:ok, %__MODULE__.CoreKeysStructs{from_provider2: "mishka"}} =
      assert CoreKeysStructs.builder(%{provider2: "mishka", from_provider2: "nothing"})

    {:ok, %__MODULE__.CoreKeysStructs{from_provider2: "mishka"}} =
      assert CoreKeysStructs.builder(%{provider2: "mishka"})
  end

  test "sub_field from core key" do
    {:ok,
     %__MODULE__.CoreKeysStructs{
       projects: [
         %__MODULE__.CoreKeysStructs.Projects{
           from_nothing: nil,
           from_provider: "mishka",
           action: "admin"
         },
         %__MODULE__.CoreKeysStructs.Projects{
           from_nothing: nil,
           from_provider: "mishka",
           action: "user"
         }
       ],
       provider: "mishka"
     }} =
      assert CoreKeysStructs.builder(%{
               provider: "mishka",
               projects: [%{action: "admin"}, %{action: "user"}]
             })
  end

  test "map conditional field from core key" do
    {:ok,
     %__MODULE__.CoreKeysStructs{
       different_code_bases: %__MODULE__.CoreKeysStructs.DifferentCodeBases1{
         from_provider: "mishka",
         action: "admin"
       },
       code_base: %__MODULE__.CoreKeysStructs.CodeBase{
         from_provider: "mishka",
         type: "new"
       },
       provider: "mishka"
     }} =
      assert CoreKeysStructs.builder(%{
               provider: "mishka",
               code_base: %{type: "new"},
               different_code_bases: %{action: "admin"}
             })
  end

  test "list conditional field from core key" do
    {:ok,
     %__MODULE__.CoreKeysStructs{
       different_code_bases: nil,
       code_base: nil,
       different_projects: [
         %__MODULE__.CoreKeysStructs.DifferentProjects1{from_provider: "mishka", action: "admin"},
         %__MODULE__.CoreKeysStructs.DifferentProjects1{from_provider: "mishka", action: "user"},
         "develop"
       ],
       project: %__MODULE__.CoreKeysStructs.Project{from_provider: "mishka", type: "new"},
       provider_path: "https://mishka.life",
       provider: "mishka"
     }} =
      assert CoreKeysStructs.builder(%{
               provider: "mishka",
               provider_path: "https://mishka.life",
               project: %{type: "new"},
               different_projects: [
                 %{action: "admin", from_provider: "test"},
                 %{action: "user", from_provider: "test1"},
                 "develop"
               ]
             })

    {:ok,
     %__MODULE__.CoreKeysStructs{
       different_projects: [
         %__MODULE__.CoreKeysStructs.DifferentProjects1{from_provider: "mishka", action: "admin"},
         %__MODULE__.CoreKeysStructs.DifferentProjects1{from_provider: "mishka", action: "user"},
         [
           %__MODULE__.CoreKeysStructs.DifferentProjects2{
             from_nothing: "test",
             from_provider: "mishka",
             action: "user"
           }
         ],
         "develop"
       ],
       project: %__MODULE__.CoreKeysStructs.Project{
         from_provider: "mishka",
         type: "new"
       },
       provider_path: "https://mishka.life",
       provider: "mishka"
     }} =
      assert CoreKeysStructs.builder(%{
               provider: "mishka",
               provider_path: "https://mishka.life",
               project: %{type: "new"},
               different_projects: [
                 %{action: "admin", from_provider: "test"},
                 %{action: "user", from_provider: "test1"},
                 [%{action: "user", from_provider: "test1", from_nothing: "test"}],
                 "develop"
               ]
             })
  end

  test "test auto core key" do
    {:ok,
     %__MODULE__.CoreKeysStructs{
       different_code_bases: nil,
       code_base: nil,
       different_projects: [
         %__MODULE__.CoreKeysStructs.DifferentProjects1{
           record_id: record_id1
         },
         %__MODULE__.CoreKeysStructs.DifferentProjects1{
           record_id: record_id2
         },
         [
           %__MODULE__.CoreKeysStructs.DifferentProjects2{
             record_id: record_id3
           }
         ],
         "develop"
       ],
       project: %__MODULE__.CoreKeysStructs.Project{
         record_id: record_id4
       }
     }} =
      assert CoreKeysStructs.builder(%{
               provider: "mishka",
               provider_path: "https://mishka.life",
               project: %{type: "new"},
               different_projects: [
                 %{action: "admin", from_provider: "test"},
                 %{action: "user", from_provider: "test1"},
                 [%{action: "user", from_provider: "test1", from_nothing: "test"}],
                 "develop"
               ]
             })

    get_ids = record_id1 == record_id2 == record_id3 == record_id4

    assert !get_ids
  end

  test "domain parent and parameters domain core key" do
    {:error, :domain_parameters,
     [
       %{
         message: "Based on field username input you have to send authorized data",
         field: :username,
         field_path: "auth.action"
       }
     ]} =
      assert AllowedParentDomain.builder(%{username: "mishka", auth: %{action: "admin1"}})

    {:error, :domain_parameters,
     [
       %{
         message:
           "Based on field username input you have to send authorized data and required key",
         field: :username,
         field_path: "auth.action"
       }
     ]} =
      assert AllowedParentDomain.builder(%{username: "mishka", auth: %{action1: "admin"}})

    {:error, :domain_parameters, _} =
      assert AllowedParentDomain.builder(%{
               username: "mishka",
               auth: %{action: "admin", social: "test"}
             })

    {:ok,
     %__MODULE__.AllowedParentDomain{
       auth: %__MODULE__.AllowedParentDomain.Auth{
         social: :banned,
         action: "admin"
       },
       username: "mishka"
     }} =
      assert AllowedParentDomain.builder(%{
               username: "mishka",
               auth: %{action: "admin", social: :banned}
             })

    {:ok,
     %__MODULE__.AllowedParentDomain{
       auth: %__MODULE__.AllowedParentDomain.Auth{
         type: %{name: "mishka"},
         social: :banned,
         action: "admin"
       },
       type_social: "github",
       username: nil
     }} =
      assert AllowedParentDomain.builder(%{
               type_social: "github",
               auth: %{action: "admin", social: :banned, type: %{name: "mishka"}}
             })

    {:error, :domain_parameters,
     [
       %{
         message: "Based on field type_social input you have to send authorized data",
         field: :type_social,
         field_path: "auth.type"
       }
     ]} =
      assert AllowedParentDomain.builder(%{
               type_social: "github",
               auth: %{action: "admin", social: :banned, type: %{name: "test"}}
             })

    {:ok,
     %__MODULE__.AllowedParentDomain{
       auth: %__MODULE__.AllowedParentDomain.Auth{
         equal: :name,
         type: nil,
         social: :banned,
         action: "admin"
       },
       social_equal: :github,
       type_social: nil,
       username: nil
     }} =
      assert AllowedParentDomain.builder(%{
               social_equal: :github,
               auth: %{action: "admin", social: :banned, equal: :name}
             })

    {:ok,
     %__MODULE__.AllowedParentDomain{
       auth: %__MODULE__.AllowedParentDomain.Auth{
         either: "test",
         equal: nil,
         type: nil,
         social: :banned,
         action: "admin"
       },
       social_either: :github,
       social_equal: nil,
       type_social: nil,
       username: nil
     }} =
      assert AllowedParentDomain.builder(%{
               social_either: :github,
               auth: %{action: "admin", social: :banned, either: "test"}
             })

    {:error, :domain_parameters,
     [
       %{
         message: "Based on field social_either input you have to send authorized data",
         field: :social_either,
         field_path: "auth.either"
       }
     ]} =
      assert AllowedParentDomain.builder(%{
               social_either: :github,
               auth: %{action: "admin", social: :banned, either: 5}
             })

    {:ok,
     %__MODULE__.AllowedParentDomain{
       auth: %__MODULE__.AllowedParentDomain.Auth{
         either: 3,
         equal: nil,
         type: nil,
         social: :banned,
         action: "admin"
       },
       social_either: :github,
       social_equal: nil,
       type_social: nil,
       username: nil
     }} =
      assert AllowedParentDomain.builder(%{
               social_either: :github,
               auth: %{action: "admin", social: :banned, either: 3}
             })
  end

  test "check Custom function inside domain core key" do
    {:ok,
     %__MODULE__.AllowedParentCustomDomain{
       auth: %__MODULE__.AllowedParentCustomDomain.Auth{
         action: "ok"
       },
       username: "mishka"
     }} =
      assert AllowedParentCustomDomain.builder(%{
               username: "mishka",
               auth: %{action: "ok"}
             })

    {:error, :domain_parameters,
     [
       %{
         message: "Based on field username input you have to send authorized data",
         field: :username,
         field_path: "auth.action"
       }
     ]} =
      assert AllowedParentCustomDomain.builder(%{
               username: "mishka",
               auth: %{action: "error"}
             })
  end

  test "call auto core key top of a conditional fields" do
    {:ok,
     %__MODULE__.AllowedParentCustomDomain{
       id: uuid,
       auth: %__MODULE__.AllowedParentCustomDomain.Auth{
         action: "ok"
       },
       username: "mishka"
     }} =
      assert AllowedParentCustomDomain.builder(
               {:root,
                %{
                  username: "mishka",
                  auth: %{action: "ok"}
                }, :edit}
             )

    {:ok,
     %__MODULE__.AllowedParentCustomDomain{
       id: uuid1,
       auth: %__MODULE__.AllowedParentCustomDomain.Auth{
         action: "ok"
       },
       username: "mishka"
     }} =
      assert AllowedParentCustomDomain.builder(%{
               username: "mishka",
               auth: %{action: "ok"}
             })

    {:ok, _uuid} = assert Ecto.UUID.cast(uuid)
    {:ok, _uuid} = assert Ecto.UUID.cast(uuid1)

    # TODO: check the error of :edit
    {:ok,
     %__MODULE__.AllowedParentCustomDomain{
       id: "https://github.com/mishka-group/mishka_developer_tools",
       auth: %__MODULE__.AllowedParentCustomDomain.Auth{
         action: "ok"
       },
       username: "mishka"
     }} =
      assert AllowedParentCustomDomain.builder(
               {:root,
                %{
                  username: "mishka",
                  auth: %{action: "ok"},
                  id: "https://github.com/mishka-group/mishka_developer_tools"
                }, :edit}
             )

    {:ok,
     %__MODULE__.AllowedParentCustomDomain{
       id: "9154b00d-4602-45c2-9562-46a2dcef257f",
       auth: %__MODULE__.AllowedParentCustomDomain.Auth{
         action: "ok"
       },
       username: "mishka"
     }} =
      assert AllowedParentCustomDomain.builder(
               {:root,
                %{
                  username: "mishka",
                  auth: %{action: "ok"},
                  id: "9154b00d-4602-45c2-9562-46a2dcef257f"
                }, :edit}
             )

    {:error, :bad_parameters,
     [
       %{
         field: :id,
         errors: [
           {:bad_parameters,
            [
              %{message: "Unexpected type error in id field", field: :id, action: :type},
              %{message: "Invalid url format in the id field", field: :id, action: :url}
            ], [__hint__: "url_id"]},
           {:bad_parameters,
            [
              %{message: "Invalid UUID format in the id field", field: :id, action: :uuid},
              %{message: "Invalid format in the id field", field: :id, action: :not_empty_string}
            ], [__hint__: "uuid_id"]}
         ],
         action: :conditionals
       }
     ]} =
      assert AllowedParentCustomDomain.builder(
               {:root,
                %{
                  username: "mishka",
                  auth: %{action: "ok"},
                  id: :test
                }, :edit}
             )

    {:error, :bad_parameters,
     [
       %{
         field: :id,
         errors: [
           {:bad_parameters,
            [
              %{
                message: "Is missing a url scheme (e.g. https) in the id field",
                field: :id,
                action: :url
              }
            ], [__hint__: "url_id"]},
           {:bad_parameters,
            [%{message: "Invalid UUID format in the id field", field: :id, action: :uuid}],
            [__hint__: "uuid_id"]}
         ],
         action: :conditionals
       }
     ]} =
      assert AllowedParentCustomDomain.builder(
               {:root,
                %{
                  username: "mishka",
                  auth: %{action: "ok"},
                  id: ":test"
                }, :edit}
             )
  end
end
