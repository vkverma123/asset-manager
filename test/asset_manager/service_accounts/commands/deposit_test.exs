defmodule AssetManager.ServiceAccounts.Commands.DepositTest do
  use AssetManager.CommandedCase

  alias AssetManager.CommandedApp
  alias AssetManager.ServiceAccounts.AggregateIdentity
  alias AssetManager.ServiceAccounts.ServiceAccount
  alias AssetManager.ServiceAccounts.Commands.Deposit
  alias AssetManager.ServiceAccounts.Events.Deposited

  test "deposit" do
    cmd = %Deposit{
      amount: Decimal.new("100.7"),
      created_at: ~U"2019-10-05T14:38:05.000000Z",
      request_id: UUID.uuid4()
    }

    assert :ok = CommandedApp.dispatch(cmd)

    assert_receive_event(
      CommandedApp,
      Deposited,
      fn %Deposited{} = evt ->
        assert Decimal.eq?(evt.amount, cmd.amount)
        assert evt.request_id == cmd.request_id
      end
    )

    assert %ServiceAccount{balance: balance} = aggregate_state(AggregateIdentity.identity(cmd))
    assert Decimal.eq?(balance, cmd.amount)
  end

  test "deposit multiple times should create multiple event" do
    cmd1 = %Deposit{
      amount: Decimal.new("100.7"),
      created_at: ~U"2019-10-05T14:38:05.000000Z",
      request_id: UUID.uuid4()
    }

    assert :ok = CommandedApp.dispatch(cmd1)

    cmd2 = %Deposit{
      amount: Decimal.new("200.7"),
      created_at: ~U"2019-10-05T14:38:05.000000Z",
      request_id: UUID.uuid4()
    }

    assert :ok = CommandedApp.dispatch(cmd2)

    assert %ServiceAccount{balance: balance} = aggregate_state(AggregateIdentity.identity(cmd1))
    assert Decimal.eq?(balance, cmd1.amount)

    assert %ServiceAccount{balance: balance} = aggregate_state(AggregateIdentity.identity(cmd2))
    assert Decimal.eq?(balance, cmd2.amount)
  end

  test "error invalid amount" do
    cmd = %Deposit{
      amount: Decimal.new("-200.7"),
      created_at: ~U"2019-10-05T14:38:05.000000Z",
      request_id: UUID.uuid4()
    }

    assert {:error, :invalid_amount} = CommandedApp.dispatch(cmd)
  end

  defp aggregate_state(identity) do
    {:ok, _aggregate_uuid} =
      Commanded.Aggregates.Supervisor.open_aggregate(CommandedApp, ServiceAccount, identity)

    Commanded.Aggregates.Aggregate.aggregate_state(CommandedApp, ServiceAccount, identity)
  end
end
