defmodule AssetManagerWeb.Router do
  use AssetManagerWeb, :router

  alias AssetManagerWeb.Actions

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api" do
    pipe_through :api

    post "/deposit", Actions.Deposit, []
    post "/list-balances", Actions.ListBalances, []
  end
end
