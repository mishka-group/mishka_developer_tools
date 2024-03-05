defmodule MnesiaAssistant.Transaction do
  @moduledoc """

  """
  alias :mnesia, as: Mnesia

  @doc """

  """
  def abort(reason), do: Mnesia.abort(reason)

  # ets | async_dirty | sync_dirty | transaction | sync_transaction
  # | {transaction, Retries :: integer() >= 0}
  # | {sync_transaction, Retries :: integer() >= 0}
  @doc """

  """
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

  @doc """

  """
  def async_dirty(dirty_fun), do: Mnesia.async_dirty(dirty_fun)

  def async_dirty(dirty_fun, args) when is_list(args), do: Mnesia.async_dirty(dirty_fun, args)

  @doc """

  """
  def ets(ets_fun), do: Mnesia.ets(ets_fun)

  def ets(ets_fun, args) when is_list(args), do: Mnesia.ets(ets_fun, args)

  @doc """

  """
  def sync_transaction(sync_fun) when is_function(sync_fun), do: Mnesia.sync_transaction(sync_fun)

  def sync_transaction(sync_fun, retries) when is_function(sync_fun) and is_integer(retries),
    do: Mnesia.sync_transaction(sync_fun, retries)

  def sync_transaction(sync_fun, args) when is_function(sync_fun) and is_list(args),
    do: Mnesia.sync_transaction(sync_fun, args)

  def sync_transaction(sync_fun, args, retries)
      when is_function(sync_fun) and is_list(args) and is_integer(retries),
      do: Mnesia.sync_transaction(sync_fun, args, retries)

  @doc """

  """
  def transaction(transaction_fn) when is_function(transaction_fn),
    do: Mnesia.transaction(transaction_fn)

  def transaction(transaction_fn, retries)
      when is_function(transaction_fn) and (is_integer(retries) or retries == :infinity),
      do: Mnesia.transaction(transaction_fn, retries)

  def transaction(transaction_fn, args) when is_function(transaction_fn) and is_list(args),
    do: Mnesia.transaction(transaction_fn, args)

  def transaction(transaction_fn, args, retries)
      when is_function(transaction_fn) and is_list(args) and
             (is_integer(retries) or retries == :infinity),
      do: Mnesia.transaction(transaction_fn, args, retries)
end
