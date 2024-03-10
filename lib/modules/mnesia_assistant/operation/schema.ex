defmodule MnesiaAssistant.Schema do
  @moduledoc """
  This module not only provides a number of tools to better cover a real project,
  but it also organises functions linked to Schema in a single location.
  """
  alias :mnesia, as: Mnesia

  @doc """
  By means of this function, you can see information about `Schema`.
  It should be noted that this function is the same as the
  `MnesiaAssistant.Information.info/1` function with the `:schema` input.

  ### Example:

  ```elixir
    MnesiaAssistant.Schema.schema()
    # OR
    MnesiaAssistant.Schema.schema(table)
  ```
  """
  def schema(), do: Mnesia.schema()

  def schema(table), do: Mnesia.schema(table)

  @doc """
  You will need to establish a `schema` in order to begin utilising `Mnesia`
  in a project; this function will automatically create the schema for you.

  > Note that prior to the creation of the schema, it is necessary
  > to determine whether or not the storage path that was introduced
  > by the configuration already exists. Assuming that it does not already exist,
  > this path ought to be made. see more information `create_dir()/0`

  ### Example:

  ```elixir
    MnesiaAssistant.Schema.create_schema([node()])
  ```
  """
  def create_schema(nodes \\ [node()]) when is_list(nodes), do: Mnesia.create_schema([node()])

  @doc """
  In the same way that you are able to generate a schema for a particular node,
  you are also able to delete it from your project.

  ### Example:

  ```elixir
    MnesiaAssistant.Schema.delete_schema([node()])
  ```
  """
  def delete_schema(nodes \\ [node()]), do: Mnesia.delete_schema(nodes)

  @doc """
  In Mnesia, the concept of `checkpoints` as it might be understood in other
  database systems (specific points in time to which you can revert the database state)
  is not directly exposed through a simple API call like `:mnesia.activate_checkpoint`.
  Mnesia's model for data recovery, consistency, and fault tolerance is built
  around its transactional model, replication, and `backup`/`restore` functionalities.

  ```erlang
   {name, Name}
   | {max, [table()]}
   | {min, [table()]}
   | {allow_remote, boolean()}
   | {ram_overrides_dump, boolean()}
  ```

  ### Example:

  ```elixir
    MnesiaAssistant.Schema.activate_checkpoint(args)
  ```
  """
  def activate_checkpoint(args) when is_list(args), do: Mnesia.activate_checkpoint(args)

  @doc """
  For deactivating `activate_checkpoint/1`.

  ### Example:

  ```elixir
    MnesiaAssistant.Schema.deactivate_checkpoint(name)
  ```
  """
  def deactivate_checkpoint(name), do: Mnesia.deactivate_checkpoint(name)

  @doc """
  Using the `mnesia` configuration, this straightforward method will assist
  you in determining whether or not the path that you have supplied is present.
  When it does not already exist, it develops it.

  ### Example:

  ```elixir
    MnesiaAssistant.Schema.create_dir()
  ```
  """
  def create_dir() do
    path = Application.get_env(:mnesia, :dir)

    with true <- !is_nil(path), false <- File.dir?(path) do
      :ok = File.mkdir_p!(path)
    end
  end
end
