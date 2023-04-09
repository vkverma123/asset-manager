defmodule ZrpcEx.ClientTest do
  use ExUnit.Case
  use Mimic

  alias ZrpcEx.Client

  describe "call/3" do
    setup do
      bypass = Bypass.open()
      {:ok, bypass: bypass}
    end

    test "success response", %{bypass: bypass} do
      Bypass.expect(bypass, "POST", "/api/api-01", fn conn ->
        # assert headers
        assert ["request_id_001"] = Plug.Conn.get_req_header(conn, "x-request-id")
        assert [content_type] = Plug.Conn.get_req_header(conn, "content-type")
        assert content_type =~ "application/json"

        # assert body
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert Jason.decode!(body) == %{"hello" => "from_client"}

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, """
        {
          "success": true,
          "data": {"hello": "from_server"}
        }
        """)
      end)

      Logger.metadata(request_id: "request_id_001")

      base_url = base_url(bypass)
      path = "api-01"
      params = %{"hello" => "from_client"}

      assert {:ok, %{"hello" => "from_server"}} = Client.call(path, params, base_url: base_url)
    end

    test "error response", %{bypass: bypass} do
      Bypass.expect(bypass, "POST", "/api/api-01", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, """
        {
          "success": false,
          "error": {"code": "dont_be_sad"}
        }
        """)
      end)

      base_url = base_url(bypass)
      path = "api-01"
      params = %{"hello" => "from_client"}

      assert {:error, %{"code" => "dont_be_sad"}} = Client.call(path, params, base_url: base_url)
    end

    test "timeout", %{bypass: bypass} do
      Bypass.stub(bypass, "POST", "/api/api-01", fn _conn ->
        Bypass.pass(bypass)
        Process.sleep(10_000)
      end)

      base_url = base_url(bypass)
      path = "api-01"
      params = %{"hello" => "from_client"}

      assert_raise Client.TimeoutError, fn ->
        Client.call(path, params, base_url: base_url, timeout: 100)
      end
    end

    test "status not ok", %{bypass: bypass} do
      Bypass.stub(bypass, "POST", "/api/api-01", fn conn ->
        conn
        |> Plug.Conn.resp(500, "Internal server error")
      end)

      base_url = base_url(bypass)
      path = "api-01"
      params = %{"hello" => "from_client"}

      assert_raise Client.StatusNotOkError, fn ->
        Client.call(path, params, base_url: base_url)
      end
    end
  end

  defp base_url(bypass), do: "http://localhost:#{bypass.port}/api"
end
