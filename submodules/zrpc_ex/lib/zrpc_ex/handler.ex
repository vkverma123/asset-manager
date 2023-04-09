defmodule ZrpcEx.Handler do
  @callback validate(params :: map()) :: {:ok, any()} | {:error, any()}
  @callback execute(request :: any()) :: :ok | {:ok, any()} | {:error, any()}

  defmacro __using__(_opts) do
    quote do
      @behaviour ZrpcEx.Handler
      @behaviour Plug

      @impl Plug
      def init(opts), do: opts

      @impl Plug
      def call(%Plug.Conn{} = conn, _opts) do
        ZrpcEx.Handler.execute(conn, __MODULE__)
      end
    end
  end

  import Plug.Conn

  def execute(%Plug.Conn{body_params: params} = conn, handler_module) do
    try do
      case handler_module.validate(params) do
        {:error, error} ->
          resp = render_error(error)
          json_response(conn, resp)

        {:ok, validated} ->
          case handler_module.execute(validated) do
            :ok ->
              resp = render_ok(nil)
              json_response(conn, resp)

            {:ok, result} ->
              resp = render_ok(result)
              json_response(conn, resp)

            {:error, error} ->
              resp = render_error(error)
              json_response(conn, resp)
          end
      end
    catch
      _, _ ->
        text_response(conn, :internal_server_error, "internal server error")
    end
  end

  defp json_response(conn, response) do
    conn
    |> put_resp_content_type("application/json")
    |> resp(:ok, Jason.encode!(response))
  end

  defp text_response(conn, status, message) do
    conn
    |> resp(status, message)
  end

  defp render_ok(result) do
    %{
      "success" => true,
      "data" => result
    }
  end

  defp render_error({:constructor, %{} = errors}) do
    %{
      "success" => false,
      "error" => %{
        "code" => "validation_error",
        "description" => errors
      }
    }
  end

  defp render_error(%Ecto.Changeset{} = changeset) do
    %{
      "success" => false,
      "error" => %{
        "code" => "validation_error",
        "description" =>
          Ecto.Changeset.traverse_errors(changeset, &translate_changeset_error/1)
          |> Map.new(fn {key, [error | _]} -> {key, error} end)
      }
    }
  end

  defp render_error(%{} = errors) do
    %{
      "success" => false,
      "error" => %{
        "code" => "validation_error",
        "description" => errors
      }
    }
  end

  defp render_error({error, description}) when is_atom(error) do
    %{
      "success" => false,
      "error" => %{"code" => error, "description" => description}
    }
  end

  defp render_error(error) when is_binary(error) do
    %{
      "success" => false,
      "error" => %{"code" => error}
    }
  end

  defp render_error(error) when is_atom(error) do
    render_error(Atom.to_string(error))
  end

  defp translate_changeset_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
