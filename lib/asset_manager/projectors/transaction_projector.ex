defmodule AssetManager.Projectors.TransactionProjector do
  use Commanded.Projections.Ecto,
    application: AssetManager.CommandedApp,
    repo: AssetManager.Repo,
    name: "TransactionProjector"

  alias Ecto.Multi
  alias AssetManager.ServiceAccounts.Events.Deposited
  alias AssetManager.Projections.DepositTransaction

  project(%Deposited{} = evt, _, fn multi ->
    multi
    |> Multi.insert(:deposit_transaction, %DepositTransaction{
      request_id: evt.request_id,
      amount: evt.amount,
      created_at: evt.created_at
    })
  end)
end
