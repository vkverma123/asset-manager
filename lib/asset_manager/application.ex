defmodule AssetManager.Application do
  use Application

  @env Mix.env()

  @default_max_restarts 10

  def start(_type, _args) do
    OpentelemetryLoggerMetadata.setup()
    OpentelemetryEcto.setup([:asset_manager, :repo])
    OpentelemetryPhoenix.setup()

    children = children(@env)

    opts = [
      strategy: :one_for_one,
      name: AssetManager.Supervisor,
      max_restarts: supervisor_max_restarts()
    ]

    Supervisor.start_link(children, opts)
  end

  defp children(test_env) when test_env in [:test] do
    [
      {Phoenix.PubSub, name: AssetManager.PubSub},
      AssetManager.Repo,
      AssetManagerWeb.Endpoint
    ]
  end

  defp children(_) do
    [
      AssetManager.Cluster,
      {Phoenix.PubSub, name: AssetManager.PubSub},
      AssetManager.CommandedApp,
      AssetManager.Projectors.TransactionProjector,
      AssetManager.Repo,
      AssetManagerWeb.Endpoint
    ]
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AssetManagerWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp supervisor_max_restarts do
    Application.get_env(:asset_manager, :supervisor_max_restarts, @default_max_restarts)
  end
end
