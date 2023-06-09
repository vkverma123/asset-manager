defmodule AssetManager.Repo.Migrations.AddTransactionProjector do
  use Ecto.Migration

  def change do
    create table("deposit_transactions", primary_key: false) do
      add :request_id, :string, primary_key: true
      add :created_at, :utc_datetime_usec
      add :amount, :decimal

      timestamps(type: :utc_datetime_usec)
    end

    create index("deposit_transactions", [:created_at])
  end
end
