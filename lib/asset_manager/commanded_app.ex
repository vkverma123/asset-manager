defmodule AssetManager.CommandedApp do
  use Commanded.Application,
    otp_app: :asset_manager,
    event_store: [
      adapter: Commanded.EventStore.Adapters.EventStore,
      event_store: AssetManager.EventStore
    ]

  router(AssetManager.CommandedRouter)

  @impl true
  def init(config) do
    {:ok, Keyword.merge(config, Application.get_env(:asset_manager, __MODULE__, []))}
  end
end
