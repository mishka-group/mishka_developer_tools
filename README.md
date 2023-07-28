# Mishka Elixir Developer Tools

Recently I have been working on [MishkaCms](https://github.com/mishka-group/mishka-cms), an open-source and free **CMS** for **Elixir** and **Phoenix**. It is very easy to use and has many APIs on both API, and HTML render. In this CMS, I should create some custom macros and modules which are helpful for Elixir developers epically Phoenix **LiveView** fans. Then I test them, and if they are usable, I put them into this project as separated tools.
So when you want to start a project with Elixir, Mishka Developer Tools is an excellent opportunity to finish or start your project as well as possible.


## Installation

The package can be installed by adding `mishka_developer_tools` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mishka_developer_tools, "~> 0.1.0"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/mishka_developer_tools](https://hexdocs.pm/mishka_developer_tools).

---

## Creating GuardedStruct

In the first stage, this module builds a struct with the `t()` type for you. Then, you can use various auxiliary functions, including `builder,` which is a function for creating tuples with error handling. It should be noted that this helper function verifies the required fields and each field's validation before passing the output to the parent validation as the `main_validator` function, which, if there isn't one, delivers a successful output.
This was a feature of the `macro`; you may now utilize the predefined `sanitizers` and `validations` of this library.

> This section is called Derive and is inspired by great libraries in programming languages such as Rust and Scala. For more information click [here](https://github.com/mishka-group/mishka_developer_tools/issues/14).

> The code in this macro is based on the **`typed_struct`** library (https://github.com/ejpcmac/typed_struct), which is licensed under the MIT License. Unfortunately, the original creator of this library no longer updates it and it has been fully abandoned. This macro is built from the code of this project and then entirely altered.

### Examples

```elixir
defmodule MyStruct do
  use GuardedStruct

  guardedstruct main_validator: {Validator, :main_validator} do
    field :field_one, String.t(), validator: {Validator, :validator}
    field :field_two, integer(), enforce: true
    field :field_three, boolean(), enforce: true
    field :field_four, atom(), default: :mishka_group
  end
end
```

OR

```elixir
defmodule MyStruct do
  use GuardedStruct

  guardedstruct enforce: true, main_validator: {Validator, :main_validator} do
    field :field_one, String.t(), derive: "sanitize(trim, lowercase) validate(not_empty, max_len = 20)"
    field :field_two, integer()
    field :field_three, boolean(), validator: {Validator, :validator}
    field :field_four, atom(), default: :mishka_group,
      validator: {Validator, :validator}, , derive: "sanitize(trim) validate(not_empty)"
  end
end
```

> This macro offers several choices, such as `HTML` sanitizer or generating a structure in the child module, which can all be found in the dedicated paper for this possibility at https://hexdocs.pm/mishka_developer_tools.

---

## Creating basic CRUD
At first, you need to call the `__using__` macro of the Mishka developer tools.

> You don't need to configure database for this library. The priority is your project database or ORM.

```elixir
 use MishkaDeveloperTools.DB.CRUD,
    module: YOUR_SCHEMA_MODULE,
    repo: YOUR_REPO_MODULE,
    id: :uuid OR ANY_TYPE_YOU_WANT
```

And after that, you can define `@behaviour`; it is optional.
```elixir
 @behaviour MishkaDeveloperTools.DB.CRUD
```

Now is the time you can have your CRUD function; it should be noted you are not forced to use these macros under functions.


```elixir
@doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :create, 1}
def create(attrs) do
  crud_add(attrs)
end

@doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :create, 1}
def create(attrs, allowed_fields) do
  crud_add(attrs, allowed_fields)
end

@doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :edit, 1}
def edit(attrs) do
  crud_edit(attrs)
end

@doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :edit, 1}
def edit(attrs, allowed_fields) do
  crud_edit(attrs, allowed_fields)
end

@doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :delete, 1}
def delete(id) do
  crud_delete(id)
end

# It is optional, list of tables name can be the assoc parameter
@doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :delete, 2}
def delete(id, assoc) do
  crud_delete(id, assoc)
end

# It is optional
@doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :show_by_id, 1}
def show_by_id(id) do
  crud_get_record(id)
end

# It is optional
@doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :show_by_field, 1}
def show_by_field(field) do
  crud_get_by_field("field", field)
end
```
