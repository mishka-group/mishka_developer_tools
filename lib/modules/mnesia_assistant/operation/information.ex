defmodule MnesiaAssistant.Information do
  @moduledoc """
  This particular module is actually a set of functions in `Mnesia` that are designed
  to supply the user with the information that they require regarding the system.
  """
  alias :mnesia, as: Mnesia
  @debug_level_types [:none, :verbose, :debug, :trace, false, true]

  @system_types [
    :all,
    :access_module,
    :auto_repair,
    :backup_module,
    :checkpoints,
    :event_module,
    :db_nodes,
    :debug,
    :directory,
    :dump_log_load_regulation,
    :dump_log_time_threshold,
    :dump_log_update_in_place,
    :dump_log_write_threshold,
    :extra_db_nodes,
    :fallback_activated,
    :held_locks,
    :is_running,
    :local_tables,
    :lock_queue,
    :log_version,
    :master_node_tables,
    :protocol_version,
    :running_db_nodes,
    :schema_location,
    :subscribers,
    :tables,
    :transactions,
    :transaction_failures,
    :transaction_commits,
    :transaction_restarts,
    :transaction_log_writes,
    :use_dir,
    :version
  ]

  @doc """
  This function is actually a combination of two functions
  in mnesia(`:mnesia.info()`, `:mnesia.schema()`).

  ### Example:

  ```elixir
    MnesiaAssistant.Information.info()
    # OR
    MnesiaAssistant.Information.info({:system, type})
    # OR
    MnesiaAssistant.Information.info(type)
  ```

  All types you can use:
  ```
    [
      :all,
      :access_module,
      :auto_repair,
      :backup_module,
      :checkpoints,
      :event_module,
      :db_nodes,
      :debug,
      :directory,
      :dump_log_load_regulation,
      :dump_log_time_threshold,
      :dump_log_update_in_place,
      :dump_log_write_threshold,
      :extra_db_nodes,
      :fallback_activated,
      :held_locks,
      :is_running,
      :local_tables,
      :lock_queue,
      :log_version,
      :master_node_tables,
      :protocol_version,
      :running_db_nodes,
      :schema_location,
      :subscribers,
      :tables,
      :transactions,
      :transaction_failures,
      :transaction_commits,
      :transaction_restarts,
      :transaction_log_writes,
      :use_dir,
      :version,
      :schema
    ]
  ```
  """
  def info(), do: Mnesia.info()

  @doc """
  Read `info/0` document.
  """
  def info({:system, type}) when type in @system_types, do: Mnesia.system_info(type)

  def info(type) when type in @system_types, do: Mnesia.system_info(type)

  def info(:schema), do: Mnesia.schema()

  @doc """
  Read `info/0` document.
  """
  def system_info(type) when is_atom(type), do: Mnesia.system_info(type)

  @doc """
  If the application detects a communication failure (in a potentially partitioned network)
  that can have caused an inconsistent database, it can use the function
  `mnesia:set_master_nodes(Tab, MasterNodes)` to define from which nodes
  each table is to be loaded. At startup, the Mnesia normal table load algorithm is
  bypassed and the table is loaded from one of the master nodes defined for the table,
  regardless of when and if Mnesia terminated on other nodes. MasterNodes can only
  contain nodes where the table has a replica. If the MasterNodes list is empty,
  the master node recovery mechanism for the particular table is reset,
  and the normal load mechanism is used at the next restart.

  > The master node setting is always local. It can be changed regardless
  > if Mnesia is started or not.

  The database can also become inconsistent if configuration
  parameter `max_wait_for_decision` is used or if `mnesia:force_load_table/1` is used.

  ### Example:

  ```elixir
    MnesiaAssistant.Information.set_debug_level(level)
  ```

  All level you can use: `[:none, :verbose, :debug, :trace, false, true]`
  """
  def set_debug_level(level) when level in @debug_level_types,
    do: Mnesia.set_debug_level(level)

  @doc """
  Ensures that the local transaction log file is synced to disk.
  On a single node system, data written to disk tables since the
  last dump can be lost if there is a power outage.

  ### Example:

  ```elixir
  MnesiaAssistant.Information.sync_log()
  ```
  """
  def sync_log(), do: Mnesia.sync_log()
end
