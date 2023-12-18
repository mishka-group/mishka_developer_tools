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
  end

  test "map conditional field from core key" do
  end

  test "list conditional field from core key" do
  end

  test "normal from auto key" do
  end

  test "map conditional field auto core key" do
  end

  test "list conditional field auto core key" do
  end
end
