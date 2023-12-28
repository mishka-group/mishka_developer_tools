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
      conditional_field(:actor, any()) do
        field(:actor, struct(), struct: Actor, derive: "validate(map, not_empty)")

        conditional_field(:actor, any(),
          structs: true,
          derive: "validate(list, not_empty, not_flatten_empty_item)"
        ) do
          field(:actor, struct(), struct: Actor, derive: "validate(map, not_empty)")

          field(:actor, String.t(), derive: "sanitize(tag=strip_tags) validate(url, max_len=160)")
        end

        field(:actor, String.t(), derive: "sanitize(tag=strip_tags) validate(url, max_len=160)")
      end
    end
  end

  test "nested conditional field with same name" do
  end

  test "call derive on main conditional field to check whole entries" do
  end
end
