defmodule MnesiaAssistant do
  @moduledoc """
  `MnesiaAssistant` is a wrapper for the Mnesia (Top level Erlang runtime database, ETS) module.
  Its primary purpose is to facilitate the utilisation of this database in Elixir.
  Additionally, it offers a number of features, such as the standardisation of
  the output and routes, as well as various hooks and helpers in this particular domain.

  The following is a list of the primary modules that you plan on using in your project:

  1. `MnesiaAssistant.Schema`
  2. `MnesiaAssistant.Table`
  3. `MnesiaAssistant.Query`
  4. `MnesiaAssistant.Transaction`
  5. `MnesiaAssistant.Information`
  6. `MnesiaAssistant.BackupAndRestore`
  """

  require Logger
  alias MnesiaAssistant.{Information, Schema}
  alias MishkaDeveloperTools.Helper.Extra
  alias MnesiaAssistant.Error, as: MError
  alias :mnesia, as: Mnesia

  ################################################################
  ######################### Public Apis ##########################
  ################################################################

  ################# Global functions Public Apis #################
  @doc """
  In order to fulfil the requirements of the **Elixir** project,
  it is necessary for you to activate this database in
  addition to executing the `mnesia` function within the `mix.exs` file.
  Both activation and information for determining whether or not it is
  active are accomplished through the utilisation of these functions.

  Two distinct variants of this function have been generated for your use.
  It is important to note that the `start/0` function is a wrapper
  from Erlang, while the second function is responsible for activating
  `mnesia` in Elixir (`start/1` :: `:app`).

  > In order to activate programmes, we utilise the `start/1` command with
  > the input `:app`.

  ### Example

  ```elixir
    MnesiaAssistant.start() # --> :mnesia.start()
    # OR
    MnesiaAssistant.start(:app) # --> Application.start(:mnesia)
  ```
  """
  def start(), do: Mnesia.start()

  @doc """
  Read `start/0` document.
  """
  def start(:app), do: Application.start(:mnesia)

  @doc false
  def start(mode, dir, identifier) do
    Logger.warning(
      "Identifier: #{inspect(identifier)} ::: MnesiaMessage: Mnesia's initial valuation process has begun."
    )

    stop() |> MError.error_description()
    mnesia_dir = dir <> "/#{mode}"
    File.mkdir_p(mnesia_dir) |> MError.error_description(identifier)
    Application.put_env(:mnesia, :dir, mnesia_dir |> to_charlist)
    MnesiaAssistant.Schema.create_schema([node()]) |> MError.error_description(identifier)
    start() |> MError.error_description(identifier)
  end

  @doc """
  The `mnesia` database provides you with the capability to perform your storage
  either on the hard drive or on the RAM, or both at the same time, depending
  on the software approach that you have chosen. In order to accomplish this goal,
  its path for storage on the disc (the position of storage) must be known.
  This can be accomplished in a number of different ways.

  You can begin the compilation process by using the configuration file of
  your programme. In this technique, you will need to specify the directory
  for the `:mnesia` (`:dir`) command. And then there is the second technique,
  which is the function of the same function and is carried out in the form of run time.

  ### Example

  ```elixir
    MnesiaAssistant.set_dir("/tmp/db") # --> Application.put_env(:mnesia, :dir, dir)
  ```
  """
  def set_dir(dir), do: Application.put_env(:mnesia, :dir, dir)

  @doc """
  You have the ability to disable mnesia by using the function.
  In the same way that the `start/0` function has two forms,
  this function also has two forms. One of the forms is a wrapper
  for the `mnesia` function itself, while the other form disables
  the `mnesia` **Elixir** red applications that have been active.

  ### Example

  ```elixir
    MnesiaAssistant.stop() # --> :mnesia.stop()
    # OR
    MnesiaAssistant.stop(:app) # --> Application.stop(:mnesia)
  ```
  """
  def stop(), do: Mnesia.stop()

  @doc """
  Read `stop/1` document.
  """
  def stop(:app), do: Application.stop(:mnesia)

  @doc """
  This function determines whether or not the `mnesia` function is active.
  The output of the `Application.started_applications()` function
  is what this function actually searches for.

  ### Example

  ```elixir
    MnesiaAssistant.started?()
  ```
  """
  def started?(), do: Extra.app_started?(:mnesia)

  ############### Information functions Public Apis ###############
  defdelegate info(), to: Information

  defdelegate info(type), to: Information

  defdelegate set_debug_level(level), to: Information

  defdelegate schema(), to: Schema

  defdelegate schema(table), to: Schema

  defdelegate eg(operation), to: Extra, as: :erlang_guard

  defdelegate er(operation), to: Extra, as: :erlang_result

  defdelegate erl_fields(tuple, fields, keys, num), to: Extra, as: :erlang_fields
  ############### Global functions Public Apis ###############
  # Ref: https://www.erlang.org/doc/apps/mnesia/mnesia_chap5#mnesia-event-handling
  # system | activity | {table, table(), simple | detailed}
  @doc """
  Using this function, you will be able to subscribe to Mnesia's activities
  and events, and you will receive notifications immediately after an
  event takes place. For example, if you are using `GenServer` and you want
  to carry out a particular activity in real time based on a strategy, you can
  make use of this method.

  ### Example

  ```elixir
    MnesiaAssistant.subscribe({:table, Person})
    # -> :mnesia.subscribe({:table, table})
    MnesiaAssistant.subscribe({:table, Person, simple_detailed})
    # -> :mnesia.subscribe({:table, table, simple_detailed})
    MnesiaAssistant.subscribe(what)
    # -> :mnesia.subscribe(what)
    # What = system | activity | {table, table(), simple | detailed}
  ```
  """
  def subscribe({:table, table, simple_detailed}),
    do: Mnesia.subscribe({:table, table, simple_detailed})

  def subscribe(what), do: Mnesia.subscribe(what)

  @doc """
  In order to terminate your subscription to mnesia, you can use the following function.
  For more information read `subscribe/1`

  ### Example

  ```elixir
  MnesiaAssistant.unsubscribe({:table, Person})
  # -> :mnesia.unsubscribe({:table, table})
  MnesiaAssistant.unsubscribe({:table, Person, simple_detailed})
  # -> :mnesia.unsubscribe({:table, table, simple_detailed})
  MnesiaAssistant.unsubscribe(what)
  # -> :mnesia.unsubscribe(what)
  # What = system | activity | {table, table(), simple | detailed}
  ```
  """
  def unsubscribe({:table, table, simple_detailed}),
    do: Mnesia.unsubscribe({:table, table, simple_detailed})

  def unsubscribe(what), do: Mnesia.unsubscribe(what)

  @doc """
  When tracing a system of Mnesia applications it is useful to be able to
  interleave Mnesia own events with `application-related` events that give
  information about the application context.

  Whenever the application begins a new and demanding Mnesia task,
  or if it enters a new interesting phase in its execution, it can be a good idea
  to use mnesia:report_event/1. Event can be any term and generates
  a `{mnesia_user, Event}` event for any processes that subscribe
  to Mnesia system events. for more information read `subscribe/1` document.

  ### Example:

  ```elixir
  MnesiaAssistant.report_event(event)
  ```
  """
  def report_event(event), do: Mnesia.report_event(event)

  @doc """
  The `:mnesia.change_config/2` function in Mnesia, the distributed database management
  system in Erlang/OTP, is used to dynamically change the configuration parameters
  of the Mnesia system while it is running.

  This function allows you to adjust certain operational parameters of Mnesia
  without needing to stop and restart the database,
  making it particularly useful for tuning performance or behavior in live systems.

  * `config`: --> extra_db_nodes | dc_dump_limit
  * `value`: -->  [node()] | number()

  ### Example

  ```elixir
    MnesiaAssistant.change_config(config, value)
  ```
  """
  def change_config(config, value) when config in [:extra_db_nodes, :dc_dump_limit],
    do: Mnesia.change_config(config, value)

  ################# Global Helper Public Apis #################
  def tuple_to_map(:"$end_of_table", _fields, _drop), do: []

  def tuple_to_map({records, cont}, fields, drop), do: {tuple_to_map(records, fields, drop), cont}

  def tuple_to_map(records, fields, drop) do
    Enum.reduce(records, [], fn item, acc ->
      converted =
        Enum.zip(fields, Tuple.delete_at(item, 0) |> Tuple.to_list())
        |> Enum.into(%{})
        |> Map.drop(drop)

      acc ++ [converted]
    end)
  end

  def tuple_to_map(:"$end_of_table", _fields, _, _drop), do: []

  def tuple_to_map(records, fields, nil, drop), do: tuple_to_map(records, fields, drop)

  def tuple_to_map({records, cont}, fields, strc, drop) do
    {tuple_to_map(records, fields, strc, drop), cont}
  end

  def tuple_to_map(records, fields, strc, drop) do
    Enum.reduce(records, [], fn item, acc ->
      converted =
        Enum.zip(fields, Tuple.delete_at(item, 0) |> Tuple.to_list())
        |> Enum.into(%{})
        |> Map.drop(drop)

      acc ++ [struct!(strc, converted)]
    end)
  end

  ################# Global Macro Public Apis #################
  # Based on https://github.com/mishka-group/mishka_developer_tools/issues/28
  # TODO: we need some strategy to implement fragment
  # {:frag_properties,
  #  [
  #    {:node_pool, all_active_nodes},
  #    {:n_fragments, 4},
  #    {:n_disc_only_copies, all_active_nodes |> length}
  #  ]}
end
