import Config
config :mishka_developer_tools, ecto_repos: [MishkaDeveloperTools.Repo]

config :mishka_developer_tools, MishkaDeveloperTools.Repo,
  database: "mishka_developer_tools_test",
  username: System.get_env("DATABASE_USER"),
  password: System.get_env("DATABASE_PASSWORD"),
  hostname: System.get_env("DATABASE_HOST"),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10
