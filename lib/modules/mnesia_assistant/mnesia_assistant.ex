defmodule MnesiaAssistant do
  alias MnesiaAssistant.{Information, Schema}

  def initial() do
    # TODO: add __using__ to create and start Mnesia
    # application ensure_all_started
    # ensure dir exists
    # Store init schema
    # start mnesia server
    # Store init_tables
    # Store ensure tables loaded
  end

  ################################################################
  ######################### Public Apis ##########################
  ################################################################

  ################# Global functions Public Apis #################
  def start(), do: Application.start(:mnesia)

  def set_dir(dir), do: Application.put_env(:mnesia, :dir, dir)

  def stop(), do: Application.stop(:mnesia)

  def started?(), do: Helper.Extra.app_started?(:mnesia)

  ############### Information functions Public Apis ###############
  defdelegate info(), to: Information

  defdelegate info(type), to: Information

  defdelegate set_debug_level(level), to: Information

  defdelegate schema(), to: Schema
end
