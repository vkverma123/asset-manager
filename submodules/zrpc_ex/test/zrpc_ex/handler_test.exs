defmodule ZrpcEx.HandlerTest do
  use ExUnit.Case
  use Plug.Test

  alias ZrpcEx.Handler

  defmodule TestSuccessApi do
    use Handler

    @impl Handler
    def validate(%{"with_result" => with_result}), do: {:ok, with_result}

    @impl Handler
    def execute(_with_result = false) do
      :ok
    end

    def execute(_with_result = true) do
      {:ok, %{"result" => true}}
    end
  end

  defmodule TestErrorApi do
    use Handler

    @impl Handler
    def validate(%{"error" => "validation", "type" => "map"}) do
      {:error, %{"field_1" => "cannot be null"}}
    end

    def validate(%{"error" => "validation", "type" => "constructor"}) do
      {:error, {:constructor, %{"field_1" => "cannot be null"}}}
    end

    def validate(%{"error" => "validation", "type" => "ecto"}) do
      data = %{}
      types = %{field_1: :string}
      params = %{"field_1" => nil}

      {data, types}
      |> Ecto.Changeset.cast(params, [:field_1])
      |> Ecto.Changeset.validate_required([:field_1])
      |> Ecto.Changeset.apply_action(:validate)
    end

    def validate(%{"error" => "business_logic"}) do
      {:ok, %{error: :business_logic}}
    end

    def validate(%{"error" => "business_logic_with_description", "description" => description}) do
      {:ok, %{error: :business_logic_with_description, description: description}}
    end

    def validate(%{"error" => "raise"}) do
      {:ok, %{error: :raise}}
    end

    @impl Handler
    def execute(%{error: :business_logic}) do
      {:error, :business_logic}
    end

    def execute(%{error: :business_logic_with_description, description: description}) do
      {:error, {:business_logic_with_description, description}}
    end

    def execute(%{error: :raise}) do
      raise "something went wrong"
    end
  end

  test "init/1" do
    assert [] = TestSuccessApi.init([])
  end

  describe "call/1" do
    test "success" do
      conn =
        conn(:post, "/success-api", %{"with_result" => false})
        |> TestSuccessApi.call([])

      assert [content_type] = get_resp_header(conn, "content-type")
      assert content_type =~ "application/json"

      assert %{
               "success" => true,
               "data" => nil
             } == Jason.decode!(conn.resp_body)
    end

    test "success with result" do
      conn =
        conn(:post, "/success-api", %{"with_result" => true})
        |> TestSuccessApi.call([])

      assert [content_type] = get_resp_header(conn, "content-type")
      assert content_type =~ "application/json"

      assert %{
               "success" => true,
               "data" => %{"result" => true}
             } == Jason.decode!(conn.resp_body)
    end

    test "validation error (map)" do
      conn =
        conn(:post, "/error-api", %{"error" => "validation", "type" => "map"})
        |> TestErrorApi.call([])

      assert %{
               "success" => false,
               "error" => %{
                 "code" => "validation_error",
                 "description" => %{"field_1" => "cannot be null"}
               }
             } == Jason.decode!(conn.resp_body)
    end

    test "validation error (constructor)" do
      conn =
        conn(:post, "/error-api", %{"error" => "validation", "type" => "constructor"})
        |> TestErrorApi.call([])

      assert %{
               "success" => false,
               "error" => %{
                 "code" => "validation_error",
                 "description" => %{"field_1" => "cannot be null"}
               }
             } == Jason.decode!(conn.resp_body)
    end

    test "validation error (ecto)" do
      conn =
        conn(:post, "/error-api", %{"error" => "validation", "type" => "ecto"})
        |> TestErrorApi.call([])

      assert %{
               "success" => false,
               "error" => %{
                 "code" => "validation_error",
                 "description" => %{"field_1" => "can't be blank"}
               }
             } == Jason.decode!(conn.resp_body)
    end

    test "business logic error" do
      conn =
        conn(:post, "/error-api", %{"error" => "business_logic"})
        |> TestErrorApi.call([])

      assert %{
               "success" => false,
               "error" => %{
                 "code" => "business_logic"
               }
             } == Jason.decode!(conn.resp_body)
    end

    test "business logic with description error" do
      conn =
        conn(:post, "/error-api", %{
          "error" => "business_logic_with_description",
          "description" => "test_description"
        })
        |> TestErrorApi.call([])

      assert %{
               "success" => false,
               "error" => %{
                 "code" => "business_logic_with_description",
                 "description" => "test_description"
               }
             } == Jason.decode!(conn.resp_body)
    end

    test "raise exception error" do
      conn =
        conn(:post, "/error-api", %{"error" => "raise"})
        |> TestErrorApi.call([])

      assert conn.status == 500
      assert conn.resp_body == "internal server error"
    end
  end
end
