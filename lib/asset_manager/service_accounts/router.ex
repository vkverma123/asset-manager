defmodule AssetManager.ServiceAccounts.Router do
  use Commanded.Commands.Router

  alias AssetManager.ServiceAccounts.AggregateIdentity
  alias AssetManager.ServiceAccounts.ServiceAccount
  alias AssetManager.ServiceAccounts.ServiceAccountLifespan

  alias AssetManager.ServiceAccounts.Commands.Deposit

  dispatch(
    Deposit,
    identity: &AggregateIdentity.identity/1,
    to: ServiceAccount,
    lifespan: ServiceAccountLifespan,
    before_execute: :before_execute
  )
end
