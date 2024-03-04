defmodule MnesiaAssistant.Query do
  alias :mnesia, as: Mnesia
  @table_lock_types [:read, :write, :sticky_write]

  def read({table, key}), do: Mnesia.read(table, key)

  def read(table, key), do: Mnesia.read(table, key)

  def read(table, key, lock_type) when lock_type in @table_lock_types,
    do: Mnesia.read(table, key, lock_type)

  # mnesia:read(Tab, Key, write)
  def wread({table, key}), do: Mnesia.wread({table, key})

  # mnesia:index_read(person, 36, age)
  def index_read(table, key, attr), do: Mnesia.index_read(table, key, attr)

  def first(table), do: Mnesia.first(table) |> check_nil_end_of_table()

  def last(table), do: Mnesia.last(table) |> check_nil_end_of_table()

  def next(table, key), do: Mnesia.next(table, key) |> check_nil_end_of_table()

  def prev(table, key), do: Mnesia.prev(table, key) |> check_nil_end_of_table()

  # MatchHead = #person{name='$1', sex=male, age='$2', _='_'},
  # Guard = {'>', '$2', 30},
  # Result = '$1',
  # mnesia:select(Tab,[{MatchHead, [Guard], [Result]}]),
  def delete(table, key, lock_type) when lock_type in [:write, :sticky_write] do
    Mnesia.delete(table, key, lock_type)
  end

  def delete(table, key), do: Mnesia.delete({table, key})

  # delete_object(Tab :: table(), Rec :: tuple(), LockKind :: write_locks())
  def delete_object(record) when is_tuple(record), do: Mnesia.delete_object(record)

  def delete_object(table, record, lock_type)
      when is_tuple(record) and lock_type in [:write, :sticky_write],
      do: Mnesia.delete_object(table, record, lock_type)

  # mnesia:delete(Tab, Key, sticky_write)
  def s_delete({table, key}), do: Mnesia.s_delete({table, key})

  # mnesia:delete_object(Tab, Record, sticky_write), where Tab is element(1, Record)
  def s_delete_object(record), do: Mnesia.s_delete_object(record)

  def write(name, data, lock_type \\ :write) when lock_type in [:write, :sticky_write] do
    Mnesia.write(name, data, lock_type)
  end

  # mnesia:write(Tab, Record, sticky_write), where Tab is element(1, Record)
  def s_write(record), do: Mnesia.s_write(record)

  def select(table, match_fields, conds, lock_type, opts)
      when is_list(match_fields) and is_list(conds) and lock_type in @table_lock_types do
    result_type = Keyword.get(opts, :result_type, [:"$$"])
    lock_type = Keyword.get(opts, :lock_type)
    converted = select_converter(table, match_fields, conds, result_type)

    cond do
      is_nil(lock_type) -> Mnesia.select(table, converted, lock_type)
      !is_nil(lock_type) and lock_type in @table_lock_types -> Mnesia.select(table, converted)
      true -> raise "The input of the select function is wrong. Do according to the document"
    end
  end

  # Mnesia.match_object({Person, :_, "Marge Simpson", :_})
  def match_object(table, pattern) when is_list(pattern) do
    pattern = ([table] ++ [pattern]) |> List.to_tuple()
    Mnesia.match_object(pattern)
  end

  def match_object(table, pattern, lock_type)
      when is_list(pattern) and lock_type in @table_lock_types do
    pattern = ([table] ++ [pattern]) |> List.to_tuple()
    Mnesia.match_object(table, pattern, lock_type)
  end

  # Fun = fun({account, _AccountID, Balance}, Acc) -> Acc + Balance end,
  # InitialAcc = 0
  # mnesia:foldl(Fun, InitialAcc, account) end)
  def foldl(table, initial_acc, foldl_fun) when is_function(foldl_fun) do
    Mnesia.foldl(foldl_fun, initial_acc, table)
  end

  def foldl(table, initial_acc, foldl_fun, lock_type)
      when is_function(foldl_fun) and lock_type in @table_lock_types do
    Mnesia.foldl(foldl_fun, initial_acc, table, lock_type)
  end

  def foldr(table, initial_acc, foldr_fun) when is_function(foldr_fun) do
    Mnesia.foldr(foldr_fun, initial_acc, table)
  end

  def foldr(table, initial_acc, foldr_fun, lock_type)
      when is_function(foldr_fun) and lock_type in @table_lock_types do
    Mnesia.foldr(foldr_fun, initial_acc, table, lock_type)
  end

  def dirty_match_object(table, pattern) when is_list(pattern) do
    pattern = ([table] ++ [pattern]) |> List.to_tuple()
    Mnesia.dirty_match_object(pattern)
  end

  def dirty_match_object(pattern) when is_tuple(pattern), do: Mnesia.dirty_match_object(pattern)

  def dirty_read(module, key), do: Mnesia.dirty_read(module, key)

  def dirty_index_read(table, key, attr), do: Mnesia.dirty_index_read(table, key, attr)

  def dirty_first(table), do: Mnesia.dirty_first(table) |> check_nil_end_of_table()

  def dirty_last(table), do: Mnesia.dirty_last(table) |> check_nil_end_of_table()

  def dirty_next(table, key), do: Mnesia.dirty_next(table, key) |> check_nil_end_of_table()

  def dirty_prev(table, key), do: Mnesia.dirty_prev(table, key) |> check_nil_end_of_table()

  def dirty_delete(table, key), do: Mnesia.dirty_delete(table, key)

  def dirty_delete({table, key}), do: Mnesia.dirty_delete(table, key)

  def dirty_delete_object(record) when is_tuple(record), do: Mnesia.dirty_delete_object(record)

  def dirty_write(name, data), do: Mnesia.dirty_write(name, data)

  def dirty_index_match_object(pattern, index_attr),
    do: Mnesia.dirty_index_match_object(pattern, index_attr)

  def dirty_index_match_object(table, pattern, index_attr),
    do: Mnesia.dirty_index_match_object(table, pattern, index_attr)

  def dirty_select(table, match_fields, conds, result_type \\ [:"$$"]) do
    Mnesia.dirty_select(table, select_converter(table, match_fields, conds, result_type))
  end

  def dirty_select(table, spec), do: Mnesia.dirty_select(table, spec)

  # dirty_update_counter(Counter :: {Tab :: table(), Key :: term()}, Incr :: integer())
  def dirty_update_counter({table, key}, incr) when is_integer(incr),
    do: Mnesia.dirty_update_counter({table, key}, incr)

  # dirty_update_counter(Tab :: table(), Key :: term(), Incr :: integer())
  def dirty_update_counter(table, key, incr) when is_integer(incr),
    do: Mnesia.dirty_update_counter(table, key, incr)

  def is_transaction?(), do: Mnesia.is_transaction()

  def transaction(transaction_fn) when is_function(transaction_fn) do
    Mnesia.transaction(transaction_fn)
  end

  def transaction(transaction_fn, retries)
      when is_function(transaction_fn) and (is_integer(retries) or retries == :infinity) do
    Mnesia.transaction(transaction_fn, retries)
  end

  def transaction(transaction_fn, attrs) when is_function(transaction_fn) and is_list(attrs) do
    Mnesia.transaction(transaction_fn, attrs)
  end

  def transaction(transaction_fn, attrs, retries)
      when is_function(transaction_fn) and is_list(attrs) and
             (is_integer(retries) or retries == :infinity) do
    Mnesia.transaction(transaction_fn, attrs, retries)
  end

  def sync_dirty(sync_dirty_fn) when is_function(sync_dirty_fn),
    do: Mnesia.sync_dirty(sync_dirty_fn)

  def sync_dirty(sync_dirty_fn, args) when is_function(sync_dirty_fn) and is_list(args) do
    Mnesia.sync_dirty(sync_dirty_fn, args)
  end

  defp check_nil_end_of_table(:"$end_of_table"), do: nil
  defp check_nil_end_of_table(value), do: value

  defp select_converter(table, match_fields, conds, result_type) do
    fields_pattern = ([table] ++ match_fields) |> List.to_tuple()

    conds =
      Enum.map(conds, fn {cond, field, value} ->
        {Helper.Extra.elixir_to_erlang_guard(cond), field, value}
      end)

    [{fields_pattern, conds, result_type}]
  end
end
