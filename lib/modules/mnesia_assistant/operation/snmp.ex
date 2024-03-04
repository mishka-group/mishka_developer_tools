defmodule MnesiaAssistant.Snmp do
  alias :mnesia, as: Mnesia

  def snmp_close_table(table), do: Mnesia.snmp_close_table(table)

  def snmp_get_mnesia_key(table, rowIndex) when is_list(rowIndex),
    do: Mnesia.snmp_get_mnesia_key(table, rowIndex)

  def snmp_get_next_index(table, rowIndex) when is_list(rowIndex),
    do: Mnesia.snmp_get_next_index(table, rowIndex)

  def snmp_get_row(table, rowIndex) when is_list(rowIndex),
    do: Mnesia.snmp_get_row(table, rowIndex)

  def snmp_open_table(table, snmp), do: Mnesia.snmp_open_table(table, snmp)
end
