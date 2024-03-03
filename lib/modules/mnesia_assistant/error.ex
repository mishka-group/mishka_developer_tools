defmodule MnesiaAssistant.Error do
  alias :mnesia, as: Mnesia
  # types link https://www.erlang.org/doc/man/mnesia#data-types

  def error_description(error), do: Mnesia.error_description(error)

  def error({:atomic, :ok}), do: {:ok, :atomic}

  def error(error) do
    {err_msg, _} = Mnesia.error_description(error)
    {:error, error, err_msg}
  end
end
