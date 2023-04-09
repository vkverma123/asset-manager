defmodule CommonLib.MixProject do
  use Mix.Project

  def project do
    [
      app: :common_lib,
      version: "0.2.0",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
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

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:constructor, "~> 1.1.0"},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:decimal, "~> 2.0"},
      {:ecto, "~> 3.4"},
      {:excoveralls, "~> 0.11", only: :test, runtime: false},
      {:jason, "~> 1.2"},
      {:mimic, "~> 1.5", only: :test},
      {:elixir_uuid, "~> 1.2", only: :test},
      {:opentelemetry, "~> 1.0"},
      {:opentelemetry_api, "~> 1.0"},
      {:decorator, "~> 1.2"}
    ]
  end
end
