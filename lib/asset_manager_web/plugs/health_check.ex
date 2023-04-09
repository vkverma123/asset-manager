defmodule AssetManagerWeb.Plug.HealthCheck do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(%Plug.Conn{request_path: request_path} = conn, opts) do
    if request_path == opts[:at] do
      case do_health_check() do
        :ok ->
          conn
          |> json(%{status: "ok"})
          |> halt()

        :error ->
          conn
          |> put_status(:internal_server_error)
          |> json(%{status: "error"})
          |> halt()
      end
    else
      conn
    end
  end

  defp do_health_check() do
    Task.yield_many(
      [
        Task.async(fn -> AssetManager.EventStore.status() end),
        Task.async(fn -> AssetManager.Repo.status() end)
      ],
      3_000
    )
    |> Enum.all?(&match?({_task, {:ok, :ok}}, &1))
    |> case do
      true -> :ok
      false -> :error
    end
  end
end
