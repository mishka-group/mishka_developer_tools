# Changelog for MishkaDeveloperTools 0.1.4

### Features:

- [x] Support whole entries check derives for struct or structs (external module)
> **More information**: https://github.com/mishka-group/mishka_developer_tools/issues/26

- [x] Support `derive` and `validator` on `conditional_field` macro as entries checker
- [x] <del>Support nested conditional fields</del>
> **More information**: https://github.com/mishka-group/mishka_developer_tools/issues/25

```elixir
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
```

### Fixed bugs:

- [x] Fix showing different errors when they accompany a conditional errors
- [x] Fix short anonymous function warning in elixir 1.16
- [x] Support pre-check derives inside conditional fields
- [x] Normalize conditional fields errors
- [x] Normalize validator errors
- [x] Normalize  errors `hint`
- [x] Normalize `derives` errors
- [x] Fix `dialyzer` warning
- [x] Support derive in normal conditional field without validator
```elixir
conditional_field(:id, String.t()) do
  field(:id, String.t(), derive: "sanitize(tag=strip_tags) validate(url, max_len=160)")
  field(:id, any(), derive: "sanitize(tag=strip_tags) validate(not_empty_string, uuid)")
end
```

### Docs

- [x] Add LiveBook


# Changelog for MishkaDeveloperTools 0.1.3

**Features**:
- [x] Support List `conditional_field`
```elixir
"actor": [
  "http://joe.example.org",
  {
    "type": "Person",
    "id": "http://sally.example.org",
    "name": "Sally"
  },
  :test
]
```
- [x] Covering `hint` inside derive `conditional_field` and normal `derive`
- [x] Support `domain` key inside children fields
- [x] Support new derives: `not_flatten_empty`, `not_flatten_empty_item` as validation
- [x] Support `not_empty` and `max_len`, `min_len` for list in validation derive.

**Fixed bugs**:
- [x] Fix and Remove `downcase` bug in `strip_tags`
- [x] Fix and Remove preventer of calling a `struct` inside itself
- [x] Fix domain core key to prevent it not to check domain when the key is `nil`

**Improvements**:
- [x] Changing the structure of on core key based on the value of the caller
- [x] Support calling struct inside itself
- [x] Separate all test of `GuardedStruct` macro in different files
- [x] Add `dialyzer` for GuardedStruct macro

# Changelog for MishkaDeveloperTools 0.1.2

---
- [x] Solving the problem of creating extra `atom` in case of a mistake or an attack on the system. It could be a `security` issue, please update.
---

- [x] Add allowed parent domain core key `Enum` derive style
- [x] Add allowed parent domain core key `either` derive style
- [x] Add allowed parent domain core key `equal` derive style
- [x] Add allowed parent domain core key `custom` derive style
- [x] Add driver for accepting `custom` function
- [x] Add status to auto core key if the data of key exists do not create auto value
- [x] Add Conditional field structure `macro` (**Multiple states of a field**)
- [x] Add Supporting new `Typespecs` for `list(struct())` and previous one `struct()`
- [x] Add Supporting new sanitizer for `:string_float`
- [x] Add Supporting new validation for `:string_float`
- [x] Add Supporting new validation for `:some_string_float`


# Changelog for MishkaDeveloperTools 0.1.1

- [x] Add `derive` for sanitizing and validating `Either`
- [x] Add `derive` for sanitizing and validating `Enum`, improved
- [x] Add `derive` for sanitizing and validating `equal`
- [x] Add `exception` when macro is configed for `error: true`, only can be called inside `sub_field` and `guardedstruct` macro
- [x] Add `authorized_fields` validating option for `sub_field` and `guardedstruct` macro
- [x] Calling a struct from another module
- [x] Calling list of structs from another module
- [x] Add capability of having a `field` with list of structs
- [x] Add capability of having a `sub_field` with list of structs
- [x] Add Automatic generator for a specific key `on`
- [x] Add a dependent key to another key `auto`
- [x] Add a key to get a value from another key `from`
- [x] Add struct information function
- [x] Add transmitting whole output of builder function to its children
- [x] Add new style of builder entries to accept tuple with keys
- [x] Add `auto`, `on`, `from` core keys for list of structs
- [x] Re-structured outputs for new capabilities with backward compatibility
- [x] Add permission access module in runtime


# Changelog for MishkaDeveloperTools 0.1.0

- [x] Add Guardedstruct macro
- [x] Support nested struct in macro
- [x] Add `derive` for Validation and Sanitization
- [x] Add custom validator and main validator
- [x] Add custom validator and main validator from finding in a module
- [x] Add `__struct__`, `keys`, `enforce_keys` and `builder` functions
- [x] Add `required_fields` validation with `:halt` status
- [x] Add calling nested fields and struct from another module
- [x] Add `Derive.Parser.convert_to_atom_map` to Change string map to atom map
- [x] Add `derive` for sanitizing and validating `Trim`
- [x] Add `derive` for sanitizing and validating `Lowercase`
- [x] Add `derive` for sanitizing and validating `Uppercase`
- [x] Add `derive` for sanitizing and validating `Max` length
- [x] Add `derive` for sanitizing and validating `Min` length
- [x] Add `derive` for sanitizing and validating Safe String `false` or `true` value
- [x] Add `derive` for sanitizing and validating `Email`
- [x] Add `derive` for sanitizing and validating `Location`
- [x] Add `derive` for sanitizing and validating `Date`
- [x] Add `derive` for sanitizing and validating `DateTime`
- [x] Add `derive` for sanitizing and validating `basic_html` sanitize
- [x] Add `derive` for sanitizing and validating `html5` sanitize
- [x] Add `derive` for sanitizing and validating `markdown_html` sanitize
- [x] Add `derive` for sanitizing and validating `strip_tags` sanitize
- [x] Add `derive` for sanitizing and validating `Regex` runner
- [x] Add `derive` for sanitizing and validating `Range`
- [x] Add `derive` for sanitizing and validating Validate `URL`
- [x] Add `derive` for sanitizing and validating Validate `IPV4`
- [x] Add `derive` for sanitizing and validating Validate `Enum`
- [x] Add `derive` for sanitizing and validating Validate `Tag`
- [x] Add `derive` for sanitizing and validating Validate `UUID`
- [x] Add `derive` for sanitizing and validating Validate `Not empty string`
- [x] Add `derive` for sanitizing and validating Validate `Equal`
- [x] Add a `:halt` error to filter validations output from showing after `halt` error
- [x] Update all dependencies to last version
- [x] Fix tests for Elixir `1.15`
- [x] Make all dependencies optional based on user requirements
- [x] improve documents

# Changelog for MishkaDeveloperTools 0.0.8

- [x] Improve CRUD macro `callbacks` and `specs` return for `dialyzer`
- [x] Add new delete macro and function
- [x] Support UUID and the other type of ID
- [x] Improve testing
- [x] Improving and updating the coding structure
