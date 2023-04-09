defmodule ZrpcEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :zrpc_ex,
      version: "0.1.0",
      elixir: "~> 1.11",
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
      {:ecto, "~> 3.7"},
      {:hackney, "~> 1.18"},
      {:jason, "~> 1.2"},
      {:opentelemetry_tesla, "~> 2.0"},
      {:plug_cowboy, "~> 2.5"},
      {:tesla, "~> 1.4"},
      {:bypass, "~> 2.1", only: :test},
      {:mimic, "~> 1.5", only: :test}
    ]
  end
end
