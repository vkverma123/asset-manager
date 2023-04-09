defmodule AssetManager.CommandedRouter do
  use Commanded.Commands.CompositeRouter
  alias AssetManager.ServiceAccounts

  router(ServiceAccounts.Router)
end
