defmodule MnesiaAssistant.Schema do
  alias :mnesia, as: Mnesia

  # Schema
  def schema(), do: Mnesia.schema()

  def create(nodes \\ [node()]) when is_list(nodes) do
    create_dir()
    Mnesia.create_schema([node()])
  end

  def delete_schema(nodes \\ [node()]), do: Mnesia.delete_schema(nodes)

  defp create_dir() do
    path = Application.get_env(:mnesia, :dir)

    with true <- !is_nil(path), false <- File.dir?(path) do
      :ok = File.mkdir_p!(path)
    end
  end
end
