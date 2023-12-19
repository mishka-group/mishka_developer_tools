# Mishka Elixir Developer Tools

We tried to deliver a series of our client's [**CMS**](https://github.com/mishka-group/mishka-cms) built on [**Elixir**](https://elixir-lang.org/) at the start of the [**Mishka Group**](https://github.com/mishka-group) project, but we recently archived this open-source project and have yet to make plans to rework and expand it. This system was created using [**Phoenix**](https://www.phoenixframework.org/) and [**Phoenix LiveView**](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html). After a long period, a series of macros and functional modules emerged from this project and our other projects, which we are gradually publishing in this library.

> **NOTICE**: Do not use the master branch; this library is under heavy development. Expect version `0.1.2`, and for using the new features, please wait until a new release is out.

---

- #### [GuardedStruct](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md)

- #### [Basic CRUD](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/crud.md)

- #### [PermissionAccess](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/permission-access.md)

---

> Mishka developer tools provides some macros and modules to make creating your elixir application as easy as possible


## Installation

The package can be installed by adding `mishka_developer_tools` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mishka_developer_tools, "~> 0.1.2"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/mishka_developer_tools](https://hexdocs.pm/mishka_developer_tools).


---
# Donate

If the project was useful for you, the only way you can donate to me is the following ways

| **BTC**                           | **ETH**                           | **DOGE**                          | **TRX**                           |
| ----------------------------------| --------------------------------- | --------------------------------- | --------------------------------- |
| <img src="https://private-user-images.githubusercontent.com/8413604/267389452-230ea4bf-7e8f-4f18-99c9-0f940dd3c6eb.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTEiLCJleHAiOjE3MDI5NzUxNjYsIm5iZiI6MTcwMjk3NDg2NiwicGF0aCI6Ii84NDEzNjA0LzI2NzM4OTQ1Mi0yMzBlYTRiZi03ZThmLTRmMTgtOTljOS0wZjk0MGRkM2M2ZWIucG5nP1gtQW16LUFsZ29yaXRobT1BV1M0LUhNQUMtU0hBMjU2JlgtQW16LUNyZWRlbnRpYWw9QUtJQUlXTkpZQVg0Q1NWRUg1M0ElMkYyMDIzMTIxOSUyRnVzLWVhc3QtMSUyRnMzJTJGYXdzNF9yZXF1ZXN0JlgtQW16LURhdGU9MjAyMzEyMTlUMDgzNDI2WiZYLUFtei1FeHBpcmVzPTMwMCZYLUFtei1TaWduYXR1cmU9Nzk4NTVhZDdmNjcyNTdmZTFkMmNkYWE0M2M5NTIzNWUwMTIxYmY4MDgwZmMxMDA3OWExM2I2ZWUwMmNjNTg1YiZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QmYWN0b3JfaWQ9MCZrZXlfaWQ9MCZyZXBvX2lkPTAifQ.GEODKQTZOLMeoiIsk6vQSNJ2loNvj0e1H2PLH0f_yFk" width="150">| <img src="https://private-user-images.githubusercontent.com/8413604/267390885-0c8e677b-7240-4b0d-8b9e-bd1efca970fb.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTEiLCJleHAiOjE3MDI5NzUxNjYsIm5iZiI6MTcwMjk3NDg2NiwicGF0aCI6Ii84NDEzNjA0LzI2NzM5MDg4NS0wYzhlNjc3Yi03MjQwLTRiMGQtOGI5ZS1iZDFlZmNhOTcwZmIucG5nP1gtQW16LUFsZ29yaXRobT1BV1M0LUhNQUMtU0hBMjU2JlgtQW16LUNyZWRlbnRpYWw9QUtJQUlXTkpZQVg0Q1NWRUg1M0ElMkYyMDIzMTIxOSUyRnVzLWVhc3QtMSUyRnMzJTJGYXdzNF9yZXF1ZXN0JlgtQW16LURhdGU9MjAyMzEyMTlUMDgzNDI2WiZYLUFtei1FeHBpcmVzPTMwMCZYLUFtei1TaWduYXR1cmU9YTJlN2UxNzQ4NWM3ZTIyMmVkMmY0ZjcyOGIxODc0M2UyOTYxOWNiMzE5YTMzMjkyZGY4YjhmYTZhMWU4MDNiZCZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QmYWN0b3JfaWQ9MCZrZXlfaWQ9MCZyZXBvX2lkPTAifQ.RWx5mFeurgxhc-oUtUgN5d-tRj42l0gBuiwJ68NG0Xk" width="150">|<img src="https://private-user-images.githubusercontent.com/8413604/267391028-3de9183e-c4c0-40fe-b2a1-2b9bb4268e3a.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTEiLCJleHAiOjE3MDI5NzUxNjYsIm5iZiI6MTcwMjk3NDg2NiwicGF0aCI6Ii84NDEzNjA0LzI2NzM5MTAyOC0zZGU5MTgzZS1jNGMwLTQwZmUtYjJhMS0yYjliYjQyNjhlM2EucG5nP1gtQW16LUFsZ29yaXRobT1BV1M0LUhNQUMtU0hBMjU2JlgtQW16LUNyZWRlbnRpYWw9QUtJQUlXTkpZQVg0Q1NWRUg1M0ElMkYyMDIzMTIxOSUyRnVzLWVhc3QtMSUyRnMzJTJGYXdzNF9yZXF1ZXN0JlgtQW16LURhdGU9MjAyMzEyMTlUMDgzNDI2WiZYLUFtei1FeHBpcmVzPTMwMCZYLUFtei1TaWduYXR1cmU9MDc1YzExY2EyZTZjYzU2NzgxZmY1MWY2MTdkNDcyYmZiNzQyNjVjOTllMDAzYTYyM2NmYzdlZmNjY2M1MmVhMCZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QmYWN0b3JfaWQ9MCZrZXlfaWQ9MCZyZXBvX2lkPTAifQ.unf6DSzDupzFVNwwX80CT_p3SL3mbmVsSvH3rCqKhHc" width="150">|<img src="https://private-user-images.githubusercontent.com/8413604/267392752-aaa1f103-a7c7-43ed-8f39-20e4c8b9975e.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTEiLCJleHAiOjE3MDI5NzUxNjYsIm5iZiI6MTcwMjk3NDg2NiwicGF0aCI6Ii84NDEzNjA0LzI2NzM5Mjc1Mi1hYWExZjEwMy1hN2M3LTQzZWQtOGYzOS0yMGU0YzhiOTk3NWUucG5nP1gtQW16LUFsZ29yaXRobT1BV1M0LUhNQUMtU0hBMjU2JlgtQW16LUNyZWRlbnRpYWw9QUtJQUlXTkpZQVg0Q1NWRUg1M0ElMkYyMDIzMTIxOSUyRnVzLWVhc3QtMSUyRnMzJTJGYXdzNF9yZXF1ZXN0JlgtQW16LURhdGU9MjAyMzEyMTlUMDgzNDI2WiZYLUFtei1FeHBpcmVzPTMwMCZYLUFtei1TaWduYXR1cmU9ZWYxMTIzODc1NzQ5YzZhOTczYjM0Y2I0MjMwYzViZTQ3ZDI0ZjdkODkzMjAxNzQxODg4NDFiOTM2MzY5MjBhMCZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QmYWN0b3JfaWQ9MCZrZXlfaWQ9MCZyZXBvX2lkPTAifQ.1MxGRvcMvw6koP-Jfen52EpQ_WGvYHeHZz0BBZxino0" width="150">|

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



