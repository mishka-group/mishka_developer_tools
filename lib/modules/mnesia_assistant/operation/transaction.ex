defmodule MnesiaAssistant.Transaction do
  @moduledoc """
  In this module, there are functions that are related to Transactions or that are opposite to commands.
  """
  alias :mnesia, as: Mnesia

  @doc """
  Termination of a `Mnesia` transaction means that an exception is thrown to an enclosing catch.
  Makes the transaction silently return the tuple `{:aborted, reason}`.
  Thus, the expression catch `mnesia:abort(x)` (Erlang) does not terminate the transaction.

  ### Example:

  ```elixir
    MnesiaAssistant.Transaction.abort(reason)
  ```
  """
  def abort(reason), do: Mnesia.abort(reason)

  # ets | async_dirty | sync_dirty | transaction | sync_transaction
  # | {transaction, Retries :: integer() >= 0}
  # | {sync_transaction, Retries :: integer() >= 0}
  @doc """
  ### Erlang document:

  The code that executes inside the activity can consist of a series of table manipulation functions,
  which are performed in an `AccessContext`. Currently, the following access contexts are supported:

  - `transaction` Short for {transaction, infinity}

  - `{transaction, Retries}` Calls `mnesia:transaction(Fun, Args, Retries)`. Notice that the result from
  Fun is returned if the transaction is successful (atomic), otherwise the function exits with an abort reason.

  - `sync_transaction` Short for {sync_transaction, infinity}

  - `{sync_transaction, Retries}` Calls mnesia:sync_transaction(Fun, Args, Retries).
  Notice that the result from Fun is returned if the transaction is successful (atomic),
  otherwise the function exits with an abort reason.

  - `async_dirty` Calls `mnesia:async_dirty(Fun, Args)`.

  - `sync_dirty` `Calls mnesia:sync_dirty(Fun, Args)`.

  - `ets` Calls `mnesia:ets(Fun, Args)`.

  This function (`mnesia:activity/4`) differs in an important way from the functions mnesia:transaction,
  `mnesia:sync_transaction`, `mnesia:async_dirty`, mnesia:sync_dirty, and `mnesia:ets`. Argument `AccessMod` is the
  name of a callback module, which implements the mnesia_access behavior.
  Mnesia forwards calls to the following functions:

  - `mnesia:lock/2` (`read_lock_table/1`, `write_lock_table/1`)
  - `mnesia:write/3` (`write/1`, `s_write/1`)
  - `mnesia:delete/3` (`delete/1`, `s_delete/1`)
  - `mnesia:delete_object/3` (`delete_object/1`, `s_delete_object/1`)
  - `mnesia:read/3` (`read/1`, `wread/1`)
  - `mnesia:match_object/3` (`match_object/1`)
  - `mnesia:all_keys/1`
  - `mnesia:first/1`
  - `mnesia:last/1`
  - `mnesia:prev/2`
  - `mnesia:next/2`
  - `mnesia:index_match_object/4` (`index_match_object/2`)
  - `mnesia:index_read/3`
  - `mnesia:table_info/2`

  to the corresponding:

  - `AccessMod:lock(ActivityId, Opaque, LockItem, LockKind)`
  - `AccessMod:write(ActivityId, Opaque, Tab, Rec, LockKind)`
  - `AccessMod:delete(ActivityId, Opaque, Tab, Key, LockKind)`
  - `AccessMod:delete_object(ActivityId, Opaque, Tab, RecXS, LockKind)`
  - `AccessMod:read(ActivityId, Opaque, Tab, Key, LockKind)`
  - `AccessMod:match_object(ActivityId, Opaque, Tab, Pattern, LockKind)`
  - `AccessMod:all_keys(ActivityId, Opaque, Tab, LockKind)`
  - `AccessMod:first(ActivityId, Opaque, Tab)`
  - `AccessMod:last(ActivityId, Opaque, Tab)`
  - `AccessMod:prev(ActivityId, Opaque, Tab, Key)`
  - `AccessMod:next(ActivityId, Opaque, Tab, Key)`
  - `AccessMod:index_match_object(ActivityId, Opaque, Tab, Pattern, Attr, LockKind)`
  - `AccessMod:index_read(ActivityId, Opaque, Tab, SecondaryKey, Attr, LockKind)`
  - `AccessMod:table_info(ActivityId, Opaque, Tab, InfoItem)`

  ActivityId is a record that represents the identity of the enclosing Mnesia activity. The first field (obtained with element(1, ActivityId)) contains an atom, which can be interpreted as the activity type: ets, `async_dirty`, `sync_dirty`, or tid. tid means that the activity is a transaction. The structure of the rest of the identity record is internal to Mnesia.

  **`Opaque` is an opaque data structure that is internal to Mnesia.**

  > Calls `mnesia:activity(AccessContext, Fun, Args, AccessMod)`, where AccessMod is the default
  > access callback module obtained by `mnesia:system_info(access_module)`. Args defaults to `[]` (empty list).

  ### Example:

  ```elixir
    MnesiaAssistant.Transaction.activity(
      :transaction,
      fn -> MnesiaAssistant.Query.read(:table, id) end
    )
  ```

  > The following is a summary of the description: activity can be helpful anytime you need to utilise additional
  > alternatives and also change certain extreme functions; nevertheless, if your job is straightforward, extremely
  > obvious, and has a direct function, it is preferable to use its own function.
  """
  def activity(kind, activity_fun)
      when kind in [:ets, :async_dirty, :sync_dirty, :transaction, :sync_transaction],
      do: Mnesia.activity(kind, activity_fun)

  def activity({type, retries} = kind, activity_fun)
      when type in [:transaction, :sync_transaction] and is_integer(retries),
      do: Mnesia.activity(kind, activity_fun)

  @doc """
  Read `activity/2` document.
  """
  def activity(kind, activity_fun, args, module)
      when kind in [:ets, :async_dirty, :sync_dirty, :transaction, :sync_transaction] and
             is_list(args),
      do: Mnesia.activity(kind, activity_fun, args, module)

  def activity({type, retries} = kind, activity_fun, args, module)
      when type in [:transaction, :sync_transaction] and is_integer(retries) and is_list(args),
      do: Mnesia.activity(kind, activity_fun, args, module)

  @doc """
  ### Erlang document:

  Calls the Fun in a context that is not protected by a transaction. The Mnesia function calls performed in the Fun are mapped to the corresponding dirty functions. **This still involves logging, replication, and subscriptions, but there is no locking, local transaction storage, or commit protocols involved**.

  Checkpoint retainers and indexes are updated, but they are updated dirty. As for normal `mnesia:dirty_*` operations, the operations are performed semi-asynchronously. For details, see `mnesia:activity/4` and the User's Guide.

  The Mnesia tables can be manipulated without using transactions. This has some serious disadvantages, but is considerably faster, as the transaction manager is not involved and no locks are set. A dirty operation does, however, guarantee a certain level of consistency, and the dirty operations cannot return garbled records. All dirty operations provide location transparency to the programmer, and a program does not have to be aware of the whereabouts of a certain table to function.

  Notice that it is more than ten times more efficient to read records dirty than within a transaction.

  Depending on the application, it can be a good idea to use the dirty functions for certain operations. Almost all Mnesia functions that can be called within transactions have a dirty equivalent, which is much more efficient.

  However, notice that there is a risk that the database can be left in an inconsistent state if dirty operations are used to update it. Dirty operations are only to be used for performance reasons when it is absolutely necessary.

  > Notice that calling (nesting) `mnesia:[a]sync_dirty` inside a transaction-context inherits the transaction semantics.

  ### Extera:

  :mnesia.async_dirty/2 and :mnesia.async_dirty/1 are two functions in Mnesia that are utilised to perform operations on the database without locking the database and without waiting for the operation to be finished across all replicas.
  To put it another way, these methods carry out the specified operation in an asynchronous and "dirty" fashion.
  This means that they do not ensure `ACID` qualities, which stands for **atomicity**, **consistency**, **isolation**, and **durability**. As a result, they are more efficient than transactions, but they may also be less secure. `async_dirty` operations are helpful for use cases in which speed is of the utmost importance and the operation does not require strong consistency guarantees.

  ### Example:

  ```elixir
    fun = fn -> MnesiaAssistant.Query.write({Person, id, name, age}) end
    MnesiaAssistant.Transaction.async_dirty(fun)
  ```
  """
  def async_dirty(dirty_fun), do: Mnesia.async_dirty(dirty_fun)

  @doc """
  Read `async_dirty/1` document.
  """
  def async_dirty(dirty_fun, args) when is_list(args), do: Mnesia.async_dirty(dirty_fun, args)

  @doc """
  ### Erlang document:

  Calls the Fun in a raw context that is not protected by a transaction. The Mnesia function call is performed in the Fun and performed directly on the local `ETS` tables on the assumption that the local storage type is **`ram_copies`** and the tables are not replicated to other nodes.
  Subscriptions are not triggered and checkpoints are not updated, but it is extremely fast.
  This function can also be applied to **`disc_copies`** tables if all operations are read only. For details, see `mnesia:activity/4` and the User's Guide.

  Notice that calling (nesting) a `mnesia:ets` inside a **transaction-context** inherits the transaction semantics.

  ### Example:

  ```elixir
    MnesiaAssistant.Transaction.ets(fn ->
      MnesiaAssistant.Table.all_keys(module)
    end)
  ```

  > Remember that `ets/1` and `ets/2` allow for `ETS-lik`e operations but still within the constraints
  > and behavior of Mnesia. They can offer performance benefits for certain types of operations
  > but use them judiciously and with understanding of their limitations.
  """
  def ets(ets_fun), do: Mnesia.ets(ets_fun)

  @doc """
  Read `ets/1` document.
  """
  def ets(ets_fun, args) when is_list(args), do: Mnesia.ets(ets_fun, args)

  @doc """
  Not only does it guarantee that the transaction is committed locally, but it also guarantees that
  the modifications are properly replicated to all of the other nodes before the function returns.
  When using this synchronous replication strategy, it waits for confirmation from all of the nodes,
  which guarantees that all replicas are consistent as soon as the transaction is finished.

  ### Erlang docuemnt:

  Waits until data have been committed and logged to disk (if disk is used) on every involved node before it returns, otherwise it behaves as `mnesia:transaction/[1,2,3]`.

  This functionality can be used to avoid that one process overloads a database on another node.


  - `sync_transaction(Fun)`
  - `sync_transaction(Fun, Retries)`
  - `sync_transaction(Fun, Args :: [Arg :: term()])`
  - `sync_transaction(Fun, Args :: [Arg :: term()], Retries)`

  ### Example:

  ```elixir
    alias MnesiaAssistant.Query

    fun = fn ->
      Query.write({Person, Query.dirty_last(Person) + 1, "Mishka, 20})
    end

    MnesiaAssistant.Transaction.sync_transaction(fun)
  ```
  """
  def sync_transaction(sync_fun) when is_function(sync_fun), do: Mnesia.sync_transaction(sync_fun)

  @doc """
  Read `sync_transaction/1` document.
  """
  def sync_transaction(sync_fun, retries) when is_function(sync_fun) and is_integer(retries),
    do: Mnesia.sync_transaction(sync_fun, retries)

  def sync_transaction(sync_fun, args) when is_function(sync_fun) and is_list(args),
    do: Mnesia.sync_transaction(sync_fun, args)

  @doc """
  Read `sync_transaction/1` document.
  """
  def sync_transaction(sync_fun, args, retries)
      when is_function(sync_fun) and is_list(args) and is_integer(retries),
      do: Mnesia.sync_transaction(sync_fun, args, retries)

  @doc """
  In contrast to the `sync_transaction/1` function, it guarantees that the transaction is not only committed locally,
  but that the modifications are also successfully replicated to all of the other nodes before the function returns.
  When using this synchronous replication strategy, it waits for confirmation from all of the nodes, which guarantees that all replicas are consistent as soon as the transaction is finished.

  ### Erlang document

  Executes the functional object Fun with arguments `Args` as a transaction.

  The code that executes inside the transaction can consist of a series of table manipulation functions.
  If something goes wrong inside the transaction as a result of a user error or a certain
  table not being available, the entire transaction is terminated and the function `transaction/1` returns the tuple `{aborted, Reason}`.

  If all is going well, {atomic, ResultOfFun} is returned, where ResultOfFun is the value
  of the last expression in Fun.

  A function that adds a family to the database can be written as follows if there is a structure `{family, Father, Mother, ChildrenList}`:

  ```erlang
  add_family({family, F, M, Children}) ->
      ChildOids = lists:map(fun oid/1, Children),
      Trans = fun() ->
          mnesia:write(F#person{children = ChildOids}),
          mnesia:write(M#person{children = ChildOids}),
          Write = fun(Child) -> mnesia:write(Child) end,
          lists:foreach(Write, Children)
      end,
      mnesia:transaction(Trans).

  oid(Rec) -> {element(1, Rec), element(2, Rec)}.
  ```
  This code adds a set of people to the database. Running this code within one transaction ensures
  that either the whole family is added to the database, or the whole transaction terminates.
  For example, if the last child is badly formatted, or the executing process terminates
  because of an `'EXIT'` signal while executing the family code, the transaction terminates.
  Thus, the situation where half a family is added can never occur.

  It is also useful to update the database within a transaction if several processes concurrently
  update the same records. For example, the function raise(Name, Amount), which adds Amount
  to the salary field of a person, is to be implemented as follows:

  ```erlang
  raise(Name, Amount) ->
      mnesia:transaction(fun() ->
          case mnesia:wread({person, Name}) of
              [P] ->
                  Salary = Amount + P#person.salary,
                  P2 = P#person{salary = Salary},
                  mnesia:write(P2);
              _ ->
                  mnesia:abort("No such person")
          end
      end).
  ```

  When this function executes within a transaction, several processes running on different nodes
  can concurrently execute the function `raise/2` without interfering with each other.


  Since Mnesia detects deadlocks, a transaction can be restarted any number of times and
  therefore the `Fun` shall not have any side effects such as waiting for specific messages.
  This function attempts a restart as many times as specified in Retries.
  Retries must be an integer greater than `0` or the atom infinity, default is infinity.
  Mnesia uses exit exceptions to signal that a transaction needs to be restarted, thus a Fun must not catch exit exceptions with reason `{aborted, term()}`.

  - `transaction(Fun)`
  - `transaction(Fun, Retries)`
  - `transaction(Fun, Args :: [Arg :: term()])`
  - `transaction(Fun, Args :: [Arg :: term()], Retries)`


  ### Example:

  ```elixir
    trans = fn ->
      MnesiaAssistant.Query.write({Person, 10, "mishka"})
      MnesiaAssistant.Query.write({Person, 11, "life"})
    end

    MnesiaAssistant.Transaction.transaction(trans)
  ```
  """
  def transaction(transaction_fn) when is_function(transaction_fn),
    do: Mnesia.transaction(transaction_fn)

  @doc """
  Read `transaction/1` document.
  """
  def transaction(transaction_fn, retries)
      when is_function(transaction_fn) and (is_integer(retries) or retries == :infinity),
      do: Mnesia.transaction(transaction_fn, retries)

  def transaction(transaction_fn, args) when is_function(transaction_fn) and is_list(args),
    do: Mnesia.transaction(transaction_fn, args)

  @doc """
  Read `transaction/1` document.
  """
  def transaction(transaction_fn, args, retries)
      when is_function(transaction_fn) and is_list(args) and
             (is_integer(retries) or retries == :infinity),
      do: Mnesia.transaction(transaction_fn, args, retries)

  def transaction_error(reason, module, type, field, action) do
    {:error, error, msg} = MnesiaAssistant.Error.error_description({:aborted, reason}, module)

    message =
      "Unfortunately, there is a problem in #{type} data in the database. #{inspect(msg)}"

    {:error, [%{message: message, field: field, action: action, source: error}]}
  end
end
