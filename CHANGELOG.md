# Changelog for MishkaDeveloperTools 0.1.7

> Kindly ensure that the macro is updated as quickly as feasible. This version includes a bug patch in the macro kernel that eliminates the issue of not being able to build in projects.

In the past, it was possible to extend validation and sanitizer functions within the macro itself; however, this was a relatively insignificant addition that was ultimately overwritten. The same opportunity will now be available to you if you include environment in the project.

### For example:
```elixir
Application.put_env(:guarded_struct, :validate_derive, [TestValidate, TestValidate2])
Application.put_env(:guarded_struct, :sanitize_derive, [TestSanitize, TestSanitize2])

# OR
Application.put_env(:guarded_struct, :validate_derive, TestValidate)
Application.put_env(:guarded_struct, :sanitize_derive, TestSanitize)
```

I offer my heartfelt apologies for the occurrence of this bug and express my desire to encounter less similar challenges in the future.

# Changelog for MishkaDeveloperTools 0.1.6

### Features:

- [x] Add `Crypto` helper module
- [x] Add new optional dependencies and their wrappers [`nimble_totp`, `joken`, `jason`, `plug`, `bcrypt_elixir`, `pbkdf2_elixir`, `argon2_elixir`]
- [x] Add a normal and basic `validated_password?` function
- [x] Add basic elixir wrapper for erlang queue
- [x] Add new validattion for erlang queue inside `guarded_struct`
- [x] Add some helpers functions for erlang queue

### Improvement:

- [x] Fix and Add compile time check is there geo url module or not
- [x] Support Struct as the builder entry
- [x] Improve some `dialyzer` warning
- [x] General improvements for the new version of Mishka Installer - [Refactor and Rewriting the Mishka installer project with Erlang's built-in databases - 0.1.0](https://github.com/mishka-group/mishka_installer/pull/99)

### Extra:

- [x] Update `ex_doc` dep
- [x] Update Github `CI`
- [x] Delete all ecto deps and custom macro and tests

# Changelog for MishkaDeveloperTools 0.1.5

---

> **The decision was made that this version will be a long-term version, and it will also include features that are several versions behind the existing version. However, because of the pressing issues with the builder's loading speed and the solution to those issues, it was decided to release this version sooner with fewer features than it had originally planned.**

---

### Features:

- [x] Add `condition_field` fields inside `__information__` function
- [x] <del>Inside module derive, in nested struct we can call from `caller`</del>
- [x] Add `uuid` from `ecto`
- [x] Add keys and enforce keys in `__information__` function
- [x] Add some helpers like: `timestamp`, `validated_user?` and validation `username`

### Improvement:

- [x] Speed problem in the derive section, and before this part of app V0.1.4, [#30](https://github.com/mishka-group/mishka_developer_tools/issues/30)
- [x] Fix performance issue inside sanitizer and validation, when we are using external `deps`
- [x] Fix `main_validator` and **halt** the error when we have errors inside `validator` and not load `main_validator`
- [x] Add some information and helper to be compatible for Mnesia (need more in the future)
- [x] Fix bug and Add `NaiveDateTime`, `DateTime`, `Date` struct to map parser

### Extra

- [x] Mnesia wrapper for Elixir, [#28](https://github.com/mishka-group/mishka_developer_tools/issues/28)
- [x] Add Erlang guard convertor for Elixir (simple helper function)
- [x] Add `Mnesia` pagination (infinite_scroll, numerical)
- [x] Add some helper to work with `Mnesia` data

# Changelog for MishkaDeveloperTools 0.1.4

### Features:

- [x] Support whole entries check derives for struct or structs (external module) (**More information**: https://github.com/mishka-group/mishka_developer_tools/issues/26)

- [x] Support `derive` and `validator` on `conditional_field` macro as entries checker
- [x] <del>Support nested conditional fields</del> (**More information**: https://github.com/mishka-group/mishka_developer_tools/issues/25)

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
- [x] Normalize errors `hint`
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
