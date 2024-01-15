defmodule MishkaDeveloperToolsTest.GuardedStruct.NestedConditionalFieldTest do
  use ExUnit.Case, async: true

  ######### (▰˘◡˘▰) NestedConditionalFieldTest GuardedStructTest Data (▰˘◡˘▰) ##########
  defmodule Actor do
    use GuardedStruct
    @types ["Application", "Group", "Organization", "Person", "Service"]

    guardedstruct do
      field(:id, String.t(), derive: "sanitize(tag=strip_tags) validate(url)")

      field(:type, String.t(),
        derive: "sanitize(tag=strip_tags) validate(enum=String[#{Enum.join(@types, "::")}])",
        default: "Person"
      )

      field(:summary, String.t(),
        enforce: true,
        derive: "sanitize(tag=strip_tags) validate(not_empty_string, max_len=364, min_len=3)"
      )
    end
  end

  defmodule Conditional do
    use GuardedStruct

    guardedstruct do
      conditional_field(:actor, any(), hint: "001-0-map") do
        field(:actor, struct(),
          struct: Actor,
          derive: "validate(map, not_empty)",
          hint: "001-1-map",
          validator: {ConditionalFieldValidatorTestValidators, :is_map_data}
        )

        field(:actor, String.t(),
          derive: "sanitize(tag=strip_tags) validate(url, max_len=160)",
          hint: "001-2-url",
          validator: {ConditionalFieldValidatorTestValidators, :is_string_data}
        )

        # conditional_field
        conditional_field(:actor, any(),
          structs: true,
          derive: "validate(list, not_empty, not_flatten_empty_item)",
          hint: "002-0-list",
          validator: {ConditionalFieldValidatorTestValidators, :is_list_data}
        ) do
          field(:actor, struct(),
            struct: Actor,
            derive: "validate(map, not_empty)",
            hint: "002-1-map",
            validator: {ConditionalFieldValidatorTestValidators, :is_map_data}
          )

          field(:actor, String.t(),
            derive: "sanitize(tag=strip_tags) validate(url, max_len=160)",
            hint: "002-2-url",
            validator: {ConditionalFieldValidatorTestValidators, :is_string_data}
          )

          # conditional_field
          conditional_field(:actor, any(),
            derive: "validate(list, not_empty, not_flatten_empty_item)",
            hint: "003-0-list",
            validator: {ConditionalFieldValidatorTestValidators, :is_list_data},
            structs: true
          ) do
            field(:actor, struct(),
              struct: Actor,
              derive: "validate(map, not_empty)",
              hint: "003-1-map",
              validator: {ConditionalFieldValidatorTestValidators, :is_map_data}
            )

            field(:actor, String.t(),
              derive: "sanitize(tag=strip_tags) validate(url, max_len=160)",
              hint: "003-1-url",
              validator: {ConditionalFieldValidatorTestValidators, :is_string_data}
            )
          end
        end
      end
    end
  end

  test "nested conditional field with same name" do
    Conditional.builder(%{
      actor: [
        [
          %{id: "https://github.com", type: "Organization", summary: "To DEv"},
          "https://yahoo.com"
        ],
        "https://google.com"
      ]
    })
    |> IO.inspect()
  end

  test "call derive on main conditional field to check whole entries" do
  end

  test "call validator on main conditional field to check whole entries" do
  end

  test "call main validator on main conditional field to check whole entries" do
  end
end
