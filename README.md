# Mishka Elixir Developer Tools

Recently I have been working on [MishkaCms](https://github.com/mishka-group/mishka-cms), an open-source and free **CMS** for **Elixir** and **Phoenix**. It is very easy to use and has many APIs on both API, and HTML render. In this CMS, I should create some custom macros and modules which are helpful for Elixir developers epically Phoenix **LiveView** fans. Then I test them, and if they are usable, I put them into this project as separated tools.
So when you want to start a project with Elixir, Mishka Developer Tools is an excellent opportunity to finish or start your project as well as possible.

> You don't need to configure database for this library. The priority is your project database or ORM.

## Installation

The package can be installed by adding `mishka_developer_tools` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mishka_developer_tools, "~> 0.0.8"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/mishka_developer_tools](https://hexdocs.pm/mishka_developer_tools).

---
---

## Creating basic CRUD
At first, you need to call the `__using__` macro of the Mishka developer tools.

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

# It is optional
@doc delegate_to: {MishkaDeveloperTools.DB.CRUD, :delete, 2}
def delete(id) do
  crud_delete(id)
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