defmodule AssetManager.Projections.DepositTransaction do
  use Ecto.Schema

  @primary_key false
  schema "deposit_transactions" do
    field :request_id, :string
    field :amount, :decimal, primary_key: true
    field :created_at, :utc_datetime_usec, primary_key: true

    timestamps(type: :utc_datetime_usec)
  end
end
