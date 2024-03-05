defmodule MnesiaAssistant.Information do
  @moduledoc """

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

  """
  def info(), do: Mnesia.info()

  def info({:system, type}) when type in @system_types, do: Mnesia.system_info(type)

  def info(type) when type in @system_types, do: Mnesia.system_info(type)

  def info(:schema), do: Mnesia.schema()

  @doc """

  """
  def system_info(type) when is_atom(type), do: Mnesia.system_info(type)

  @doc """

  """
  def set_debug_level(level) when level in @debug_level_types,
    do: Mnesia.set_debug_level(level)

  @doc """

  """
  def report_event(event), do: Mnesia.report_event(event)

  @doc """

  """
  def sync_log(), do: Mnesia.sync_log()
end
