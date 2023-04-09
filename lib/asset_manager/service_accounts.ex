defmodule AssetManager.ServiceAccounts do
  import Ecto.Query
  alias AssetManager.Projections.DepositTransaction
  alias AssetManager.CommandedApp
  alias AssetManager.ServiceAccounts.Commands
  alias AssetManager.Repo

  @dispatch_timeout :timer.seconds(60)

  @spec deposit(%{
          datetime: String.t(),
          amount: Decimal.t()
        }) :: :ok | {:error, :invalid_amount} | {:error, :invalid_datetime}
  def deposit(args) do
    {:ok, datetime, _offset} = DateTime.from_iso8601(args.datetime)
    {:ok, utc_datetime} = DateTime.shift_zone(datetime, "Etc/UTC")

    %Commands.Deposit{
      amount: args.amount,
      created_at: utc_datetime,
      request_id: UUID.uuid4()
    }
    |> dispatch()
  end

  @spec list_balances(start_datetime :: DateTime.t(), end_datetime :: DateTime.t()) ::
          [DepositTransaction.t()]
  def list_balances(start_datetime, end_datetime) do
    DepositTransaction
    |> where([b], b.created_at >= ^start_datetime and b.created_at <= ^end_datetime)
    |> order_by([b], asc: b.created_at)
    |> select([b], %{hour: b.created_at, amount: sum(b.amount)})
    |> group_by([b], b.created_at)
    |> Repo.all()
  end

  defp dispatch(cmd) do
    case CommandedApp.dispatch(cmd, timeout: @dispatch_timeout) do
      :ok -> :ok
      {:ok, _} -> :ok
      {:error, :duplicate_event} -> :ok
      error -> error
    end
  end
end
