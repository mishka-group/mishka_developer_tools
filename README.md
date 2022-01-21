# Mishka Elixir Developer Tools

Recently I have been working on [MishkaCms](https://github.com/mishka-group/mishka-cms), an open-source and free **CMS** for **Elixir** and **Phoenix**. It is very easy to use and has many APIs on both API, and HTML render. In this CMS, I should create some custom macros and modules which are helpful for Elixir developers epically Phoenix **LiveView** fans. Then I test them, and if they are usable, I put them into this project as separated tools.
So when you want to start a project with Elixir, Mishka Developer Tools is an excellent opportunity to finish or start your project as well as possible.

> it should be noted that if you want to test Mishka Developer Tools, please migrate its migrations file; otherwise, you don't need to configure it. The priority is your project database or ORM.

## Installation

The package can be installed by adding `mishka_developer_tools` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mishka_developer_tools, "~> 0.0.3"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/mishka_developer_tools](https://hexdocs.pm/mishka_developer_tools).

---
---
