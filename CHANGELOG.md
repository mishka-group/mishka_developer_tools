# Changelog for MishkaDeveloperTools 0.1.1

- [x] Add `derive` for sanitizing and validating `Either`
- [x] Add `derive` for sanitizing and validating `equal`
- [x] Add `exception` when macro is configed for `error: true`, only can be called inside `sub_field` and `guardedstruct` macro
- [x] Add `authorized_fields` validating option for `sub_field` and `guardedstruct` macro
- [x] Calling a struct from another module
- [x] Calling list of structs from another module
- [x] Add capability of having a `field` with list of structs
- [x] Add capability of having a `sub_field` with list of structs

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
