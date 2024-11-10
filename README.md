# Mishka Elixir Developer Tools

<a href="https://www.buymeacoffee.com/mishkagroup" target="_blank">
  <img src="https://img.buymeacoffee.com/button-api/?text=Buy us coffee&emoji=☕&slug=mishkagroup&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff" alt="Buy Me A Coffee" height="50" width="210">
</a>

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
    {:mishka_developer_tools, "~> 0.1.7"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/mishka_developer_tools](https://hexdocs.pm/mishka_developer_tools).

[![Run in Livebook](https://livebook.dev/badge/v1/pink.svg)](https://livebook.dev/run?url=https%3A%2F%2Fgithub.com%2Fmishka-group%2Fmishka_developer_tools%2Fblob%2Fmaster%2Fguidance%2Fguarded-struct.livemd)

---

# Donate

You can support this project through the "[Sponsor](https://github.com/sponsors/mishka-group)" button on GitHub or via cryptocurrency donations. All our projects are **open-source** and **free**, and we rely on community contributions to enhance and improve them further.

| **BTC**                                                                                                                            | **ETH**                                                                                                                            | **DOGE**                                                                                                                           | **TRX**                                                                                                                            |
| ---------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| <img src="https://github.com/mishka-group/mishka_developer_tools/assets/8413604/230ea4bf-7e8f-4f18-99c9-0f940dd3c6eb" width="200"> | <img src="https://github.com/mishka-group/mishka_developer_tools/assets/8413604/0c8e677b-7240-4b0d-8b9e-bd1efca970fb" width="200"> | <img src="https://github.com/mishka-group/mishka_developer_tools/assets/8413604/3de9183e-c4c0-40fe-b2a1-2b9bb4268e3a" width="200"> | <img src="https://github.com/mishka-group/mishka_developer_tools/assets/8413604/aaa1f103-a7c7-43ed-8f39-20e4c8b9975e" width="200"> |

<details>
  <summary>Donate addresses</summary>

**BTC**:‌

```
bc1q24pmrpn8v9dddgpg3vw9nld6hl9n5dkw5zkf2c
```

**ETH**:

```
0xD99feB9db83245dE8B9D23052aa8e62feedE764D
```

**DOGE**:

```
DGGT5PfoQsbz3H77sdJ1msfqzfV63Q3nyH
```

**TRX**:

```
TBamHas3wAxSEvtBcWKuT3zphckZo88puz
```

</details>
