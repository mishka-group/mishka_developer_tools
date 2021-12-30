defmodule MishkaDeveloperTools.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MishkaDeveloperTools.Repo
    ]
    opts = [strategy: :one_for_one, name: MishkaDeveloperTools.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
