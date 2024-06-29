defmodule MishkaDeveloperTools.MixProject do
  use Mix.Project
  @version "0.1.6"
  @source_url "https://github.com/mishka-group/mishka_developer_tools"

  def project do
    [
      app: :mishka_developer_tools,
      version: @version,
      elixir: "~> 1.15",
      name: "Mishka developer tools",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      compilers: [:yecc, :leex] ++ Mix.compilers(),
      deps: deps(),
      description: description(),
      package: package(),
      homepage_url: "https://github.com/mishka-group",
      source_url: @source_url,
      test_elixirc_options: [debug_info: Mix.env() == :test],
      docs: [
        main: "MishkaDeveloperTools",
        source_ref: "master",
        extras: ["README.md"],
        source_url: @source_url
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :mnesia],
      included_applications: [:mnesia],
      mod: {MishkaDeveloperTools.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Optional dependencies
      {:html_sanitize_ex, "~> 1.4.3", optional: true},
      {:email_checker, "~> 0.2.4", optional: true},
      {:ex_url, "~> 2.0", optional: true},
      {:ex_phone_number, "~> 0.4.4", optional: true},
      {:nimble_totp, "~> 1.0", optional: true},
      {:joken, "~> 2.6", optional: true},
      {:jason, "~> 1.4", optional: true},
      {:plug, "~> 1.16", optional: true},
      # Make sure you have a C compiler installed. See the Comeonin wiki for details.
      # Wiki link: https://github.com/riverrun/comeonin/wiki/Requirements
      {:bcrypt_elixir, "~> 3.1", optional: true},
      {:pbkdf2_elixir, "~> 2.2", optional: true},
      {:argon2_elixir, "~> 4.0", optional: true},
      # Dev dependencies
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description() do
    "Mishka developer tools provides some macros and modules to make creating your elixir application as easy as possible"
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs LICENSE README*),
      licenses: ["Apache-2.0"],
      maintainers: ["Shahryar Tavakkoli"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/master/CHANGELOG.md"
      }
    ]
  end
end
