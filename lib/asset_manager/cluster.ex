defmodule AssetManager.Cluster do
  def child_spec(_opts) do
    Cluster.Supervisor.child_spec([config(), [name: __MODULE__]])
  end

  defp config do
    Application.get_env(:asset_manager, __MODULE__, [])
  end
end
