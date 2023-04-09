defmodule AssetManager.MixProject do
  use Mix.Project

  def project do
    [
      app: :asset_manager,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [plt_core_path: "_build/#{Mix.env()}", plt_add_apps: [:ex_unit]]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {AssetManager.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # submodules
      {:common_lib, path: "submodules/common_lib"},
      {:zrpc_ex, path: "submodules/zrpc_ex"},
      # deps
      {:commanded, github: "commanded/commanded", tag: "v1.4.1", override: true},
      {:commanded_eventstore_adapter,
       github: "commanded/commanded-eventstore-adapter", tag: "v1.4.0"},
      {:commanded_ecto_projections,
       github: "commanded/commanded-ecto-projections", tag: "v1.3.0"},
      {:ecto_sql, "~> 3.8.2"},
      {:eventstore, "~> 1.3.2"},
      {:jason, "~> 1.0"},
      {:libcluster, "~> 3.3"},
      {:logger_json, "~> 5.0"},
      {:opentelemetry, "~> 1.0"},
      {:opentelemetry_api, "~> 1.0"},
      {:opentelemetry_ecto, "~> 1.0"},
      {:opentelemetry_exporter, "~> 1.0"},
      {:opentelemetry_logger_metadata, "~> 0.1"},
      {:opentelemetry_phoenix, "~> 1.0"},
      {:opentelemetry_process_propagator, "~> 0.1"},
      {:opentelemetry_telemetry, "~> 1.0"},
      {:phoenix_ecto, "~> 4.4.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix, "~> 1.6.2"},
      {:plug_cowboy, "~> 2.5.2"},
      {:postgrex, ">= 0.0.0"},
      {:prom_ex, "~> 1.5"},
      {:telemetry, "~> 1.0"},
      {:timex, "~> 3.7.6"},
      # dev
      {:assert_eventually, "~> 1.0.0", only: [:dev, :test]},
      {:credo, "~> 1.6.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:mimic, "~> 1.5", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "es.setup"],
      reset: ["ecto.reset", "es.reset"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "es.setup": ["event_store.create", "event_store.init"],
      "es.reset": ["event_store.drop", "es.setup"],
      test: ["es.setup", "ecto.setup", "test"],
      "ecto.seeds": ["run priv/repo/seeds.exs"],
      "dev.reset": ["ecto.reset", "es.reset", "ecto.seeds"]
    ]
  end
end
