defmodule MnesiaAssistant.Error do
  alias :mnesia, as: Mnesia
  require Logger
  # types link https://www.erlang.org/doc/man/mnesia#data-types

  @error_types [
    :nested_transaction,
    :badarg,
    :no_transaction,
    :combine_error,
    :bad_index,
    :already_exists,
    :index_exists,
    :no_exists,
    :system_limit,
    :mnesia_down,
    :not_a_db_node,
    :bad_type,
    :node_not_running,
    :truncated_binary_file,
    :active,
    :illegal
  ]

  @doc """
  ### Erlang document:

  All Mnesia transactions, including all the schema update functions, either return value `{atomic, Val}`
  or the tuple `{aborted, Reason}`. Reason can be either of the atoms in the following list.
  The function `error_description/1` returns a descriptive string that describes the error.


  - `nested_transaction`. Nested transactions are not allowed in this context.
  - `badarg`. Bad or invalid argument, possibly bad type.
  - `no_transaction`. Operation not allowed outside transactions.
  - `combine_error`. Table options illegally combined.
  - `bad_index`. Index already exists, or was out of bounds.
  - `already_exists`. Schema option to be activated is already on.
  - `index_exists`. Some operations cannot be performed on tables with an index.
  - `no_exists`. Tried to perform operation on non-existing (not-alive) item.
  - `system_limit`. A system limit was exhausted.
  - `mnesia_down`. A transaction involves records on a remote node, which became unavailable
  before the transaction was completed. Records are no longer available elsewhere in the network.
  - `not_a_db_node`. A node was mentioned that does not exist in the schema.
  - `bad_type`. Bad type specified in argument.
  - `node_not_running`. Node is not running.
  - `truncated_binary_file`. Truncated binary in file.
  - `active`. Some delete operations require that all active records are removed.
  - `illegal`. Operation not supported on this record.

  Error can be Reason, `{error, Reason}`, or `{aborted, Reason}`. Reason can be an atom or a
  tuple with Reason as an atom in the first field.

  The following examples illustrate a function that returns an error, and the method to
  retrieve more detailed error information:

  - The function `mnesia:create_table(bar, [{attributes, 3.14}])` returns the tuple `{aborted,Reason}`, where
  Reason is the tuple `{bad_type,bar,3.14000}`.

  The function `mnesia:error_description(Reason)` returns the term `{"Bad type on some provided arguments",bar,3.14000}`,
  which is an error description suitable for display.

  - `error_description(Error :: term())`

  ### Example:

  ```elixir
    MnesiaAssistant.Error.error_description(error)
  ```
  """
  def error_description(error), do: Mnesia.error_description(error)

  def error_description(error, identifier) when error in [{:atomic, :ok}, :ok] do
    Logger.info(
      "Identifier: #{inspect(identifier)}; The action concerned was completed successfully."
    )

    {:ok, :atomic}
  end

  def error_description(:starting, identifier) do
    Logger.info(
      "Identifier: #{inspect(identifier)}; The action concerned is being started successfully."
    )

    {:ok, :atomic}
  end

  def error_description({:aborted, {:already_exists, _module}} = error, identifier) do
    concerted = error_description(error)

    Logger.warning("""
    Identifier: #{inspect(identifier)}
    MnesiaError: #{inspect(error)}
    ConvertedError: #{inspect(concerted)}
    """)

    {:error, error, elem(concerted, 0) |> to_string}
  end

  def error_description({:error, {_, {:already_exists, _}}} = error, identifier) do
    concerted = error_description(error)

    Logger.warning("""
    Identifier: #{inspect(identifier)}
    MnesiaError: #{inspect(error)}
    ConvertedError: #{inspect(concerted)}
    """)

    {:error, error, elem(concerted, 0) |> to_string}
  end

  def error_description({:aborted, error_type} = error, identifier) when is_tuple(error_type) do
    if elem(error_type, 0) in @error_types do
      concerted = error_description(error)

      Logger.error("""
      Identifier: #{inspect(identifier)}
      MnesiaError: #{inspect(error)}
      ConvertedError: #{inspect(concerted)}
      """)

      {:error, error, elem(concerted, 0) |> to_string}
    else
      error_description(error, identifier)
    end
  end

  def error_description(error, identifier) do
    concerted = error_description(error)

    Logger.error("""
    Identifier: #{inspect(identifier)}
    MnesiaError: #{inspect(error)}
    ConvertedError: #{inspect(concerted)}
    """)

    {:error, error, concerted}
  end

  def try?({:error, {:timeout, _missing_tables}, _}, max, current) when current <= max, do: true

  def try?({:error, {:timeout, _missing_tables}, _}, max, current) when current > max, do: false

  def try?({:ok, :atomic}, _max, _current), do: false

  def try?(_error, _max, _current), do: false

  def try?({:error, {:timeout, _missing_tables}, _}), do: true

  def try?({:ok, :atomic}), do: false

  def try?(_error), do: false
end
