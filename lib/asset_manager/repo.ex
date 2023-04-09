defmodule AssetManager.Repo do
  use Ecto.Repo,
    otp_app: :asset_manager,
    adapter: Ecto.Adapters.Postgres

  def status do
    %Postgrex.Result{num_rows: 1, rows: [[1]]} = query!("SELECT 1", [])
    :ok
  catch
    _kind, e -> {:error, e}
  end
end
