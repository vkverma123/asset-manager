defmodule AssetManagerWeb.Actions.DepositTest do
  use AssetManagerWeb.ConnCase
  use Mimic.DSL

  alias AssetManager.ServiceAccounts

  test "success case", %{conn: conn} do
    params = %{
      "amount" => Decimal.new("100.7"),
      "datetime" => "2019-10-05T20:46:05+07:00"
    }

    expect ServiceAccounts.deposit(args) do
      assert Decimal.eq?(args.amount, params["amount"])
      assert args.datetime == params["datetime"]

      :ok
    end

    conn = post(conn, "/api/deposit", params)

    assert %{
             "success" => true,
             "data" => nil
           } = json_response(conn, 200)
  end
end
