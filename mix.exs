defmodule MishkaDeveloperTools.MixProject do
  use Mix.Project

  def project do
    [
      app: :mishka_developer_tools,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.7"},
      {:postgrex, "~> 0.15.13"},
      {:ex_doc, "~> 0.26", only: :dev, runtime: false}
    ]
  end
end
