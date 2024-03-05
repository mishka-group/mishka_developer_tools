defmodule MnesiaAssistant.Snmp do
  @moduledoc """

  """
  alias :mnesia, as: Mnesia

  @doc """

  """
  def snmp_close_table(table), do: Mnesia.snmp_close_table(table)

  @doc """

  """
  def snmp_get_mnesia_key(table, rowIndex) when is_list(rowIndex),
    do: Mnesia.snmp_get_mnesia_key(table, rowIndex)

  @doc """

  """
  def snmp_get_next_index(table, rowIndex) when is_list(rowIndex),
    do: Mnesia.snmp_get_next_index(table, rowIndex)

  @doc """

  """
  def snmp_get_row(table, rowIndex) when is_list(rowIndex),
    do: Mnesia.snmp_get_row(table, rowIndex)

  @doc """

  """
  def snmp_open_table(table, snmp), do: Mnesia.snmp_open_table(table, snmp)
end
