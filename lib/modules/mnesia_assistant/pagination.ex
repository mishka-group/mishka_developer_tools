defmodule MnesiaAssistant.Pagination do
  alias MnesiaAssistant.{Transaction, Query}
  import MnesiaAssistant, only: [eg: 1, er: 1, tuple_to_map: 4]

  def infinite_scroll({_record, _cont} = output, _table, keys, strc, _limit) do
    infinite_scroll(output, keys, strc)
  end

  def infinite_scroll(table, keys, strc, limit, spec) do
    match_pattern =
      if is_nil(spec) do
        fields =
          ([table] ++ Enum.map(1..length(keys), fn _x -> :_ end))
          |> List.to_tuple()

        [{fields, [], er(:all)}]
      else
        spec
      end

    Transaction.activity(:async_dirty, fn -> Query.select(table, match_pattern, limit, :read) end)
    |> tuple_to_map(keys, strc, [])
    |> case do
      [] -> []
      data -> data
    end
  end

  def infinite_scroll({_record, cont}, keys, strc) do
    Transaction.activity(:async_dirty, fn -> Query.select(cont) end)
    |> tuple_to_map(keys, strc, [])
    |> case do
      [] -> []
      data -> data
    end
  end

  def infinite_scroll(table, keys, strc, limit, page, spec) when page >= 1 do
    match_pattern =
      if is_nil(spec) do
        fields =
          ([table] ++ Enum.map(1..length(keys), fn _x -> :_ end))
          |> List.to_tuple()

        [{fields, [], er(:all)}]
      else
        spec
      end

    Transaction.activity(:async_dirty, fn -> Query.select(table, match_pattern, limit, :read) end)
    |> tuple_to_map(keys, strc, [])
    |> case do
      [] -> []
      data when data != [] and page == 1 -> elem(data, 0)
      data -> go_next_page(page, data, keys, strc)
    end
  end

  defp go_next_page(page, {record, cont}, keys, strc) do
    Enum.reduce_while(1..(page - 1), {record, cont}, fn item, acc ->
      Transaction.activity(:async_dirty, fn -> Query.select(elem(acc, 1)) end)
      |> tuple_to_map(keys, strc, [])
      |> case do
        [] ->
          {:halt, []}

        {new_record, new_cont} ->
          if item + 1 == page, do: {:halt, new_record}, else: {:cont, {new_record, new_cont}}
      end
    end)
  end

  # mnesia:transaction(fun() -> mnesia:select(tab,
  # [{{tab,'$1','_','_','_','_','_','_','_','_','_','_','_','_','_'},
  # [{'andalso', {'>', '$1', 20}, {'<', '$1', 30}}], ['$_']}], 11, read)
  # end).
  def numerical(table, keys, strc, start: start, last: last, at: at) do
    fields =
      ([table] ++
         Enum.map(1..length(keys), fn x -> if(x === at, do: :"$1", else: :_) end))
      |> List.to_tuple()

    conds = [{eg(:and), {eg(:>=), :"$1", start}, {eg(:<=), :"$1", last}}]
    spec = [{fields, conds, er(:all)}]
    run_numerical_query(table, spec, keys, strc)
  end

  def numerical(table, keys, strc, page, limit, at) when page > 0 and limit > 0 do
    start = page * limit - limit

    fields =
      ([table] ++
         Enum.map(1..length(keys), fn x -> if(x === at, do: :"$1", else: :_) end))
      |> List.to_tuple()

    conds = [{eg(:and), {eg(:>), :"$1", start}, {eg(:<=), :"$1", page * limit}}]
    spec = [{fields, conds, er(:all)}]
    run_numerical_query(table, spec, keys, strc)
  end

  defp run_numerical_query(table, spec, keys, strc) do
    Transaction.transaction(fn -> Query.select(table, spec, :read) end)
    |> case do
      {:atomic, res} ->
        tuple_to_map(res, keys, strc, [])

      {:aborted, reason} ->
        Transaction.transaction_error(reason, __MODULE__, "listing", :global, :database)
    end
  end
end
