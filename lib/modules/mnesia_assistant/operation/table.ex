defmodule MnesiaAssistant.Table do
  use GuardedStruct
  alias :mnesia, as: Mnesia

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

  @table_lock_types [:read, :write, :sticky_write]
  @change_table_access_mode_types [:read_only, :read_write]

  guardedstruct error: true do
    # Defines the read/write access mode for the table.
    field(:access_mode, atom(), derive: "validate(enum=Atom[read_write::read_only])")
    # Specifies which nodes should store disc copies of the table.
    field(:disc_copies, list(node()), derive: "validate(list, not_empty)")
    # Specifies nodes that store the table entirely on disk.
    field(:disc_only_copies, list(node()), derive: "validate(list, not_empty)")
    # Specifies nodes that should keep the table in RAM.
    field(:ram_copies, list(node()), derive: "validate(list, not_empty)")
    # Defines additional attributes to be indexed.
    field(:index, list(atom()), derive: "validate(list, not_empty)")
    # Specifies the order in which tables should be loaded.
    field(:load_order, non_neg_integer(), derive: "validate(integer)")
    # Ensures a majority of replicas must write successfully for a transaction to commit.
    field(:majority, boolean(), derive: "validate(boolean)")
    # Sets the name of the record.
    field(:record_name, atom(), derive: "validate(atom)")
    # Specifies SNMP (Simple Network Management Protocol) options.
    # Less commonly used in Elixir projects.
    field(:snmp, map(), derive: "validate(map, not_empty)")
    # Defines custom storage properties. Its usage is advanced and depends on the storage type.
    field(:storage_properties, list(tuple()), derive: "validate(list, not_empty)")
    # Defines the type of the table.
    field(:type, table_type(), derive: "validate(enum=Atom[set::ordered_set::bag])")
    # Ensures the table's content is only relevant to the local node.
    field(:local_content, boolean(), derive: "validate(boolean)")
    # Defines the schema of the table, i.e., the columns.
    field(:attributes, list(atom()), enforce: true, derive: "validate(list, not_empty)")
  end

  # Table
  def create_table(module, opts) when is_map(opts) do
    case __MODULE__.builder(opts, true) do
      {:ok, data} ->
        converted = Map.from_struct(data) |> Enum.reject(fn {_, v} -> is_nil(v) end)

        Mnesia.create_table(module, converted)
        |> MnesiaAssistant.Error.error()

      error ->
        error
    end
  end

  def create_table(module, opts) when is_list(opts) do
    Mnesia.create_table(module, opts)
    |> MnesiaAssistant.Error.error()
  end

  def add_table_index(module, field) when is_atom(field) do
    Mnesia.add_table_index(module, field)
  end

  def table_info(module, type \\ :attributes) when is_atom(type) and type in @table_info_types do
    Mnesia.table_info(module, type)
  end

  def change_table_copy_type(module, type) when type in @create_table_types do
    Mnesia.change_table_copy_type(module, node(), type)
  end

  def wait_for_tables(tables, timeout) when is_list(tables) and is_integer(timeout),
    do: Mnesia.wait_for_tables(tables, timeout)

  def transform_table(table, transform_fun, fields: fields)
      when is_function(transform_fun) and is_list(fields),
      do: Mnesia.transform_table(table, transform_fun, fields)

  def transform_table(table, transform_fun, fields: fields, rec_name: rec_name)
      when is_function(transform_fun) and is_list(fields),
      do: Mnesia.transform_table(table, transform_fun, fields, rec_name)

  def lock(key, nodes, type) when type in @table_lock_types do
    Mnesia.lock({:global, key, nodes}, type)
  end

  def lock(opts, type) when type in @table_lock_types, do: Mnesia.lock(opts, type)

  def write_lock_table(table), do: Mnesia.write_lock_table(table)

  def ets(ets_fn) when is_function(ets_fn), do: Mnesia.ets(ets_fn)

  def ets(ets_fn, args) when is_function(ets_fn) and is_list(args), do: Mnesia.ets(ets_fn, args)

  def force_load_table(table), do: Mnesia.force_load_table(table)

  def exists?(name) do
    MnesiaAssistant.Information.info({:system, :tables})
    |> Enum.member?(name)
  end

  def is_bag?(module), do: table_info(module, :type) == :bag

  def is_set?(module), do: table_info(module, :type) == :set

  def is_ordered_set?(module), do: table_info(module, :type) == :ordered_set

  def change_table_access_mode(module, type) when type in @change_table_access_mode_types do
    Mnesia.change_table_access_mode(module, type)
  end

  def change_table_load_order(module, order) when is_integer(order),
    do: Mnesia.change_table_load_order(module, order)

  def change_table_majority(module, status) when is_boolean(status),
    do: Mnesia.change_table_majority(module, status)

  def add_table_copy(module, node, type) when type in @storage_types,
    do: Mnesia.add_table_copy(module, node, type)

  def move_table_copy(module, from: from, to: to) do
    Mnesia.move_table_copy(module, from, to)
  end

  def del_table_copy(module, node), do: Mnesia.del_table_copy(module, node)

  def del_table_index(module, attribute) when is_atom(attribute),
    do: Mnesia.del_table_index(module, attribute)

  def set_master_nodes(nodes) when is_list(nodes),
    do: Mnesia.set_master_nodes(nodes)

  def set_master_nodes(module, nodes) when is_list(nodes),
    do: Mnesia.set_master_nodes(module, nodes)

  def delete_table(module), do: Mnesia.delete_table(module)

  def clear_table(module), do: Mnesia.clear_table(module)

  def count(module), do: table_info(module, :size)

  def all_keys(module), do: Mnesia.all_keys(module)

  def dirty_all_keys(module), do: Mnesia.dirty_all_keys(module)

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
end
