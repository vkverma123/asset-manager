defmodule AssetManager.ServiceAccounts.Commands.Deposit do
  defstruct [
    :request_id,
    :amount,
    :created_at
  ]

  @type t :: %__MODULE__{
          request_id: UUID.t(),
          amount: Decimal.t(),
          created_at: DateTime.t()
        }
end

defimpl AssetManager.ServiceAccounts.AggregateIdentity,
  for: AssetManager.ServiceAccounts.Commands.Deposit do
  alias AssetManager.ServiceAccounts.Commands.Deposit
  alias AssetManager.ServiceAccounts.ServiceAccount

  def identity(cmd = %Deposit{}) do
    ServiceAccount.identity(cmd.request_id, cmd.created_at, cmd.amount)
  end
end
