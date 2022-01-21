defmodule MishkaDeveloperTools.MixProject do
  use Mix.Project
  @version "0.0.3"

  def project do
    [
      app: :mishka_developer_tools,
      version: @version,
      elixir: "~> 1.13",
      name: "Mishka developer tools",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      homepage_url: "https://github.com/mishka-group",
      source_url: "https://github.com/mishka-group/mishka_developer_tools",
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {MishkaDeveloperTools.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.7"},

      # Test dependencies
      {:ecto_sql, "~> 3.7", only: :test},
      {:postgrex, "~> 0.15.13", only: :test},

      # Dev dependencies
      {:ex_doc, "~> 0.26", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description() do
    "Mishka developer tools provides some macros and modules to make creating your elixir site as easy as possible"
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs LICENSE README*),
      licenses: ["Apache License 2.0"],
      maintainers: ["Shahryar Tavakkoli"],
      links: %{"GitHub" => "https://github.com/mishka-group/mishka_developer_tools"}
    ]
  end
end
