defmodule AssetManager.Projectors.TransactionProjector do
  use Commanded.Projections.Ecto,
    application: AssetManager.CommandedApp,
    repo: AssetManager.Repo,
    name: "TransactionProjector"

  alias Ecto.{Changeset, Multi}
  alias AssetManager.Repo
  alias AssetManager.ServiceAccounts.Events.Deposited
  alias AssetManager.Projections.DepositTransaction

  project(%Deposited{} = evt, _, fn multi ->
    multi
    |> Multi.run(:all, fn _repo, _changes ->
      all =
        Repo.get_by(DepositTransaction,
          created_at: evt.created_at
        ) ||
          %DepositTransaction{
            request_id: evt.request_id,
            amount: Decimal.new(0),
            created_at: evt.created_at
          }

      {:ok, all}
    end)
    |> Multi.insert_or_update(:all_updated, fn %{all: %DepositTransaction{} = all} ->
      all
      |> Changeset.change(
        amount: Decimal.add(all.amount, evt.amount),
        created_at: evt.created_at
      )
    end)
  end)
end
