defmodule AssetManagerWeb.Actions.ListBalancesTest do
  use AssetManagerWeb.ConnCase

  alias AssetManager.Projections.DepositTransaction
  alias AssetManager.Repo

  test "balances sorted by product_id", %{conn: conn} do
    params = %{
      "start_datetime" => "2019-10-05T12:45:05+07:00",
      "end_datetime" => "2022-10-05T21:45:05+07:00"
    }

    [
      %DepositTransaction{
        request_id: "ee3b5a3c-1bd3-4697-9d70-9d609067b463",
        amount: Decimal.new("100.700"),
        created_at: ~U"2019-10-05T08:10:00.000000Z"
      },
      %DepositTransaction{
        request_id: "ee3b5a3c-1bd3-4697-9d70-9d609067b464",
        amount: Decimal.new("200.700"),
        created_at: ~U"2019-10-05T08:20:00.000000Z"
      }
    ]
    |> Enum.each(&Repo.insert!/1)

    conn = post(conn, "/api/list-balances", params)

    assert %{
             "success" => true,
             "data" => data
           } = json_response(conn, 200)

    assert [
             %{"amount" => "100.7", "datetime" => "2019-10-05T08:10:00+00:00"},
             %{"amount" => "200.7", "datetime" => "2019-10-05T08:20:00+00:00"}
           ] = data
  end
end
