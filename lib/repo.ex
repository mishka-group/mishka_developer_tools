defmodule MishkaDeveloperTools.Repo do
  use Ecto.Repo,
    otp_app: :mishka_developer_tools,
    adapter: Ecto.Adapters.Postgres
end
