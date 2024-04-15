defmodule MnesiaAssistant.BackupAndRestore do
  @moduledoc """
  This module is where you will find the collection of functions that can
  assist you in obtaining a support version of `Mnesia` or in recovering the
  backup that was stored in the system.
  Additionally, it is possible to have a variety of inputs and consequently outputs.
  """
  alias :mnesia, as: Mnesia

  @doc """
  The `:mnesia.load_textfile/1` function in `Mnesia` is used to load data from a
  text file into a Mnesia table. The text file should contain Erlang terms,
  with one term per line, matching the structure of the records in the target table.

  ### Example

  ```elixir
    MnesiaAssistant.BackupAndRestore.load_textfile("/path/to/person.txt")
  ```
  """
  def load_textfile(path), do: Mnesia.load_textfile(path)

  @doc """
  The `:mnesia.dump_to_textfile/1` function in `Mnesia` is used to dump the contents
  of one or more Mnesia tables to a text file.
  Each record is written to the file as an Erlang term, one term per line.
  This can be useful for backing up data or exporting it for
  analysis or use in other systems.

  > Dumps all local tables of a Mnesia system into a text file,
  > which can be edited (by a normal text editor) and then be reloaded
  > with `mnesia:load_textfile/1`.
  > Only use this function for educational purposes.
  > Use other functions to deal with real backups.

  ### Example

  ```elixir
    MnesiaAssistant.BackupAndRestore.dump_to_textfile("/path/to/person.txt")
  ```
  """
  def dump_to_textfile(path), do: Mnesia.dump_to_textfile(path)

  @doc """
  Sets master nodes for `mnesia`.

  > For each table Mnesia determines its replica nodes (TabNodes) and
  > starts `mnesia:set_master_nodes(Tab, TabMasterNodes)`.
  > where `TabMasterNodes` is the intersection of `MasterNodes` and `TabNodes`.
  > For semantics, see `mnesia:set_master_nodes/2`.

  ### Example

  ```elixir
    MnesiaAssistant.BackupAndRestore.set_master_nodes([node()])
  ```
  """
  def set_master_nodes(nodes) when is_list(nodes), do: Mnesia.set_master_nodes(nodes)

  @doc """
  The `:mnesia.backup_checkpoint/2` function is used in Mnesia to create a
  backup of the database at a specific checkpoint.

  This function allows you to specify a checkpoint name, and `Mnesia`
  will generate a backup that includes all changes up to that point.

  This is particularly useful for creating consistent backups of the
  database state at known good points, facilitating easier recovery in
  case of data corruption or loss.

  > The tables are backed up to external media using backup module BackupMod.
  Tables with the local contents property are backed up as they exist on
  the current node. BackupMod is the default backup callback module obtained
  by `mnesia:system_info(backup_module)`. For information about the exact
  callback interface (the mnesia_backup behavior), see the User's Guide.

  ```erlang
    backup_checkpoint(Name, Dest) -> result()
    backup_checkpoint(Name, Dest, Mod) -> result()
  ```

  ### Example

  ```elixir
    MnesiaAssistant.BackupAndRestore.backup_checkpoint(name, dest, mod)
    MnesiaAssistant.BackupAndRestore.backup_checkpoint(name, dest)
  ```
  """
  def backup_checkpoint(name, dest, mod), do: Mnesia.backup_checkpoint(name, dest, mod)

  @doc """
  Read `backup_checkpoint/3` document.
  """
  def backup_checkpoint(name, dest), do: Mnesia.backup_checkpoint(name, dest)

  @doc """
  With this function, you can get a support version of `mnesia`.

  > Activates a new checkpoint covering all Mnesia tables,
  > including the schema, with maximum degree of redundancy,
  > and performs a backup using `backup_checkpoint/2` and `backup_checkpoint/3`. The
  > default value of the backup callback module BackupMod is
  > obtained by `mnesia:system_info(backup_module)`.

  ### Example

  ```elixir
    MnesiaAssistant.BackupAndRestore.backup(backup_path)
    MnesiaAssistant.BackupAndRestore.backup(backup_path, module)
  ```
  """
  def backup(backup_path), do: Mnesia.backup(backup_path)

  @doc """
  Read `backup/1` document.
  """
  def backup(backup_path, module), do: Mnesia.backup(backup_path, module)

  @doc """
  Iterates over a backup, either to transform it into a new backup, or read it.
  The arguments are explained briefly here. For details, see the User's Guide.

  * SourceMod and TargetMod are the names of the modules that actually
  access the backup media.
  * Source and Target are opaque data used exclusively by modules SourceMod and
  TargetMod to initialize the backup media.
  * Acc is an initial accumulator value.
  * Fun(BackupItems, Acc) is applied to each item in the backup.
  The Fun must return a tuple {BackupItems,NewAcc}, where BackupItems is a list of valid backup items, and NewAcc is a new accumulator value. The returned backup items are written in the target backup.
  * LastAcc is the last accumulator value. This is the last NewAcc value
  that was returned by Fun.

  > The `:mnesia.traverse_backup/4` function in Mnesia is designed for traversing
  > and processing the contents of a `Mnesia` backup file.
  > This functionality is particularly useful when you need to inspect,
  > analyze, or selectively restore data from a backup.
  > The `traverse_backup` function allows you to specify callback functions
  > that will be called with the data from the backup, enabling you to
  > programmatically interact with the backup contents.

  ```erlang
    traverse_backup(Src :: term(), Dest :: term(), Fun, Acc) ->
    traverse_backup(Src :: term(), SrcMod :: module(), Dest :: term(), DestMod :: module(), Fun, Acc)
  ```

  ### Example:

  ```elixir
    initial_acc = []  # Initial value for the accumulator

    MnesiaAssistant.BackupAndRestore.traverse_backup(
      source,
      dest,
      &BackupTraversal.table_fun/2,
      initial_acc
    )
    # OR
    MnesiaAssistant.BackupAndRestore.traverse_backup(
      source,
      source_module,
      dest,
      dest_module
      &BackupTraversal.table_fun/2,
      initial_acc
    )
  ```
  """
  def traverse_backup(source, dest, fun, acc), do: Mnesia.traverse_backup(source, dest, fun, acc)

  @doc """
  Read `traverse_backup/4` document.
  """
  def traverse_backup(source, source_module, dest, dest_module, fun, acc),
    do: Mnesia.traverse_backup(source, source_module, dest, dest_module, fun, acc)

  @doc """
  With this function, tables can be restored online from a backup
  without restarting Mnesia. Opaque is forwarded to the backup module.
  `args` is a list of the following tuples:

  * `Op`: skip_tables | clear_tables | keep_tables | restore_tables
  * `Arg`: {module, module()} | {Op, [table()]} | {default_op, Op}

  ---

  1. `{module,BackupMod}`. The backup module BackupMod is used to
  access the backup media. If omitted, the default backup module is used.
  2. `{skip_tables, TabList}`, where TabList is a list of tables that is
  not to be read from the backup.
  3. `{clear_tables, TabList}`, where TabList is a list of tables that
  is to be cleared before the records from the backup are inserted.
  That is, all records in the tables are deleted before the tables are restored.
  Schema information about the tables is not cleared or read from the backup.
  4. `{keep_tables, TabList}`, where TabList is a list of tables that is not
  to be cleared before the records from the backup are inserted.
  That is, the records in the backup are added to the records in the table.
  Schema information about the tables is not cleared or read from the backup.
  5. `{recreate_tables, TabList}`, where TabList is a list of tables that is
  to be recreated before the records from the backup are inserted.
  The tables are first deleted and then created with the schema information
  from the backup. All the nodes in the backup need to be operational.
  6. `{default_op, Operation}`, where Operation is either of the operations `skip_tables`,
  `clear_tables`, `keep_tables`, or `recreate_tables`.
  The default operation specifies which operation that is to be used on
  tables from the backup that is not specified in any of the mentioned lists.
  If omitted, operation clear_tables is used.

  > The affected tables are `write-locked` during the restoration.
  > However, regardless of the lock conflicts caused by this,
  > the applications can continue to do their work while the restoration
  > is being performed. The restoration is performed as one single transaction.

  > If the database is huge, it it not always possible to restore it online.
  > In such cases, restore the old database by installing a fallback and then restart.

  ### Example:

  ```elixir
    MnesiaAssistant.BackupAndRestore.restore(
      "/tmp/mnesia_backup", [{:skip_tables, [Person]}]
    )
  ```
  """
  def restore(source, args), do: Mnesia.restore(source, args)

  @doc """
  Installs a backup as fallback. The fallback is used to restore the database
  at the next startup. Installation of fallbacks requires Erlang to be operational
  on all the involved nodes, but it does not matter if Mnesia is running or not.
  The installation of the fallback fails if the local node is
  not one of the `disc-resident` nodes in the backup.

  ### Example:

  ```elixir
    MnesiaAssistant.BackupAndRestore.install_fallback(source)
    # --> :mnesia.install_fallback(source)
    MnesiaAssistant.BackupAndRestore.install_fallback(source, module)
    # --> :mnesia.install_fallback(source, module)
  ```
  """
  def install_fallback(source), do: Mnesia.install_fallback(source)

  @doc """
  Read `install_fallback/1` document.
  """
  def install_fallback(source, module), do: Mnesia.install_fallback(source, module)

  @doc """
  Deinstalls a fallback before it has been used to restore the database.
  This is normally a distributed operation that is either performed
  on all nodes with disc resident schema, or none.

  Uninstallation of fallbacks requires Erlang to be operational on all
  involved nodes, but it does not matter if Mnesia is running or not.
  Which nodes that are considered as disc-resident nodes is determined
  from the schema information in the local fallback.

  ```erlang
   Args = [{mnesia_dir, Dir :: string()}]
   {module, BackupMod}. For semantics, see mnesia:install_fallback/2.
   {scope, Scope}. For semantics, see mnesia:install_fallback/2.
   {mnesia_dir, AlternateDir}. For semantics, see mnesia:install_fallback/2.
  ```

  ### Example:

  ```elixir
    MnesiaAssistant.BackupAndRestore.uninstall_fallback()
    # --> :mnesia.uninstall_fallback()
    MnesiaAssistant.BackupAndRestore.uninstall_fallback(args)
    # --> :mnesia.uninstall_fallback(args)
  ```
  """
  def uninstall_fallback(), do: Mnesia.uninstall_fallback()

  @doc """
  Read `uninstall_fallback/0` document.
  """
  def uninstall_fallback(args) when is_list(args), do: Mnesia.uninstall_fallback(args)

  @doc """
  Performs a user-initiated dump of the local log file.
  This is usually not necessary, as Mnesia by default manages this automatically

  ### Example:

  ```elixir
    MnesiaAssistant.BackupAndRestore.dump_log() # --> :mnesia.dump_log()
  ```
  """
  def dump_log(), do: Mnesia.dump_log()

  @doc """
  Dumps a set of `ram_copies` tables to disc. The next time the system is started,
  these tables are initiated with the data found in the files that are the
  result of this dump. None of the tables can have `disc-resident` replicas.

  ### Example:

  ```elixir
    MnesiaAssistant.BackupAndRestore.dump_tables(tables) # --> :mnesia.dump_tables(tables)
  ```
  """
  def dump_tables(tables) when is_list(tables), do: Mnesia.dump_tables(tables)
end
