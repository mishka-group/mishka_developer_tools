defmodule MnesiaAssistant.BackupAndRestore do
  alias :mnesia, as: Mnesia

  def load_textfile(path), do: Mnesia.load_textfile(path)

  def dump_to_textfile(path), do: Mnesia.dump_to_textfile(path)

  def set_master_nodes(nodes) when is_list(nodes), do: Mnesia.set_master_nodes(nodes)

  # backup_checkpoint(Name, Dest) -> result()
  # backup_checkpoint(Name, Dest, Mod) -> result()
  def backup_checkpoint(name, dest, mod), do: Mnesia.backup_checkpoint(name, dest, mod)
  def backup_checkpoint(name, dest), do: Mnesia.backup_checkpoint(name, dest)

  def backup(backup_path), do: Mnesia.backup(backup_path)

  def backup(backup_path, module), do: Mnesia.backup(backup_path, module)

  # traverse_backup(Src :: term(), Dest :: term(), Fun, Acc) ->
  # traverse_backup(Src :: term(), SrcMod :: module(), Dest :: term(), DestMod :: module(), Fun, Acc)
  def traverse_backup(source, dest, fun, acc), do: Mnesia.traverse_backup(source, dest, fun, acc)

  def traverse_backup(source, source_module, dest, dest_module, fun, acc),
    do: Mnesia.traverse_backup(source, source_module, dest, dest_module, fun, acc)

  # Op = skip_tables | clear_tables | keep_tables | restore_tables
  # Arg = {module, module()} | {Op, [table()]} | {default_op, Op}
  def restore(source, args), do: Mnesia.restore(source, args)

  def install_fallback(source), do: Mnesia.install_fallback(source)
  def install_fallback(source, module), do: Mnesia.install_fallback(source, module)

  def uninstall_fallback(), do: Mnesia.uninstall_fallback()
  # Args = [{mnesia_dir, Dir :: string()}]
  # {module, BackupMod}. For semantics, see mnesia:install_fallback/2.
  # {scope, Scope}. For semantics, see mnesia:install_fallback/2.
  # {mnesia_dir, AlternateDir}. For semantics, see mnesia:install_fallback/2.
  def uninstall_fallback(args) when is_list(args), do: Mnesia.uninstall_fallback(args)

  def dump_log(), do: Mnesia.dump_log()

  def dump_tables(tables) when is_list(tables), do: Mnesia.dump_tables(tables)
end
