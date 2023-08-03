defmodule MishkaDeveloperTools.MixProject do
  use Mix.Project
  @version "0.1.0"

  def project do
    [
      app: :mishka_developer_tools,
      version: @version,
      elixir: "~> 1.15",
      name: "Mishka developer tools",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      homepage_url: "https://github.com/mishka-group",
      source_url: "https://github.com/mishka-group/mishka_developer_tools",
      test_elixirc_options: [debug_info: Mix.env() == :test],
      docs: [
        main: "MishkaDeveloperTools",
        source_ref: "master",
        extras: ["README.md"],
        source_url: "https://github.com/mishka-group/mishka_developer_tools"
      ]
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
      {:ecto_sql, "~> 3.10", optional: true},
      {:postgrex, "~> 0.17.2", optional: true},
      {:ecto_enum, "~> 1.4", optional: true},
      {:html_sanitize_ex, "~> 1.4.3", optional: true},
      {:email_checker, "~> 0.2.4", optional: true},
      {:ex_url, github: "kipcole9/url", optional: true},
      # Dev dependencies
      {:ex_doc, "~> 0.30.2", only: :dev, runtime: false}
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
      licenses: ["Apache-2.0"],
      maintainers: ["Shahryar Tavakkoli"],
      links: %{"GitHub" => "https://github.com/mishka-group/mishka_developer_tools"}
    ]
  end
end
