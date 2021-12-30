if Mix.env() in [:test, :dev] do
  defmodule MishkaDeveloperTools.Repo do
    use Ecto.Repo,
      otp_app: :mishka_developer_tools,
      adapter: Ecto.Adapters.Postgres
  end
else
  raise BadEnv, message: "You can not use it as a prod package"
end
