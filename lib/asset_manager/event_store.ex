defmodule AssetManager.EventStore do
  use EventStore, otp_app: :asset_manager

  # Optional `init/1` function to modify config at runtime.
  def init(config) do
    {:ok, config}
  end

  def status do
    {conn, _opts} = parse_opts([])
    %Postgrex.Result{num_rows: 1, rows: [[1]]} = Postgrex.query!(conn, "SELECT 1", [])
    :ok
  catch
    _kind, e -> {:error, e}
  end
end
