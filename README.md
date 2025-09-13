# Mishka Elixir Developer Tools

<div align="center">
  <pre style="display: inline-block; text-align: left;">
    💖 Hey there! If you like my work, please <b><a href="https://github.com/sponsors/mishka-group">support me financially!</a></b> 💖
  </pre>
</div>

<br />

<p align="center">
  <a href="https://www.buymeacoffee.com/mishkagroup">
    <img src="https://github.com/user-attachments/assets/f4d4df7e-dcc4-4d1a-80e1-59c4d99725ab" alt="Support Mishka by Buy Me a Coffee" />
  </a>
</p>

## Low Maintenance Warning:

> **This library is in low maintenance mode, which means the author is currently only responding to pull requests.**

We tried to deliver a series of our client's [**CMS**](https://github.com/mishka-group/mishka-cms) built on [**Elixir**](https://elixir-lang.org/) at the start of the [**Mishka Group**](https://github.com/mishka-group) project, but we recently archived this open-source project and have yet to make plans to rework and expand it. This system was created using [**Phoenix**](https://www.phoenixframework.org/) and [**Phoenix LiveView**](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html). After a long period, a series of macros and functional modules emerged from this project and our other projects, which we are gradually publishing in this library.

> **NOTICE**: Do not use the master branch; this library is under heavy development. Expect version `0.1.7`, and for using the new features, please wait until a new release is out.

---

- ### [GuardedStruct](https://github.com/mishka-group/guarded_struct)

  **We recently separated the [GuardedStruct](https://github.com/mishka-group/guarded_struct) macro into a standalone library. Please visit its repository for more information.**

  > The creation of this macro will allow you to build `Structs` that provide you with a number of important options, including the following:
  >
  > 1. Validation
  > 2. Sanitizing
  > 3. Constructor
  > 4. It provides the capacity to operate in a nested style simultaneously.

- ### [PermissionAccess](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/permission-access.md)

> Consider the scenario in which you are responsible for maintaining each user's access level in the database related to users.
> **It is unix like way**.

---

> **Mishka developer tools** provides some macros and modules to make creating your elixir application as easy as possible

## Installation

The package can be installed by adding `mishka_developer_tools` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mishka_developer_tools, "~> 0.1.9"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/mishka_developer_tools](https://hexdocs.pm/mishka_developer_tools).

[![Run in Livebook](https://livebook.dev/badge/v1/pink.svg)](https://livebook.dev/run?url=https%3A%2F%2Fgithub.com%2Fmishka-group%2Fmishka_developer_tools%2Fblob%2Fmaster%2Fguidance%2Fguarded-struct.livemd)

---

# Donate

You can support this project through the "[Sponsor](https://github.com/sponsors/mishka-group)" button on GitHub donations. All our projects are **open-source** and **free**, and we rely on community contributions to enhance and improve them further.
