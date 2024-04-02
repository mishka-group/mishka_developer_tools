defmodule MnesiaAssistant.Query do
  @moduledoc """
  **Querying** is one of the most significant aspects of working with the **database**;
  for this reason, you can access the aggregation functions of `Mnesia`
  in this section of the database.
  """
  alias :mnesia, as: Mnesia
  alias MishkaDeveloperTools.Helper.Extra
  @table_lock_types [:read, :write, :sticky_write]

  @doc """
  The database can be accessed through the use of this function to retrieve a record.
  It is important to remind you that if you are seeking for a
  reliable assurance for the retrieval of data, you can utilise transaction.

  ### Example:

  ```elixir
    MnesiaAssistant.Transaction.transaction(fn ->
      MnesiaAssistant.Query.read({Person, 20})
    end)
    # OR
    MnesiaAssistant.Query.read(Person, 20)
    # OR use one of @table_lock_types [:read, :write, :sticky_write]
    MnesiaAssistant.Query.read(Person, 20, lock_type)
  ```

  > Reads all records from table Tab with key Key.
  > This function has the same semantics regardless of the location of Tab.
  > If the table is of type `bag`, the function `mnesia:read(Tab, Key)` can return
  > an arbitrarily long list. If the table is of type set, the list
  > is either of length `1`, or `[]`.

  **Note**: The LockKind ([:read, :write, :sticky_write]) argument is used to control the
  locking behavior during the read operation, which can influence data consistency and
  concurrency control for the operation.
  """
  def read({table, key}), do: Mnesia.read(table, key)

  def read(table, key), do: Mnesia.read(table, key)

  def read(table, key, lock_type) when lock_type in @table_lock_types,
    do: Mnesia.read(table, key, lock_type)

  # mnesia:read(Tab, Key, write)
  @doc """
  It is like `read/3` with `:write` LockKind.

  ### Example:

  ```elixir
    MnesiaAssistant.Query.wread(Person, 20)
  ```
  """
  def wread({table, key}), do: Mnesia.wread({table, key})

  # mnesia:index_read(person, 36, age)
  @doc """
  Assume that there is an index on position Pos for a certain record type.
  This function can be used to read the records without knowing the actual `key`
  for the record. For example, with an index in position 1 of table person,
  the call `mnesia:index_read(person, 36, #person.age)` returns a list of all
  persons with age 36. Pos can also be an attribute name (atom),
  but if the notation `mnesia:index_read(person, 36, age)` is used,
  the field position is searched for in runtime, for each call.

  ### Example:

  ```elixir
    MnesiaAssistant.Query.index_read(Person, 20, :age)
  ```
  """
  def index_read(table, key, attr), do: Mnesia.index_read(table, key, attr)

  @doc """
  Returns first record of the table concerned.

  ### Example:

  ```elixir
    MnesiaAssistant.Query.first(Person)
  ```
  """
  def first(table), do: Mnesia.first(table) |> check_nil_end_of_table()

  @doc """
  Returns last record of the table concerned.

  ### Example:

  ```elixir
    MnesiaAssistant.Query.last(Person)
  ```
  """
  def last(table), do: Mnesia.last(table) |> check_nil_end_of_table()

  @doc """
  Returns next record of the table concerned from your selected :id as the key.

  ### Example:

  ```elixir
    MnesiaAssistant.Query.next(Person, 1)
  ```
  """
  def next(table, key), do: Mnesia.next(table, key) |> check_nil_end_of_table()

  @doc """
  Returns prev record of the table concerned from your selected :id as the key.

  ### Example:

  ```elixir
    MnesiaAssistant.Query.prev(Person, 1)
  ```
  """
  def prev(table, key), do: Mnesia.prev(table, key) |> check_nil_end_of_table()

  @doc """
  By using this function, you will be able to delete a record from
  the table based on the key that you desire.

  **Note**: The LockKind ([:write, :sticky_write]) argument is used to control the
  locking behavior during the delete operation, which can influence data consistency and
  concurrency control for the operation.

  ### Example:

  ```elixir
    MnesiaAssistant.Query.delete(Person, 1, :write)
    # OR
    MnesiaAssistant.Query.delete(Person, 1)
  ```
  """
  def delete(table, key, lock_type) when lock_type in [:write, :sticky_write] do
    Mnesia.delete(table, key, lock_type)
  end

  @doc """
  Read `delete/3` document.
  """
  def delete(table, key), do: Mnesia.delete({table, key})

  @doc """
  To use `:mnesia.delete_object/3` in Elixir, you need to specify the table from
  which to delete (Tab), the complete record to be deleted (Rec),
  and the lock type (LockKind). This function is particularly useful
  when you need to delete a specific record and you know the entire tuple
  structure of that record.

  ### Example:

  ```elixir
    record_to_delete = {Person, 2, "John Doe", 30}

    MnesiaAssistant.Query.delete_object(record_to_delete)
    # OR
    MnesiaAssistant.Query.delete_object(Person, record_to_delete, :write)
  ```
  """
  def delete_object(record) when is_tuple(record), do: Mnesia.delete_object(record)

  @doc """
  Read `delete_object/1` document.
  """
  def delete_object(table, record, lock_type)
      when is_tuple(record) and lock_type in [:write, :sticky_write],
      do: Mnesia.delete_object(table, record, lock_type)

  @doc """
  It is like `MnesiaAssistant.Query.delete(table, key, :sticky_write)`.
  For more information read `delete/3` or `mnesia:delete(Tab, Key, sticky_write)`.

  ### Example:

  ```elixir
    MnesiaAssistant.Query.s_delete(Person, 20)
  ```
  """
  def s_delete({table, key}), do: Mnesia.s_delete({table, key})

  @doc """
  It is like `MnesiaAssistant.Query.delete_object(table, record, :sticky_write)`
  where Tab is element(1, Record).
  For more information read `delete_object/3` or `mnesia:delete_object(Tab, Record, sticky_write)`.

  ### Example:

  ```elixir
    MnesiaAssistant.Query.s_delete_object({Person, 2, "John Doe", 30})
  ```
  """
  def s_delete_object(record), do: Mnesia.s_delete_object(record)

  @doc """
  The following function will help you update a record of a table
  based on a specific key.

  **Note**: The LockKind ([:write, :sticky_write]) argument is used to control the
  locking behavior during the write operation, which can influence data consistency and
  concurrency control for the operation.

  ### Example:

  ```elixir
    updated_person = {Person, id, name, new_age}

    MnesiaAssistant.Query.write(Person, updated_person)
    # OR
    MnesiaAssistant.Query.write(Person, updated_person, :write)
    # OR
    MnesiaAssistant.Query.write(updated_person)
  ```
  """
  def write(table, record, lock_type \\ :write) when lock_type in [:write, :sticky_write] do
    Mnesia.write(table, record, lock_type)
  end

  @doc """
  Read `write/3` document.
  """
  def write(record), do: Mnesia.write(record)

  @doc """
  It is like `MnesiaAssistant.Query.write(Person, updated_person, :sticky_write)` or
  `mnesia:write(Tab, Record, sticky_write)`.
  For more information read `write/3`.

  ### Example:

  ```elixir
    updated_person = {Person, id, name, new_age}

    MnesiaAssistant.Query.s_write(updated_person)
  ```
  """
  def s_write(record), do: Mnesia.s_write(record)

  @doc """
  The `select/5` function allows you to specify a custom query using any
  operator or function in the Elixir language (or Erlang for that matter).

  ### Example:

  ```elixir
    alias MnesiaAssistant.Query

    Query.select(Person, [{{Person, :"$1", :"$2", :"$3"}, [{:>, :"$1", 3}], [:"$$"]}])
    # OR you can use this helper `select/5`
    Query.select(
      Person,
      [:"$1", :"$2", :"$3"],
      [{:>, :"$1", 3}],
      :write,
      [result_type: [:"$$"], lock_type: :write]
    )
  ```
  """
  def select(table, match_fields, conds, opts, :custom)
      when is_list(match_fields) and is_list(conds) do
    result_type = Keyword.get(opts, :result_type, [:"$$"])
    lock_type = Keyword.get(opts, :lock_type)
    converted = select_converter(table, match_fields, conds, result_type)

    cond do
      is_nil(lock_type) -> Mnesia.select(table, converted, lock_type)
      !is_nil(lock_type) and lock_type in @table_lock_types -> Mnesia.select(table, converted)
      true -> raise "The input of the select function is wrong. Do according to the document"
    end
  end

  @doc """
  Read `select/5` document.
  """
  def select(table, spec, limit, lock_type) when lock_type in @table_lock_types do
    Mnesia.select(table, spec, limit, lock_type)
  end

  @doc """
  Read `select/5` document.
  """
  def select(table, spec), do: Mnesia.select(table, spec)

  @doc """
  Read `select/5` document.
  """
  def select(table, spec, lock_type) when lock_type in @table_lock_types do
    Mnesia.select(table, spec, lock_type)
  end

  @doc """
  Read `select/5` document.
  """
  def select(cont), do: Mnesia.select(cont)

  @doc """
  There is a distinction between this method and the `select` function,
  which is that you are aware of the record that you wish to remove from the table.
  It is like: `:mnesia.match_object({Person, :_, "Mishka", :_})`

  ### Example:

  ```elixir
    alias MnesiaAssistant.Query

    Query.match_object(Person, [:_, "Mishka", :_])
    # OR
    Query.match_object(Person, [:_, "Mishka", :_], :write)
    # OR
    Query.match_object(Person, {Person, :_, "Mishka", :_}, :write)
    # OR
    Query.match_object({Person, :_, "Mishka", :_})
  ```
  """
  def match_object(table, pattern) when is_list(pattern) do
    pattern = ([table] ++ [pattern]) |> List.to_tuple()
    Mnesia.match_object(pattern)
  end

  @doc """
  Read `match_object/2` document.
  """
  def match_object(table, pattern, lock_type)
      when is_list(pattern) and lock_type in @table_lock_types do
    pattern = ([table] ++ [pattern]) |> List.to_tuple()
    Mnesia.match_object(table, pattern, lock_type)
  end

  def match_object(table, pattern, lock_type)
      when is_tuple(pattern) and lock_type in @table_lock_types do
    Mnesia.match_object(table, pattern, lock_type)
  end

  @doc """
  Read `match_object/2` document.
  """
  def match_object(pattern), do: Mnesia.match_object(pattern)

  # Fun = fun({account, _AccountID, Balance}, Acc) -> Acc + Balance end,
  # InitialAcc = 0
  # mnesia:foldl(Fun, InitialAcc, account) end)
  @doc """
  it is like `Enum.reduce`.

  ### Example:

  ```elixir
    initial_acc = 0

    fun = fn {:people, _id, _name, age}, acc ->
      acc + age
    end

    MnesiaAssistant.Query.foldl(Person, initial_acc, fun)
    # OR
    MnesiaAssistant.Query.foldl(Person, initial_acc, fun, :write)
    # OR
    MnesiaAssistant.Transaction.transaction(fn ->
      MnesiaAssistant.Query.foldl(Person, initial_acc, fun)
    end)
  ```
  """
  def foldl(table, initial_acc, foldl_fun) when is_function(foldl_fun) do
    Mnesia.foldl(foldl_fun, initial_acc, table)
  end

  @doc """
  Read `foldl/3` document.
  """
  def foldl(table, initial_acc, foldl_fun, lock_type)
      when is_function(foldl_fun) and lock_type in @table_lock_types do
    Mnesia.foldl(foldl_fun, initial_acc, table, lock_type)
  end

  @doc """
  Works exactly like foldl/3 but iterates the table in the opposite order for the `ordered_set`
  table type. For all other table types, `foldr/3` and `foldl/3` are synonyms.

  Read `foldl/3` document.
  """
  def foldr(table, initial_acc, foldr_fun) when is_function(foldr_fun) do
    Mnesia.foldr(foldr_fun, initial_acc, table)
  end

  @doc """
  Read `foldr/3` document.
  """
  def foldr(table, initial_acc, foldr_fun, lock_type)
      when is_function(foldr_fun) and lock_type in @table_lock_types do
    Mnesia.foldr(foldr_fun, initial_acc, table, lock_type)
  end

  @doc """
  In a manner similar to the function `mnesia:index_read/3`, any index information can
  be used when trying to match records. This function takes a pattern that
  obeys the same rules as the function `mnesia:match_object/3`, except that this
  function requires the following conditions:

  * The table Tab must have an index on position Pos.
  * The element in position Pos in Pattern must be bound. Pos is an integer (`#record.Field`) or an attribute name.

  > The two index search functions described here are automatically
  > started when searching tables with qlc list comprehensions and
  > also when using the low-level `mnesia:[dirty_]match_object` functions.

  The semantics of this function is context-sensitive. For details,
  `see mnesia:activity/4`. In transaction-context, it acquires a lock of type
  LockKind on the entire table or on a single record. Currently,
  the lock type read is supported.

  ### Example:

  ```elixir
    MnesiaAssistant.Query.index_match_object({Person, :_, "Mishka", :_}, 30)
    MnesiaAssistant.Query.index_match_object(Person, {Person, :_, "Mishka", :_}, 30, :write)
  ```
  """
  def index_match_object(pattern, index_attr) when is_tuple(pattern),
    do: Mnesia.index_match_object(pattern, index_attr)

  def index_match_object(table, pattern, index_attr, lock_type)
      when lock_type in @table_lock_types and is_tuple(pattern),
      do: Mnesia.index_match_object(table, pattern, index_attr, lock_type)

  @doc """
    There is a distinction between this method and the `select` function,
    which is that you are aware of the record that you wish to remove from the table.
    It is like: `:mnesia.match_object({Person, :_, "Mishka", :_})`

    ### Example:

    ```elixir
      alias MnesiaAssistant.Query

      Query.dirty_match_object(Person, [:_, "Mishka", :_])
      # OR
      Query.dirty_match_object(Person, {Person, :_, "Mishka", :_})
      # OR
      Query.dirty_match_object({Person, :_, "Mishka", :_})
  ```

  > **Note**: In the context of `mnesia`, the `dirty` keyword indicates that it
  > encompasses the maximum speed, but it does not guarantee that it will execute correctly.
  """
  def dirty_match_object(table, pattern) when is_list(pattern) do
    pattern = ([table] ++ [pattern]) |> List.to_tuple()
    Mnesia.dirty_match_object(pattern)
  end

  def dirty_match_object(table, pattern) when is_tuple(pattern) do
    Mnesia.dirty_match_object(table, pattern)
  end

  @doc """
  Read `dirty_match_object/2` document.
  """
  def dirty_match_object(pattern) when is_tuple(pattern), do: Mnesia.dirty_match_object(pattern)

  @doc """
  The database can be accessed through the use of this function to retrieve a record.
  It is important to remind you that if you are seeking for a
  reliable assurance for the retrieval of data, you can utilise transaction.

  > **Note**: In the context of `mnesia`, the `dirty` keyword indicates that it
  > encompasses the maximum speed, but it does not guarantee that it will execute correctly.

  ### Example:

  ```elixir
    alias MnesiaAssistant.Query

    Query.dirty_read(Person, 20)
  ```
  """
  def dirty_read(module, key), do: Mnesia.dirty_read(module, key)

  @doc """
  Dirty equivalent of the function `index_read/3`.

  > **Note**: In the context of `mnesia`, the `dirty` keyword indicates that it
  > encompasses the maximum speed, but it does not guarantee that it will execute correctly.

  ### Example:

  ```elixir
    MnesiaAssistant.Query.dirty_index_read(Person, 20, :age)
  ```

  > Attr = index_attr()
  """
  def dirty_index_read(table, key, attr), do: Mnesia.dirty_index_read(table, key, attr)

  @doc """
  Dirty equivalent of the function `first/1`.

  > **Note**: In the context of `mnesia`, the `dirty` keyword indicates that it
  > encompasses the maximum speed, but it does not guarantee that it will execute correctly.

  ### Example:

  ```elixir
    MnesiaAssistant.Query.dirty_first(Person)
  ```
  """
  def dirty_first(table), do: Mnesia.dirty_first(table) |> check_nil_end_of_table()

  @doc """
  Dirty equivalent of the function `last/1`.

  > **Note**: In the context of `mnesia`, the `dirty` keyword indicates that it
  > encompasses the maximum speed, but it does not guarantee that it will execute correctly.

  ### Example:

  ```elixir
    MnesiaAssistant.Query.dirty_last(Person)
  ```
  """
  def dirty_last(table), do: Mnesia.dirty_last(table) |> check_nil_end_of_table()

  @doc """
  Dirty equivalent of the function `next/2`.

  > **Note**: In the context of `mnesia`, the `dirty` keyword indicates that it
  > encompasses the maximum speed, but it does not guarantee that it will execute correctly.

  ### Example:

  ```elixir
    MnesiaAssistant.Query.dirty_next(Person, 20)
  ```
  """
  def dirty_next(table, key), do: Mnesia.dirty_next(table, key) |> check_nil_end_of_table()

  @doc """
  Dirty equivalent of the function `prev/2`.

  > **Note**: In the context of `mnesia`, the `dirty` keyword indicates that it
  > encompasses the maximum speed, but it does not guarantee that it will execute correctly.

  ### Example:

  ```elixir
    MnesiaAssistant.Query.dirty_prev(Person, 20)
  ```
  """
  def dirty_prev(table, key), do: Mnesia.dirty_prev(table, key) |> check_nil_end_of_table()

  @doc """
  Dirty equivalent of the function `delete/2`.

  > **Note**: In the context of `mnesia`, the `dirty` keyword indicates that it
  > encompasses the maximum speed, but it does not guarantee that it will execute correctly.

  ### Example:

  ```elixir
    MnesiaAssistant.Query.dirty_delete(Person, 20)
    # OR
    MnesiaAssistant.Query.dirty_delete({Person, 20})
  ```
  """
  def dirty_delete(table, key), do: Mnesia.dirty_delete(table, key)

  @doc """
  Read `dirty_delete/1` document.
  """
  def dirty_delete({table, key}), do: Mnesia.dirty_delete(table, key)

  @doc """
  Dirty equivalent of the function `delete_object/1`.

  > **Note**: In the context of `mnesia`, the `dirty` keyword indicates that it
  > encompasses the maximum speed, but it does not guarantee that it will execute correctly.

  ### Example:

  ```elixir
    Query.dirty_delete_object({Person, :_, "Mishka", :_})
  ```
  """
  def dirty_delete_object(record) when is_tuple(record), do: Mnesia.dirty_delete_object(record)

  @doc """
  Read `dirty_delete_object/1` document.
  """
  def dirty_delete_object(table, record) when is_tuple(record),
    do: Mnesia.dirty_delete_object(table, record)

  @doc """
  Dirty equivalent of the function `write/1`.

  > **Note**: In the context of `mnesia`, the `dirty` keyword indicates that it
  > encompasses the maximum speed, but it does not guarantee that it will execute correctly.

  ### Example:

  ```elixir
    updated_person = {Person, id, name, new_age}

    MnesiaAssistant.Query.dirty_write(Person, updated_person)
    # OR
    MnesiaAssistant.Query.dirty_write(updated_person)
  ```
  """
  def dirty_write(table, record), do: Mnesia.dirty_write(table, record)

  @doc """
  Read `dirty_write/2` document.
  """
  def dirty_write(record), do: Mnesia.dirty_write(record)

  @doc """
  Dirty equivalent of the function `index_match_object/2`.

  > **Note**: In the context of `mnesia`, the `dirty` keyword indicates that it
  > encompasses the maximum speed, but it does not guarantee that it will execute correctly.

  ### Example:

  ```elixir
    MnesiaAssistant.Query.dirty_index_match_object({Person, :_, "Mishka", :_}, 30)
    MnesiaAssistant.Query.dirty_index_match_object(Person, {Person, :_, "Mishka", :_}, 30)
  ```
  """
  def dirty_index_match_object(pattern, index_attr),
    do: Mnesia.dirty_index_match_object(pattern, index_attr)

  @doc """
  Read `dirty_index_match_object/2` document.
  """
  def dirty_index_match_object(table, pattern, index_attr),
    do: Mnesia.dirty_index_match_object(table, pattern, index_attr)

  @doc """
  Dirty equivalent of the function `select/5`.

  > **Note**: In the context of `mnesia`, the `dirty` keyword indicates that it
  > encompasses the maximum speed, but it does not guarantee that it will execute correctly.

  ### Example:

  ```elixir
    MnesiaAssistant.Query.dirty_select(Person, [{{Person, :"$1", :"$2", :"$3"}, [{:>, :"$1", 3}], [:"$$"]}])
    # OR
    MnesiaAssistant.Query.dirty_select(
      Person,
      [:"$1", :"$2", :"$3"],
      [{:>, :"$1", 3}],
      [:"$$"]
    )
  ```
  """
  def dirty_select(table, match_fields, conds, result_type \\ [:"$$"]) do
    Mnesia.dirty_select(table, select_converter(table, match_fields, conds, result_type))
  end

  @doc """
  Read `dirty_select/4` document.
  """
  def dirty_select(table, spec), do: Mnesia.dirty_select(table, spec)

  @doc """
  Mnesia has no special counter records. However, records of the form `{Tab, Key, Integer}`
  can be used as (possibly `disc-resident`) counters when Tab is a set.
  This function updates a counter with a positive or negative number.
  However, counters can never become less than zero. There are two significant
  differences between this function and the action of first reading the record,
  performing the arithmetic, and then writing the record:

  1. It is much more efficient.
  2. `mnesia:dirty_update_counter/3` is performed as an atomic operation although it is
  not protected by a transaction.

  ---

  If two processes perform `mnesia:dirty_update_counter/3` simultaneously,
  both updates take effect without the risk of losing one of the updates.
  The new value NewVal of the counter is returned.

  > If Key does not exist, a new record is created with value Incr if it is larger than 0,
  > otherwise it is set to 0.

  > **Note**: In the context of `mnesia`, the `dirty` keyword indicates that it
  > encompasses the maximum speed, but it does not guarantee that it will execute correctly.

  ### Example:

  ```elixir
    MnesiaAssistant.Query.dirty_update_counter(:counters, :visits, 1)
    # OR+
    MnesiaAssistant.Query.dirty_update_counter({:counters, :visits}, 1)
  ```
  """
  def dirty_update_counter({table, key}, incr) when is_integer(incr),
    do: Mnesia.dirty_update_counter({table, key}, incr)

  @doc """
  Read `dirty_update_counter/2` document.
  """
  def dirty_update_counter(table, key, incr) when is_integer(incr),
    do: Mnesia.dirty_update_counter(table, key, incr)

  @doc """
  Calls the Fun in a context that is not protected by a transaction.
  The `Mnesia` function calls performed in the Fun are mapped to the corresponding
  dirty functions. It is performed in almost the same context as `mnesia:async_dirty/1,2`.
  The difference is that the operations are performed synchronously.
  The caller waits for the updates to be performed on all active replicas
  before the Fun returns. For details, see `mnesia:activity/4` and the User's Guide.

  > **Note**: In the context of `mnesia`, the `dirty` keyword indicates that it
  > encompasses the maximum speed, but it does not guarantee that it will execute correctly.

  ### Example:

  ```elixir
    MnesiaAssistant.Query.sync_dirty(fn -> something end)
    # OR
    MnesiaAssistant.Query.sync_dirty(fn -> something end, args)
  ```
  """
  def sync_dirty(sync_dirty_fn) when is_function(sync_dirty_fn),
    do: Mnesia.sync_dirty(sync_dirty_fn)

  @doc """
  Read `sync_dirty/1` document.
  """
  def sync_dirty(sync_dirty_fn, args) when is_function(sync_dirty_fn) and is_list(args) do
    Mnesia.sync_dirty(sync_dirty_fn, args)
  end

  @doc """
  When this function is executed inside a transaction-context, it returns true, otherwise false.
  """
  def is_transaction?(), do: Mnesia.is_transaction()

  defp check_nil_end_of_table(:"$end_of_table"), do: nil
  defp check_nil_end_of_table(value), do: value

  defp select_converter(table, match_fields, conds, result_type) do
    fields_pattern = ([table] ++ match_fields) |> List.to_tuple()

    conds =
      Enum.map(conds, fn {cond, field, value} -> {Extra.erlang_guard(cond), field, value} end)

    [{fields_pattern, conds, result_type}]
  end
end
