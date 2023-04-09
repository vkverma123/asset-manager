defmodule AssetManager.ReleaseTask do
  @app :asset_manager

  def run_migration do
    run_ecto_migration()
    run_event_store_migration()
    :ok
  end

  def run_ecto_migration do
    Application.load(@app)

    {:ok, _} = Application.ensure_all_started(:ssl)

    repos = Application.fetch_env!(@app, :ecto_repos)

    for repo <- repos do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def run_event_store_migration do
    Application.load(@app)

    {:ok, _} = Application.ensure_all_started(:postgrex)
    {:ok, _} = Application.ensure_all_started(:ssl)

    event_stores = Application.fetch_env!(@app, :event_stores)

    for event_store <- event_stores do
      config = event_store.config()

      :ok = EventStore.Tasks.Init.exec(config)
      :ok = EventStore.Tasks.Migrate.exec(config)
    end
  end
end
