defmodule MnesiaAssistant.Transaction do
  alias :mnesia, as: Mnesia

  def abort(reason), do: Mnesia.abort(reason)

  # ets | async_dirty | sync_dirty | transaction | sync_transaction
  # | {transaction, Retries :: integer() >= 0}
  # | {sync_transaction, Retries :: integer() >= 0}
  def activity(kind, activity_fun)
      when kind in [:ets, :async_dirty, :sync_dirty, :transaction, :sync_transaction],
      do: Mnesia.activity(kind, activity_fun)

  def activity({type, retries} = kind, activity_fun)
      when type in [:transaction, :sync_transaction] and is_integer(retries),
      do: Mnesia.activity(kind, activity_fun)

  def activity(kind, activity_fun, args, module)
      when kind in [:ets, :async_dirty, :sync_dirty, :transaction, :sync_transaction] and
             is_list(args),
      do: Mnesia.activity(kind, activity_fun, args, module)

  def activity({type, retries} = kind, activity_fun, args, module)
      when type in [:transaction, :sync_transaction] and is_integer(retries) and is_list(args),
      do: Mnesia.activity(kind, activity_fun, args, module)

  def async_dirty(dirty_fun), do: Mnesia.async_dirty(dirty_fun)

  def async_dirty(dirty_fun, args) when is_list(args), do: Mnesia.async_dirty(dirty_fun, args)

  def ets(ets_fun), do: Mnesia.ets(ets_fun)

  def ets(ets_fun, args) when is_list(args), do: Mnesia.ets(ets_fun, args)

  def sync_transaction(sync_fun) when is_function(sync_fun), do: Mnesia.sync_transaction(sync_fun)

  def sync_transaction(sync_fun, retries) when is_function(sync_fun) and is_integer(retries),
    do: Mnesia.sync_transaction(sync_fun, retries)

  def sync_transaction(sync_fun, args) when is_function(sync_fun) and is_list(args),
    do: Mnesia.sync_transaction(sync_fun, args)

  def sync_transaction(sync_fun, args, retries)
      when is_function(sync_fun) and is_list(args) and is_integer(retries),
      do: Mnesia.sync_transaction(sync_fun, args, retries)

  def transaction(sync_fun) when is_function(sync_fun), do: Mnesia.transaction(sync_fun)

  def transaction(sync_fun, retries) when is_function(sync_fun) and is_integer(retries),
    do: Mnesia.transaction(sync_fun, retries)

  def transaction(sync_fun, args) when is_function(sync_fun) and is_list(args),
    do: Mnesia.transaction(sync_fun, args)

  def transaction(sync_fun, args, retries)
      when is_function(sync_fun) and is_list(args) and is_integer(retries),
      do: Mnesia.transaction(sync_fun, args, retries)
end
