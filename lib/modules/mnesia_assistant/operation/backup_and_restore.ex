defmodule MnesiaAssistant.BackupAndRestore do
  alias :mnesia, as: Mnesia

  def load_textfile(path), do: Mnesia.load_textfile(path)

  def dump_to_textfile(path), do: Mnesia.dump_to_textfile(path)

  def set_master_nodes(nodes) when is_list(nodes), do: Mnesia.set_master_nodes(nodes)
end
