defmodule MnesiaAssistant.Table do
  @moduledoc """
  Within this module, you will find all of the functions that you require in order to operate with a table in Mnesia.
  """

  alias :mnesia, as: Mnesia
  require Logger

  @type table_type() :: :set | :ordered_set | :bag
  @create_table_types [:disc_only_copies, :disc_copies, :ram_copies]
  @storage_types [:ram_copies, :disc_copies, :disc_only_copies]
  @table_info_types [
    :all,
    :access_mode,
    :arity,
    :attributes,
    :checkpoints,
    :cookie,
    :disc_copies,
    :disc_only_copies,
    :index,
    :load_node,
    :load_order,
    :load_reason,
    :local_content,
    :master_nodes,
    :memory,
    :ram_copies,
    :record_name,
    :size,
    :snmp,
    :storage_type,
    :subscribers,
    :type,
    :user_properties,
    :version,
    :where_to_read,
    :where_to_write,
    :wild_pattern
  ]

  @change_table_access_mode_types [:read_only, :read_write]

  @doc """
  You are possible to generate a table in Mnesia by utilizing this function. During the process
  of creating the table, it is important to know that the first input, which is the name of the
  table, and the second input, which is in the form of a list, are respectively options that you
  are required to apply to the table.

  > It is important to note that you should make an effort to have a proper implementation at the
  > beginning by thoroughly researching the possibilities that are dependent on your strategy.
  > This will ensure that you do not have to repeat the procedures with as many different functions as possible.

  ### Erlang Documents

  - `{access_mode, Atom}` The access mode is by default the atom read_write but it can also be set to the atom read_only.
  If AccessMode is set to read_only, updates to the table cannot be performed.
  At startup, Mnesia always loads read_only table locally regardless of when and if Mnesia is terminated on other nodes.
  This argument returns the access mode of the table. The access mode can be read_only or read_write.

  - `{attributes, AtomList}` is a list of the attribute names for the records that are supposed to populate the table.
  Default is [key, val]. The table must at least have one extra attribute in addition to the key.
  When accessing single attributes in a record, it is not necessary, or even recommended, to hard code any
  attribute names as atoms. Use construct `record_info(fields, RecordName)` instead. It can be used for records
  of type RecordName.

  - `{disc_copies, Nodelist}`, where Nodelist is a list of the nodes where this table is supposed to have disc copies.
  If a table replica is of type disc_copies, all write operations on this particular replica of the table are written
  to disc and to the RAM copy of the table.
  It is possible to have a replicated table of type disc_copies on one node and another type on another node.
  Default is [].

  - `{disc_only_copies, Nodelist}`, where Nodelist is a list of the nodes where this table is supposed to have
  `disc_only_copies`. A disc only table replica is kept on disc only and unlike the other replica types,
  the contents of the replica do not reside in RAM. These replicas are considerably slower than replicas held in RAM.

  - `{index, Intlist}`, where Intlist is a list of attribute names (atoms) or record fields for which Mnesia is
  to build and maintain an extra index table. The qlc query compiler may be able to optimize queries
  if there are indexes available.

  - `{load_order, Integer}`. The load order priority is by default 0 `(zero)` but can be set to any integer.
  The tables with the highest load order priority are loaded first at startup.

  - `{majority, Flag}`, where Flag must be a boolean. If true, any `(non-dirty)` update to the table is aborted,
  unless a majority of the table replicas are available for the commit. When used on a fragmented table,
  all `fragments` are given the same majority setting.

  - `{ram_copies, Nodelist}`, where Nodelist is a list of the nodes where this table is supposed to have RAM copies.
  A table replica of type ram_copies is not written to disc on a per transaction basis. ram_copies replicas can be
  dumped to disc with the function mnesia:dump_tables(Tabs). Default value for this attribute is `[node()]`.


  - `{record_name, Name}`, where Name must be an atom. All records stored in the table must have this name as the
  first element. It defaults to the same name as the table name.

  - `{snmp, SnmpStruct}`. For a description of SnmpStruct, see `mnesia:snmp_open_table/2`.
  If this attribute is present in ArgList to `mnesia:create_table/2`, the table is immediately accessible by SNMP.
  Therefore applications that use SNMP to manipulate and control the system can be designed easily,
  since Mnesia provides a direct mapping between the logical tables that make up an SNMP control
  application and the physical data that makes up a `Mnesia` table.

  - `{storage_properties, [{Backend, Properties}]` forwards more properties to the back end storage.
  Backend can currently be ets or dets. Properties is a list of options sent to the back end storage during
  table creation. Properties cannot contain properties already used by Mnesia, such as type or `named_table`.

  For example:
  ```erlang
  mnesia:create_table(table, [{ram_copies, [node()]}, {disc_only_copies, nodes()},
         {storage_properties,
         [{ets, [compressed]}, {dets, [{auto_save, 5000}]} ]}])
  ```

  - `{type, Type}`, where Type must be either of the atoms set, `ordered_set`, or `bag`. Default is set. In a `set`,
  all records have unique keys. In a bag, several records can have the same key, but the record content is unique.
  If a non-unique record is stored, the old conflicting records are overwritten.

  Notice that currently `ordered_set` is not supported for `disc_only_copies`.

  `{local_content, Bool}`, where Bool is `true` or `false`. Default is `false`.

  For example, the following call creates the person table (defined earlier) and replicates it on two nodes:

  ```erlang
  mnesia:create_table(person,
      [{ram_copies, [N1, N2]},
      {attributes, record_info(fields, person)}]).
  ```

  If it is required that Mnesia must build and maintain an extra index table on attribute address of all
  the person records that are inserted in the table, the following code would be issued:

  ```erlang
  mnesia:create_table(person,
      [{ram_copies, [N1, N2]},
       {index, [address]},
       {attributes, record_info(fields, person)}]).
   ```

   The specification of index and attributes can be hard-coded as `{index, [2]}` and
   `{attributes, [name, age, address, salary, children]}`, respectively.

   `mnesia:create_table/2` writes records into the table schema. This function, and all other schema
   manipulation functions, are implemented with the normal transaction management system.
   This guarantees that schema updates are performed on all nodes in an atomic manner.

   ### Example:

   ```elixir
    MnesiaAssistant.Table.create_table(Person, attributes: [:id, :name, :family, :age])
   ```
  """
  def create_table(module, opts) when is_list(opts) do
    Mnesia.create_table(module, opts)
  end

  @doc """
  Table indexes can be used whenever the user wants to use frequently some other field than the key
  field to look up records. If this other field has an associated index,
  these lookups can occur in constant time and space. For example, if your application wishes to use field `age`
  to find efficiently all persons with a specific age, it can be a good idea to have an index on field age.
  This can be done with the following call:

  ### Example:

  ```elixir
   MnesiaAssistant.Table.add_table_index(Person, :age)
  ```
  """
  def add_table_index(module, field) when is_atom(field) do
    Mnesia.add_table_index(module, field)
  end

  @doc """
  You can use this function to see the information of a table.
  The `table_info/2` function takes two arguments. The first is the name of a Mnesia table.
  The second is one of the following keys:

  - `:all` Returns a list of all local table information. Each element is a {InfoKey, ItemVal} tuple.

  New InfoItems can be added and old undocumented InfoItems can be removed without notice.

  - `:access_mode` Returns the access mode of the table. The access mode can be read_only or read_write.

  - `:arity` Returns the arity of records in the table as specified in the schema.

  - `:attributes` Returns the table attribute names that are specified in the schema.

  - `:checkpoints` Returns the names of the currently active checkpoints, which involve this table on this node.

  - `:cookie` Returns a table cookie, which is a unique system-generated identifier for the table. The cookie is used internally to ensure that two different table definitions using the same table name cannot accidentally be intermixed. The cookie is generated when the table is created initially.

  - `:disc_copies` Returns the nodes where a disc_copy of the table resides according to the schema.

  - `:disc_only_copies` Returns the nodes where a disc_only_copy of the table resides according to the schema.

  - `:index` Returns the list of index position integers for the table.

  - `:load_node` Returns the name of the node that Mnesia loaded the table from. The structure of the returned value is unspecified, but can be useful for debugging purposes.

  - `:load_order` Returns the load order priority of the table. It is an integer and defaults to 0 (zero).

  - `:load_reason` Returns the reason of why Mnesia decided to load the table. The structure of the returned value is unspecified, but can be useful for debugging purposes.

  - `:local_content` Returns true or false to indicate if the table is configured to have locally unique content on each node.

  - `:master_nodes` Returns the master nodes of a table.

  - `:memory` Returns for ram_copies and disc_copies tables the number of words allocated in memory to the table on this node. For disc_only_copies tables the number of bytes stored on disc is returned.

  - `:ram_copies` Returns the nodes where a ram_copy of the table resides according to the schema.

  - `:record_name` Returns the record name, common for all records in the table.

  - `:size` Returns the number of records inserted in the table.

  - `:snmp` Returns the SNMP struct. [] means that the table currently has no SNMP properties.

  - `:storage_type` Returns the local storage type of the table. It can be disc_copies, ram_copies, disc_only_copies, or the atom unknown. unknown is returned for all tables that only reside remotely.

  - `:subscribers` Returns a list of local processes currently subscribing to local table events that involve this table on this node.

  - `:type` Returns the table type, which is bag, set, or ordered_set.

  - `:user_properties` Returns the user-associated table properties of the table. It is a list of the stored property records.

  - `:version` Returns the current version of the table definition. The table version is incremented when the table definition is changed. The table definition can be incremented directly when it has been changed in a schema transaction, or when a committed table definition is merged with table definitions from other nodes during startup.

  - `:where_to_read` Returns the node where the table can be read. If value nowhere is returned, either the table is not loaded or it resides at a remote node that is not running.

  - `:where_to_write` Returns a list of the nodes that currently hold an active replica of the table.

  - `:wild_pattern` Returns a structure that can be given to the various match functions for a certain table. A record tuple is where all record fields have value '_'.

  ### Example:

  ```elixir
   MnesiaAssistant.Table.table_info(:attributes)
   # OR
   MnesiaAssistant.Table.table_info(:all)
  ```
  """
  def table_info(module, type \\ :attributes) when is_atom(type) and type in @table_info_types do
    Mnesia.table_info(module, type)
  end

  @doc """
  After the table has been created, it is possible that you will need to modify the way of copying data in a `Mnesia`
  table in accordance with the logic of your program.

  Table copy types: `[:disc_only_copies, :disc_copies, :ram_copies]`

  ### Example:

  ```elixir
   MnesiaAssistant.Table.change_table_copy_type(Person, :disc_only_copies)
  ```
  """
  def change_table_copy_type(module, type) when type in @create_table_types do
    Mnesia.change_table_copy_type(module, node(), type)
  end

  @doc """
  Some applications need to wait for certain tables to be accessible to do useful work.
  `mnesia:wait_for_tables/2` either hangs until all tables in TabList are accessible, or until `timeout` is reached.

  ### Example:

  ```elixir
   MnesiaAssistant.Table.wait_for_tables(Person, 5000)
  ```
  """
  def wait_for_tables(tables, timeout) when is_list(tables) and is_integer(timeout),
    do: Mnesia.wait_for_tables(tables, timeout)

  def wait_for_tables(tables, timeout, identifier) when is_list(tables) and is_integer(timeout) do
    case wait_for_tables(tables, timeout) do
      :ok ->
        Logger.info(
          "Identifier: #{inspect(identifier)}; The action concerned was completed successfully."
        )

        {:ok, :atomic}

      {:timeout, missing_tables} = error ->
        concerted =
          {"The requested tables could not be loaded in the specified time #{timeout}.",
           missing_tables}

        Logger.error("""
          Identifier: #{inspect(identifier)}
          MnesiaError: #{inspect(error)}
          ConvertedError: #{inspect(concerted)}
        """)

        {:error, error, elem(concerted, 0)}

      error ->
        concerted = MnesiaAssistant.Error.error_description(error)

        Logger.error("""
          Identifier: #{inspect(identifier)}
          MnesiaError: #{inspect(error)}
          ConvertedError: #{inspect(concerted)}
        """)

        {:error, error, elem(concerted, 0) |> to_string}
    end
  end

  @doc """
  When continuing or beginning to call a table from `Mnesia`, it is possible that you will be required to
  use an anonymous function in order to convert the previous data into the new data.

  ### Erlang document:

  Applies argument Fun to all records in the table. Fun is a function that takes a record of the **`old`** type and
  returns a transformed record of the **`new`** type.
  Argument Fun can also be the atom ignore, which indicates that only the metadata about
  the table is updated. Use of ignore is not recommended, but included as a possibility for the user
  do to an own transformation.

  **NewAttributeList** and **NewRecordName** specify the attributes and the new record type of the converted table.
  Table name always remains unchanged. If `record_name` is changed, only the `Mnesia` functions that use table
  identifiers work, for example, `mnesia:write/3` works, but not `mnesia:write/1`.

  ### Example:

  ```elixir
  transform_fun = fn ({id, name}) ->
    # Return the new structure with a default age
    {id, name, 30}
  end

  MnesiaAssistant.Transaction.transaction(fn ->
    MnesiaAssistant.Table.transform_table(Person, transform_fun, [:id, :name, :age])
  end)
  # OR
  # MnesiaAssistant.Table.transform_table(Person, transform_fun, [:id, :name, :age])
  # OR
  MnesiaAssistant.Table.transform_table(Person, transform_fun, [:id, :name, :age], NewPerson)
  ```
  """
  def transform_table(table, transform_fun, new_fields)
      when is_function(transform_fun) and is_list(new_fields),
      do: Mnesia.transform_table(table, transform_fun, new_fields)

  def transform_table(table, transform_fun, new_fields, rec_name)
      when is_function(transform_fun) and is_list(new_fields),
      do: Mnesia.transform_table(table, transform_fun, new_fields, rec_name)

  @doc """

  ### Erlang document:

  - `lock(LockItem, LockKind)`

  LockItem =
    {record, table(), Key :: term()} |
    {table, table()} |
    {global, Key :: term(), MnesiaNodes :: [node()]}

  LockKind = [:read, :write, :sticky_write, :load]

  Write locks are normally acquired on all nodes where a replica of the table resides (and is active).
  Read locks are acquired on one node (the local node if a local replica exists).
  Most of the context-sensitive access functions acquire an implicit lock if they are started in a transaction-context.
  The granularity of a lock can either be a single record or an entire table.

  The normal use is to call the function without checking the return value, as it exits if it fails and the
  transaction is restarted by the transaction manager. It returns all the locked nodes if a write lock is
  acquired and ok if it was a read lock.

  The function `mnesia:lock/2` is intended to support explicit locking on tables, but is also intended for
  situations when locks need to be acquired regardless of how tables are replicated.
  Currently, two kinds of LockKind are supported:

  - `:write` Write locks are exclusive. This means that if one transaction manages to acquire a write lock on an item,
  no other transaction can acquire any kind of lock on the same item.

  - `read` Read locks can be shared. This means that if one transaction manages to acquire a read lock on an item,
  other transactions can also acquire a read lock on the same item. However,
  if someone has a read lock, no one can acquire a write lock at the same item.
  If someone has a write lock, no one can acquire either a read lock or a write lock at the same item.
  Conflicting lock requests are automatically queued if there is no risk of a deadlock. Otherwise the transaction must
  be terminated and executed again. Mnesia does this automatically as long as the upper limit
  of the maximum retries is not reached. For details, see `mnesia:transaction/3`.

  > For the sake of completeness, sticky write locks are also described here even if a sticky write lock is not
  > supported by this function:

  - `sticky_write` Sticky write locks are a mechanism that can be used to optimize write lock acquisition.
  If your application uses replicated tables mainly for fault tolerance (as opposed to read access optimization purpose),
  sticky locks can be the best option available.

  When a sticky write lock is acquired, all nodes are informed which node is locked. Then, sticky lock requests
  from the same node are performed as a local operation without any communication with other nodes.
  The sticky lock lingers on the node even after the transaction ends. For details, see the User's Guide.

  Currently, this function supports two kinds of LockItem:

  `{table, Tab}` This acquires a lock of type LockKind on the entire table Tab.

  `{global, GlobalKey, Nodes}` This acquires a lock of type LockKind on the global resource GlobalKey.
  The lock is acquired on all active nodes in the Nodes list.

  Locks are released when the outermost transaction ends. The semantics of this function is context-sensitive.
  For details, see `mnesia:activity/4`. In transaction-context, it acquires locks, otherwise it ignores the request.

  ### Example:

  ```elixir
    MnesiaAssistant.Table.lock({:table, Person}, :load)
  ```
  """
  def lock(opts, type) when type in [:read, :write, :sticky_write, :load],
    do: Mnesia.lock(opts, type)

  @doc """
    Calls the function `mnesia:lock({table, Tab}, write)`. Read `lock/2` document.

  ### Example:

  ```elixir
    MnesiaAssistant.Table.write_lock_table(Person)
  ```
  """
  def write_lock_table(table), do: Mnesia.write_lock_table(table)

  @doc """
  ### Experimental:

  The assumption here is that you do not wish to have a warranty for your data and that you also desire a copy
  of the `ram_copies` document. When it comes to this section, speed is of the utmost importance,
  and you should concentrate on local `ets`.
  When you take into account all of these factors, this feature is really helpful.

  ### Erlang document:

  Calls the Fun in a raw context that is not protected by a transaction. The `Mnesia` function call is
  performed in the Fun and performed directly on the local `ETS` tables on the assumption that
  the local storage type is ram_copies and the tables are not replicated to other nodes.
  Subscriptions are not triggered and checkpoints are not updated, but it is extremely fast.
  This function can also be applied to disc_copies tables if all operations are read only.
  For details, see `mnesia:activity/4` and the User's Guide.

  > Notice that calling (nesting) a `mnesia:ets` inside a transaction-context inherits the transaction semantics.

  ### Example:

  ```elixir
    fun = fn ->
      # Use ETS to get all records from the :people table and count them
      ets_table = :ets.tab2list(:people)
      length(ets_table)
    end

    MnesiaAssistant.Table.ets(fun)
    # OR
    MnesiaAssistant.Table.ets(fn ->
      MnesiaAssistant.Table.all_keys(module)
    end)
    # OR
    MnesiaAssistant.Table.ets(fn -> Enum.each(list, &save_dirty/1) end)
  ```
  """
  def ets(ets_fn) when is_function(ets_fn), do: Mnesia.ets(ets_fn)

  @doc """
  Read `ets/1` document.
  """
  def ets(ets_fn, args) when is_function(ets_fn) and is_list(args), do: Mnesia.ets(ets_fn, args)

  @doc """
  The Mnesia algorithm for table load can lead to a situation where a table cannot be loaded.
  This situation occurs when a node is started and Mnesia concludes, or suspects,
  that another copy of the table was active after this local copy became inactive because of a system crash.

  If this situation is not acceptable, this function can be used to override the strategy of
  the Mnesia table load algorithm. This can lead to a situation where some transaction effects
  are lost with an inconsistent database as result, but for some applications high availability
  is more important than consistent data.

  ### Example:

  ```elixir
    MnesiaAssistant.Table.force_load_table(Person)
  ```
  """
  def force_load_table(table), do: Mnesia.force_load_table(table)

  @doc """
  Checking if the desired table exists?

  ### Example:

  ```elixir
    MnesiaAssistant.Table.exists?(Person)
  ```
  """
  def exists?(name) do
    MnesiaAssistant.Information.info({:system, :tables})
    |> Enum.member?(name)
  end

  @doc """
  Checking whether the desired table is of `bag` type or not?

  ### Example:

  ```elixir
    MnesiaAssistant.Table.is_bag?(Person)
  ```
  """
  def is_bag?(module), do: table_info(module, :type) == :bag

  @doc """
  Checking whether the desired table is of `set` type or not?

  ### Example:

  ```elixir
    MnesiaAssistant.Table.is_set?(Person)
  ```
  """
  def is_set?(module), do: table_info(module, :type) == :set

  @doc """
  Checking whether the desired table is of `ordered_set` type or not?

  ### Example:

  ```elixir
    MnesiaAssistant.Table.is_ordered_set?(Person)
  ```
  """
  def is_ordered_set?(module), do: table_info(module, :type) == :ordered_set

  @doc """
  AcccessMode is by default the atom `read_write` but it can also be set to the atom `read_only`.
  If `AccessMode` is set to `read_only`, updates to the table cannot be performed.
  At startup, `Mnesia` always loads `read_only` tables locally regardless of when and if `Mnesia` is terminated on
  other nodes.

  ### Example:

  ```elixir
    MnesiaAssistant.Table.change_table_access_mode(Person, :read_write) #  [:read_only, :read_write]
  ```
  """
  def change_table_access_mode(module, type) when type in @change_table_access_mode_types do
    Mnesia.change_table_access_mode(module, type)
  end

  @doc """
  Consider the following scenario: the existence of other tables is somewhat reliant on the existence of other tables,
  and the tables should be brought up in order based on a prioritization of the tables; therefore,
  this function may be useful in this part.

  ### Erlang document:

  The LoadOrder priority is by default `0` (zero) but can be set to any integer.
  The tables with the highest LoadOrder priority are loaded first at startup.

  ### Example:

  ```elixir
    MnesiaAssistant.Table.change_table_load_order(Person, 10)
  ```
  """
  def change_table_load_order(module, order) when is_integer(order),
    do: Mnesia.change_table_load_order(module, order)

  @doc """
  This function is part of Mnesia's advanced features for handling distributed data consistency.
  The majority property, when set to true, requires that a majority of replicas (nodes)
  for a given table must acknowledge a write operation for it to be considered successful.
  This can enhance data consistency in distributed environments at the cost of availability,

  ### Erlang document:

  Majority must be a boolean. Default is false. When true, a majority of the table replicas
  must be available for an update to succeed. When used on fragmented tables,
  Tab must be the base table name. Directly changing the majority setting on individual fragments is not allowed.

  ### Example:

  ```elixir
    MnesiaAssistant.Table.change_table_majority(Person, true)
    # OR
    MnesiaAssistant.Table.change_table_majority(Person, false)
  ```
  """
  def change_table_majority(module, status) when is_boolean(status),
    do: Mnesia.change_table_majority(module, status)

  @doc """
  Makes another copy of a table on the Node you want. Argument Type must be either of the
  atoms `ram_copies`, `disc_copies`, or `disc_only_copies`. For example, the following call ensures
  that a disc replica of the person table also exists at node Node:

  ### Example:

  ```elixir
     MnesiaAssistant.Table.add_table_copy(Person, A_NODE, :disc_copies)
  ```
  """
  def add_table_copy(module, node, type) when type in @storage_types,
    do: Mnesia.add_table_copy(module, node, type)

  @doc """
  Moves the copy of table Tab from node `From` to node `To`.

  > The storage type is preserved. For example, a RAM table moved from one node remains
  > a RAM on the new node. Other transactions can still read and write in the table while it is being moved.

  This function cannot be used on `local_content` tables.

  ### Example:

  ```elixir
      MnesiaAssistant.Table.add_table_copy(Person, A_NODE, B_NODE)
  ```
  """
  def move_table_copy(module, from, to) do
    Mnesia.move_table_copy(module, from, to)
  end

  @doc """
    ### Erlang document:

    Deletes the replica of table `Tab` at node `Node`. When the last replica is deleted with this function,
    the table disappears entirely.

    This function can also be used to delete a replica of the table named schema.
    The Mnesia node is then removed. Notice that Mnesia must be stopped on the node first.

    ### Example:

    ```elixir
       MnesiaAssistant.Table.del_table_copy(Person, A_NODE)
    ```
  """
  def del_table_copy(module, node), do: Mnesia.del_table_copy(module, node)

  @doc """
  Deletes the index on attribute with name `AttrName` (for example :age) in a table.

  ### Example:

  ```elixir
     MnesiaAssistant.Table.del_table_index(Person, :age)
  ```
  """
  def del_table_index(module, attribute) when is_atom(attribute),
    do: Mnesia.del_table_index(module, attribute)

  @doc """
  ### Erlang document:

  For each table Mnesia determines its replica nodes (`TabNodes`) and starts `mnesia:set_master_nodes(Tab, TabMasterNodes)`.
  where `TabMasterNodes` is the intersection of `MasterNodes` and TabNodes. For semantics, `see mnesia:set_master_nodes/2`.

  ### Example:

  ```elixir
     MnesiaAssistant.Table.set_master_nodes([node()])
  ```
  """
  def set_master_nodes(nodes) when is_list(nodes),
    do: Mnesia.set_master_nodes(nodes)

  @doc """
  ### Erlang document:

  If the application detects a communication failure (in a potentially partitioned network) that can
  have caused an inconsistent database, it can use the function `mnesia:set_master_nodes(Tab, MasterNodes)`
  to define from which nodes each table is to be loaded. At startup, the `Mnesia` normal table load
  algorithm is bypassed and the table is loaded from one of the master nodes defined for the table,
  regardless of when and if Mnesia terminated on other nodes. `MasterNodes` can only contain
  nodes where the table has a replica. If the `MasterNodes` list is empty,
  the master node recovery mechanism for the particular table is reset, and the normal load
  mechanism is used at the next restart.

  The master node setting is always local. It can be changed regardless if `Mnesia` is started or not.

  The database can also become inconsistent if configuration parameter `max_wait_for_decision` is used or
  if `mnesia:force_load_table/1` is used.

  ### Example:

  ```elixir
     MnesiaAssistant.Table.set_master_nodes(Person, [node()])
  ```
  """
  def set_master_nodes(module, nodes) when is_list(nodes),
    do: Mnesia.set_master_nodes(module, nodes)

  @doc """
  Permanently deletes all replicas of table Tab.

  ### Example:

  ```elixir
     MnesiaAssistant.Table.delete_table(Person)
  ```
  """
  def delete_table(module), do: Mnesia.delete_table(module)

  @doc """
  Deletes all entries in a table.

  ### Example:

  ```elixir
     MnesiaAssistant.Table.clear_table(Person)
  ```
  """
  def clear_table(module), do: Mnesia.clear_table(module)

  @doc """
  It returns size of a table by using `table_info(module, :size)`.

  ### Example:

  ```elixir
      MnesiaAssistant.Table.count(Person)
  ```
  """
  def count(module), do: table_info(module, :size)

  @doc """
  Returns a list of all keys in a table.
  he semantics of this function is context-sensitive. For more information, see `MnesiaAssistant.Transaction.activity/4`.
  In `transaction-context`, it acquires a read lock on the entire table.

  ### Example:

  ```elixir
      MnesiaAssistant.Table.all_keys(Person)
  ```
  """
  def all_keys(module), do: Mnesia.all_keys(module)

  @doc """
  Dirty equivalent of the function `all_keys/1`.

  ### Example:

  ```elixir
      MnesiaAssistant.Table.dirty_all_keys(Person)
  ```
  """
  def dirty_all_keys(module), do: Mnesia.dirty_all_keys(module)

  @doc """
  Calls the function `lock({:table, Person}, :read)`

  ### Example:

  ```elixir
      MnesiaAssistant.Table.read_lock_table(Person)
  ```
  """
  def read_lock_table(table), do: Mnesia.read_lock_table(table)

  @doc """
  ### Erlang document:

  Returns a Query List Comprehension (`QLC`) query handle, see the `qlc(3)` manual page in STDLIB.
  The module qlc implements a query language that can use Mnesia tables as sources of data.
  Calling `mnesia:table/1,2` is the means to make the mnesia table Tab usable to **`QLC`**.

  Option can contain Mnesia options or QLC options. Mnesia recognizes the following options
  (any other option is forwarded to QLC).

  - `{lock, Lock}`, where lock can be read or write. Default is read.
  `{n_objects,Number}`, where n_objects specifies (roughly) the number of objects returned from Mnesia to QLC.
  Queries to remote tables can need a larger chunk to reduce network overhead.
  By default, 100 objects at a time are returned.

  - `{traverse, SelectMethod}`, where traverse determines the method to traverse the whole table (if needed).
  The default method is select.

  There are two alternatives for select:

  1. `select`. The table is traversed by calling `mnesia:select/4` and `mnesia:select/1`.
  The match specification (the second argument of select/3) is assembled by QLC:
  simple filters are translated into equivalent match specifications. More complicated filters need to
  be applied to all objects returned by select/3 given a match specification that matches all objects.

  2. `{select, MatchSpec}`. As for select, the table is traversed by calling `mnesia:select/3` and `mnesia:select/1`.
  The difference is that the match specification is explicitly given.
  This is how to state match specifications that cannot easily be expressed within the syntax provided by QLC.

  ```erlang
  # Options = Option | [Option]
  # Option = MnesiaOpt | QlcOption
  # MnesiaOpt = {traverse, SelectOp} | {lock, lock_kind()} | {n_objects, integer() >= 0}
  # SelectOp = select | {select, ets:match_spec()}
  # QlcOption = {key_equality, '==' | '=:='}
  table(Tab :: table()) -> qlc:query_handle()
  table(Tab :: table(), Options) -> qlc:query_handle()
  ```

  TODO: We need to support `qlc` interface, Query interface to Mnesia, ETS, Dets, and so on.
  - **Ref**: https://www.erlang.org/doc/man/qlc.html

  ### Example:

  ```elixir
      MnesiaAssistant.Table.table(Person)
  ```
  """
  def table(table), do: Mnesia.table(table)

  @doc """
  Read `table/1` document.
  """
  def table(table, options), do: Mnesia.table(table, options)

  @doc false
  def validator(:storage_properties, value) when is_list(value) do
    Enum.reduce_while(value, [], fn item, _acc ->
      case item do
        {:ets, [:compressed]} ->
          {:cont, value}

        {:dets, [{:auto_save, time_out}]} when is_integer(time_out) ->
          {:cont, value}

        _ ->
          {:halt,
           {:error, :storage_properties,
            "The options sent for the storage_properties field are incorrect"}}
      end
    end)
  end

  def validator(:storage_properties, _),
    do: {:error, :storage_properties, "The storage_properties field must be list of tuples"}

  def validator(name, value), do: {:ok, name, value}

  def start_table(start_data, module, database_config, identifier, suc_fn \\ nil) do
    {number, wait_tables, waiting_time, max_try} = start_data
    # We should wait for id_tracker table
    case wait_for_tables(wait_tables, waiting_time, identifier) do
      {:ok, :atomic} ->
        output =
          create_table(module, database_config)
          |> MnesiaAssistant.Error.error_description(module)
          |> case do
            {:ok, :atomic} ->
              re_wait_for_tables(true, [], number + 1, max_try, module, identifier, waiting_time)

            {:error, {:aborted, {:already_exists, module}}, _msg} ->
              re_wait_for_tables(true, [], number + 1, max_try, module, identifier, waiting_time)

            error ->
              Logger.error("Identifier: #{inspect(module)}; Source: #{inspect(error)}")
              {:error, :create_table, error, identifier}
          end

        if output == {:ok, :create_table, identifier} and !is_nil(suc_fn), do: suc_fn.()

        output

      error ->
        Logger.error(
          "Identifier: #{inspect(module)}; Tries to get the table again(count: #{number + 1}). Source: #{inspect(error)}"
        )

        new_output =
          MnesiaAssistant.Table.wait_for_tables(wait_tables, waiting_time, identifier)

        new_output
        |> MnesiaAssistant.Error.try?(max_try, number)
        |> re_wait_for_tables(new_output, number + 1, max_try, module, identifier, waiting_time)
    end
  end

  defp re_wait_for_tables(false, {:ok, :atomic}, _, _, _, identifier, _) do
    :persistent_term.put(identifier, %{table: true})
    {:ok, :create_table, identifier}
  end

  defp re_wait_for_tables(false, output, number, _, module, identifier, _) do
    Logger.error(
      "Identifier: #{inspect(module)}; Tries to get the table again(count: #{number + 1}). Source: #{inspect(output)}"
    )

    {:error, :create_table, output, identifier}
  end

  defp re_wait_for_tables(true, _output, number, max_try, module, identifier, waiting_time) do
    Logger.warning(
      "Identifier: #{inspect(module)}; Tries to get the table again(count: #{number})."
    )

    new_output =
      MnesiaAssistant.Table.wait_for_tables([module], waiting_time, module)

    new_output
    |> MnesiaAssistant.Error.try?(max_try, number)
    |> re_wait_for_tables(new_output, number + 1, max_try, module, identifier, waiting_time)
  end
end
