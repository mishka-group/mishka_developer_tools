defmodule MishkaDeveloperTools do
  @moduledoc """
  # Mishka Elixir Developer Tools

  We tried to deliver a series of our client's [**CMS**](https://github.com/mishka-group/mishka-cms) built on
  [**Elixir**](https://elixir-lang.org/) at the start of the [**Mishka Group**](https://github.com/mishka-group) project,
  but we recently archived this open-source project and have yet to make plans to rework and expand it.
  This system was created using [**Phoenix**](https://www.phoenixframework.org/) and
  [**Phoenix LiveView**](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html).
  After a long period, a series of macros and functional modules emerged from this
  project and our other projects, which we are gradually publishing in this library.

  > **NOTICE**: Do not use the master branch; this library is under heavy development.
  Expect version `0.1.2`, and for using the new features, please wait until a new release is out.
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
  """
end
