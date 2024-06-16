defmodule QueueAssistant do
  @moduledoc """
  This is a simple wrapper for the Erlang queue, in which the order of some entries
  has also been changed

  - **Based on:** https://www.erlang.org/doc/man/queue
  """

  @type queue_type :: :queue.queue(any())

  @doc """
  Returns true if all elements in enumerable are truthy. It is like `Enum.all?/1`.

  ### Example:
  ```elixir
  new()
  |> insert(1)
  |> all?(fn x -> x >= 1 end)
  ```
  """
  @spec all?((any() -> boolean()), queue_type()) :: boolean()
  def all?(fun, queue) do
    :queue.all(fun, queue)
  end

  @doc """
  Returns true if at least one element in enumerable is truthy.

  ### Example:
  ```elixir
  new()
  |> insert(1)
  |> insert(2)
  |> any?(fn x -> x >= 2 end)
  ```
  """
  @spec any?(queue_type(), (any() -> boolean())) :: boolean()
  def any?(queue, fun) do
    :queue.any(fun, queue)
  end

  @doc """
  Returns a copy of `q1` where the first item matching `item` is deleted, if there is such an item.

  ### Example:
  ```elixir
  queue = from_list([1, 2, 3, 4, 5])
  queue1 = queue |> delete(3)
  member(queue1, 3)
  # false
  ```
  """
  @spec delete(queue_type(), any()) :: queue_type()
  def delete(queue, item) do
    :queue.delete(item, queue)
  end

  @doc """
  Returns a copy of `q1` where the last item matching `item` is deleted, if there is such an item.

  ### Example:
  ```elixir
  queue = from_list([1, 2, 3, 4, 3, 5])
  queue1 = delete_r(queue, 3)
  to_list(queue1).
  [1,2,3,4,5]
  ```
  """
  @spec delete_r(queue_type(), any()) :: queue_type()
  def delete_r(queue, item) do
    :queue.delete_r(item, queue)
  end

  @doc """
  Returns a copy of `q1` where the first item for which `fn` returns true is deleted,
  if there is such an item.

  ### Example:
  ```elixir
  queue = from_list([100,1, 2, 3, 4, 5])
  queue1 = delete_with(queue, fn x -> x > 0)
  to_list(queue1)
  [1,2,3,4,5]
  ```

  If we make it abstract in Elixir, you can do it with a list like this:

  ```elixir
  list = [1, 2, 3, 4, 5]
  {before, [h | t]} = Enum.split_with(list, fn x -> x < 4 end)
  new_list = before ++ t
  ```
  """
  @spec delete_with(queue_type(), (any() -> boolean())) :: queue_type()
  def delete_with(queue, fun) do
    :queue.delete_with(fun, queue)
  end

  @doc """
  Returns a copy of `q1` where the last item for which `fn` returns true is deleted,
  if there is such an item.

  ### Example:
  ```elixir
  queue = from_list([100,1, 4, 2, 3, 4, 5])
  queue1 = delete_with_r(queue, fn x -> x == 4)
  to_list(queue1)
  [100,1, 4, 2, 3, 5]
  ```
  """
  @spec delete_with_r(queue_type(), (any() -> boolean())) :: queue_type()
  def delete_with_r(queue, fun) do
    :queue.delete_with_r(fun, queue)
  end

  @doc """
  Filters the enumerable, i.e. returns only those elements for which fun returns a truthy value.
  It is like `Enum.filter/2`.

  ### Example:
  ```elixir
  queue = from_list([1, 2, 3, 4, 5])
  queue1 = filter(queue, fn x -> x > 2 end)
  to_list(queue1)
  # [3, 4, 5]
  ```

  ### From Erlang docs:

  > So, `Fun(Item)` returning `[Item]` is thereby semantically equivalent to returning true,
  > just as returning `[]` is semantically equivalent to returning false.
  >
  > But returning a list builds more garbage than returning an atom.

  ### Example:
  ```elixir
  queue = from_list([1, 2, 3, 4, 5])
  # {[5, 4, 3], [1, 2]}

  queue1 = filter(queue, fn x -> [x, x+1] end)
  # {[6, 5, 5, 4, 4, 3], [1, 2, 2, 3]}

  to_list(queue1)
  # [1, 2, 2, 3, 3, 4, 4, 5, 5, 6]
  ```
  """
  @spec filter(queue_type(), (any() -> boolean() | list())) :: queue_type()
  def filter(queue, fun) do
    :queue.filter(fun, queue)
  end

  @doc """
  ### From Erlang doc:

  Returns a queue `q2` that is the result of calling `Fun(Item)` on all items in `q1`.

  If `Fun(Item)` returns true, Item is copied to the result queue. If it returns **false**,
  Item is not copied.

  If it returns `{true, NewItem}`, the queue element at this position is replaced with `NewItem`
  in the result queue.

  ### Example:
  ```elixir
  queue = from_list([1, 2, 3, 4, 5])
  queue1 = filtermap(queue, fn x -> x > 2 end)
  to_list(queue1)
  # [3, 4, 5]
  ```
  """
  @spec filtermap(queue_type(), (any() -> boolean() | {true, any()})) ::
          queue_type()
  def filtermap(queue, fun) do
    :queue.filtermap(fun, queue)
  end

  @doc """
  Invokes fun for each element in the enumerable with the accumulator. It is like `Enum.reduce/3`.

  ### From Erlang docs:

  Calls Fun(Item, AccIn) on successive items Item of Queue, starting with `AccIn == Acc`0.
  The queue is traversed in queue order, that is, from front to rear.

  `Fun/2` must return a new accumulator, which is passed to the next call.
  The function returns the final value of the accumulator. `Acc0` is returned if the queue is empty.

  ### Example:
  ```elixir
  queue = from_list([1, 2, 3, 4, 5])

  1> fold(queue, 0, fn item, acc -> item + acc end)
  # 15

  2> fold(queue, 0, fn item, acc -> item * acc end)
  # 120
  ```
  """
  @spec fold(queue_type(), any(), (any(), any() -> any())) :: any()
  def fold(queue, acc, fun) do
    :queue.fold(fun, acc, queue)
  end

  @doc """
  For see more information, check `fold/3`
  """
  @spec reduce(queue_type(), any(), (any(), any() -> any())) :: any()
  def reduce(queue, acc, fun), do: fold(queue, acc, fun)

  @doc """
  Returns a queue containing the items in the same order; the head item of
  the list becomes the front item of the queue.

  ### Example:
  ```elixir
  from_list([1, 2, 3, 4, 5])
  # {[5, 4, 3], [1, 2]}
  ```
  """
  @spec from_list(list()) :: queue_type()
  def from_list(items) do
    :queue.from_list(items)
  end

  @doc """
  Inserts Item at the rear of queue `q1`. Returns the resulting queue `q2`.

  ### Example:
  ```elixir
  queue = from_list([1, 2, 3, 4, 5])
  queue1 = insert(queue, 100)
  to_list(queue1)
  # [1, 2, 3, 4, 5, 100]
  ```
  """
  @spec insert(queue_type(), any()) :: queue_type()
  def insert(queue, item) do
    :queue.in(item, queue)
  end

  @doc """
  Inserts Item at the front of queue `q1`. Returns the resulting queue `q2`.

  ### Example:
  ```elixir
  queue = from_list([1, 2, 3, 4, 5])
  queue1 = insert_r(queue, 100)
  to_list(queue1)
  # [100, 1, 2, 3, 4, 5]
  ```
  """
  @spec insert_r(queue_type(), any()) :: queue_type()
  def insert_r(queue, item) do
    :queue.in_r(item, queue)
  end

  @doc """
  For see more information, check `insert_r/2`
  """
  @spec in_r(queue_type(), any()) :: queue_type()
  def in_r(queue, item), do: insert_r(queue, item)

  @doc """
  Tests if a queue is empty and returns true if so, otherwise false.

  ### Example:
  ```elixir
  queue = from_list([1, 2, 3, 4, 5])
  is_empty?(queue)
  # false
  ```
  """
  @spec is_empty?(queue_type() | nil) :: boolean()
  def is_empty?(nil), do: true

  def is_empty?(queue) do
    :queue.is_empty(queue)
  end

  @spec empty?(queue_type()) :: boolean()
  @doc """
  For see more information, check `is_empty?/1`
  """
  @spec empty?(queue_type() | nil) :: boolean()
  def empty?(queue), do: is_empty?(queue)

  @doc """
  Tests if an entry is queue and returns true if so, otherwise false.

  ### Example:
  ```elixir
  queue = from_list([1, 2, 3, 4, 5])
  is_queue?(queue)
  # true
  ```
  """
  @spec is_queue?(queue_type()) :: boolean()
  def is_queue?(queue) do
    :queue.is_queue(queue)
  end

  @doc """
  For see more information, check `is_queue?/1`
  """
  @spec queue?(queue_type()) :: boolean()
  def queue?(queue), do: is_queue?(queue)

  @doc """
  Returns a queue `q3` that is the result of joining `q1` and `q2` with `q1` in front of `q2`.

  ### Example:
  ```elixir
  queue = from_list([1, 2])
  queue1 = from_list([3, 4])
  join(queue, queue1)
  # [1, 2, 3, 4]
  ```
  """
  @spec join(queue_type(), queue_type()) :: queue_type()
  def join(queue, queue1) do
    :queue.join(queue, queue1)
  end

  @doc """
  Calculates and returns the length of a queue.

  ### Example:
  ```elixir
  queue = from_list([1, 2])
  len(queue)
  # 2
  ```
  """
  @spec len(queue_type()) :: non_neg_integer()
  def len(queue) do
    :queue.len(queue)
  end

  @doc """
  For see more information, check `len/1`
  """
  @spec count(queue_type()) :: non_neg_integer()
  def count(queue), do: len(queue)

  @doc """
  Checks if element exists within the queue.

  ### Example:
  ```elixir
  queue = from_list([1, 2])
  member?(queue, 2)
  # true
  ```
  """
  @spec member?(queue_type(), any()) :: boolean()
  def member?(queue, item) do
    :queue.member(item, queue)
  end

  @doc """
  Returns an empty queue.
  ### Example:
  ```elixir
  new()
  # {[], []}
  ```
  """
  @spec new() :: queue_type()
  def new() do
    :queue.new()
  end

  @doc """
  Removes the item at the front of queue `q1`. Returns tuple `{{:value, item}, q2}`,
  where Item is the item removed and `q2` is the resulting queue.
  If `q1` is empty, tuple `{empty, q1}` is returned.

  ### Example:
  ```elixir
  queue = from_list([1, 2, 3, 4, 5])
  # {[5, 4, 3],[1, 2]}

  {{:value, 1}, new_queue} = out(queue)
  # {{:value, 1}, {[5, 4, 3], [2]}}

  to_list(new_queue)
  # [2, 3, 4, 5]
  ```
  """
  @dialyzer {:nowarn_function, out: 1}
  @spec out(queue_type()) :: {:empty, {[], []}} | {{:value, any()}, queue_type()}
  def out(queue) do
    :queue.out(queue)
  end

  @doc """
  Removes the item at the rear of queue `q1`. Returns tuple `{{:value, item}, q2}`,
  where Item is the item removed and `q2` is the resulting queue.
  If `q1` is empty, tuple `{empty, q1}` is returned.

  ### Example:
  ```elixir
  queue = from_list([1, 2, 3, 4, 5])
  # {[5,4,3], [1, 2]}

  {{:value, 5}, new_queue} = out_r(queue)
  # {{:value, 5}, {[5, 4, 3], [2, 1]}}

  to_list(new_queue)
  # [1, 2, 3, 4]
  ```
  """
  @spec out_r(queue_type()) :: {:empty | {:value, any()}, queue_type()}
  def out_r(queue) do
    :queue.out_r(queue)
  end

  @doc """
  Returns a queue `q2` containing the items of `q1` in the reverse order.

  ### Example:
  ```elixir
  queue = from_list([1, 2, 3, 4, 5])
  reverse(queue)
  # {[1, 2], [5, 4, 3]}
  ```
  """
  @spec reverse(queue_type()) :: queue_type()
  def reverse(queue) do
    :queue.reverse(queue)
  end

  @doc """
  Splits `q1` in two. The `n` front items are put in `q2` and the rest in `q3`.

  ### Example:
  ```elixir
  queue = from_list([1, 2, 3, 4, 5])
  split(queue, 2)
  # {{[2], [1]}, {[5], [3, 4]}}
  ```
  """
  @spec split(queue_type(), non_neg_integer()) ::
          {queue_type(), queue_type()}
  def split(queue, at) do
    :queue.split(at, queue)
  end

  @doc """
  Returns a list of the items in the queue in the same order; the front item of
  the queue becomes the head of the list.

  ### Example:
  ```elixir
  queue = from_list([1, 2, 3, 4, 5])
  # {[5, 4, 3], [1, 2]}

  to_list(queue)
  # [1, 2, 3, 4, 5]
  ```
  """
  @spec to_list(queue_type()) :: list()
  def to_list(queue) do
    :queue.to_list(queue)
  end

  # Extended APIs

  @doc """
  Returns a queue `q2` that is the result of removing the front item from `q1`.

  ### Example:
  ```elixir
  queue = from_list([1, 2, 3, 4, 5])
  queue1 = drop(queue)
  to_list(queue1)
  # [2,3,4,5]
  ```

  > **Fails with reason empty if `q1` is empty.** You must check if it is empty before dropping it.

  ### Error output:

  ```
  ** (ErlangError) Erlang error: :empty
      (stdlib 5.2.1) queue.erl:252: :queue.drop({[], []})
      iex:55: (file)
  ```
  """
  @spec drop(queue_type()) :: queue_type()
  def drop(queue) do
    :queue.drop(queue)
  end

  @doc """
  Returns a queue `q2` that is the result of removing the rear item from `q1`.

  ### Example:
  ```elixir
  queue = from_list([1, 2, 3, 4, 5])
  queue1 = drop_r(queue)
  to_list(queue1)
  # [1, 2, 3, 4]
  ```

  > **Fails with reason empty if `q1` is empty.** You must check if it is empty before dropping it.

  ### Error output:

  ```
  ** (ErlangError) Erlang error: :empty
      (stdlib 5.2.1) queue.erl:270: :queue.drop_r({[], []})
      iex:58: (file)
  ```
  """
  @spec drop_r(queue_type()) :: queue_type()
  def drop_r(queue) do
    :queue.drop_r(queue)
  end

  @doc """
  Returns Item at the front of a queue.

  ### Example:
  ```elixir
  queue = from_list([1, 2, 3, 4, 5])
  1 == get(queue)
  ```

  > **Fails with reason empty if `queue` is empty.** You must check if it is empty before getting it.

  ### Error output:

  ```
  ** (ErlangError) Erlang error: :empty
      (stdlib 5.2.1) queue.erl:188: :queue.get({[], []})
      iex:58: (file)
  ```
  """
  @spec get(queue_type()) :: any()
  def get(queue) do
    :queue.get(queue)
  end

  @doc """
  Returns Item at the rear of a queue.

  ### Example:
  ```elixir
  queue = from_list([1, 2, 3, 4, 5])
  5 == get_r(queue)
  ```

  > **Fails with reason empty if `queue` is empty.** You must check if it is empty before getting it.

  ### Error output:

  ```
  ** (ErlangError) Erlang error: :empty
      (stdlib 5.2.1) queue.erl:207: :queue.get_r({[], []})
      iex:58: (file)
  ```
  """
  @spec get_r(queue_type()) :: any()
  def get_r(queue) do
    :queue.get_r(queue)
  end

  @doc """
  Returns tuple `{:value, item}`, where Item is the front item of a queue,
  or empty if a queue is `:empty`.

  ### Example:
  ```elixir
  peek(new())
  # :empty

  queue = from_list([1, 2 ,3 ,4 ,5])
  # {[5, 4, 3], [1, 2]}

  peek(queue)
  # {:value, 1}
  ```
  """
  @spec peek(queue_type()) :: :empty | {:value, any()}
  def peek(queue) do
    :queue.peek(queue)
  end

  @doc """
  Returns tuple `{:value, item}`, where Item is the rear item of a queue,
  or empty if a queue is `:empty`.

  ### Example:
  ```elixir
  peek_r(new())
  # :empty

  queue = from_list([1, 2 ,3 ,4 ,5])
  # {[5, 4, 3], [1, 2]}

  peek_r(queue)
  # {:value, 5}
  ```
  """
  @spec peek_r(queue_type()) :: :empty | {:value, any()}
  def peek_r(queue) do
    :queue.peek_r(queue)
  end

  @doc """
  Please see `join/2` and `to_list/1`.
  """
  @spec join_to_list(queue_type(), queue_type()) :: list(any())
  def join_to_list(queue, queue1) do
    :queue.join(queue, queue1)
    |> :queue.to_list()
  end

  @doc """
  Please see `join/2` and `to_list/1`.
  """
  @spec join_to_list(list(any()), list(any())) :: queue_type()
  def list_to_join(queue, queue1) do
    :queue.join(:queue.from_list(queue), :queue.from_list(queue1))
  end

  # The "Okasaki API" is inspired by "Purely Functional Data Structures" by Chris Okasaki.
  # It regards queues as lists. This API is by many regarded as strange and avoidable.
  # For example, many reverse operations have lexically reversed names, some with more
  # readable but perhaps less understandable aliases.
  #
  # Do not use these functions

  @doc """
  Inserts Item at the head of queue `q1`. Returns the new queue `q2`.

  ### Example:
  ```elixir
  queue = cons(from_list([1, 2, 3]), 0)
  to_list queue
  # [0, 1, 2, 3]
  ```
  """
  @spec cons(queue_type(), any()) :: queue_type()
  def cons(queue, item) do
    :queue.cons(item, queue)
  end

  @doc """
  Returns the tail item of a queue.

  ### Example:
  ```elixir
  queue = daeh(from_list([1, 2, 3]))
  # 3
  ```

  > **Fails with reason empty if `queue` is empty.** You must check if it is empty before tailing it.

  ### Error output:

  ```
  ** (ErlangError) Erlang error: :empty
      (stdlib 5.2.1) queue.erl:207: :queue.get_r({[], []})
      iex:67: (file)
  ```
  """
  @spec daeh(queue_type()) :: any()
  def daeh(queue) do
    :queue.daeh(queue)
  end

  @doc """
  Returns the head item of a queue.

  ### Example:
  ```elixir
  queue = head(from_list([1, 2, 3]))
  # 1
  ```

  > **Fails with reason empty if `queue` is empty.** You must check if it is empty before heading it.

  ### Error output:

  ```
  ** (ErlangError) Erlang error: :empty
      (stdlib 5.2.1) queue.erl:662: :queue.head({[], []})
      iex:67: (file)
  ```
  """
  @spec head(queue_type()) :: any()
  def head(queue) do
    :queue.head(queue)
  end

  @doc """
  Please see `head/1`.
  """
  @spec first(queue_type()) :: any()
  def first(queue) do
    :queue.head(queue)
  end

  @doc """
  Returns a queue `q2` that is the result of removing the tail item from `q1`.

  ### Example:
  ```elixir
  init(from_list([1, 2, 3]))
  # {[2],[1]}
  ```

  > **Fails with reason empty if `queue` is empty.** You must check if it is empty before initing it.

  ### Error output:

  ```
  ** (ErlangError) Erlang error: :empty
      (stdlib 5.2.1) queue.erl:270: :queue.drop_r({[], []})
      iex:67: (file)
  ```
  """
  @spec init(queue_type()) :: queue_type()
  def init(queue) do
    :queue.init(queue)
  end

  @doc """
  Returns the tail item of a queue.

  ### Example:
  ```elixir
  last(from_list([1,2 , 3]))
  # 3
  ```

  > **Fails with reason empty if `queue` is empty.** You must check if it is empty before getting it.

  ### Error output:

  ```
  ** (ErlangError) Erlang error: :empty
      (stdlib 5.2.1) queue.erl:207: :queue.get_r({[], []})
      iex:67: (file)
  ```
  """
  @spec last(queue_type()) :: any()
  def last(queue) do
    :queue.last(queue)
  end

  @spec liat(queue_type()) :: queue_type()
  @doc """
  It is like `init/1`.
  """
  @spec liat(queue_type()) :: queue_type()
  def liat(queue) do
    :queue.liat(queue)
  end

  @doc """
  Inserts Item as the tail item of a queue `q1`. Returns a new queue like `q2`.

  ### Example:
  ```elixir
  queue = snoc(from_list([1, 2, 3]), 4)
  # {[4, 3, 2], [1]}

  to_list(queue)
  # [1,2,3,4]
  ```
  """
  @spec snoc(queue_type(), any()) :: queue_type()
  def snoc(queue, item) do
    :queue.snoc(queue, item)
  end

  @doc """
    Returns a queue `q2` that is the result of removing the head item from `q1`.

    > **Fails with reason empty if `queue` is empty.** You must check if it is empty before tailing it.

    ### Error output:

    ```
    ** (ErlangError) Erlang error: :empty
        (stdlib 5.2.1) queue.erl:252: :queue.drop({[], []})
        iex:67: (file)
    ```
  """
  @spec tail(queue_type()) :: queue_type()
  def tail(queue) do
    :queue.tail(queue)
  end
end
