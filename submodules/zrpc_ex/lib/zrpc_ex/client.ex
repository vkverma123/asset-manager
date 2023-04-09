defmodule ZrpcEx.Client do
  use Tesla
  alias ZrpcEx.Client.{TimeoutError, StatusNotOkError, UnhandledError}

  @type config :: [{:base_url, String.t()} | {:proxy_url, String.t()} | {:timeout, timeout()}]

  @callback config(config()) :: config()

  defmacro __using__(opts \\ []) do
    quote do
      @behaviour ZrpcEx.Client

      @opts unquote(opts)

      @impl ZrpcEx.Client
      def config(config), do: config

      def call(path, params, opts \\ []) do
        config = parse_config!(opts)

        ZrpcEx.Client.call(path, params, config)
      end

      defp parse_config!(opts) do
        @opts
        |> Keyword.merge(__MODULE__.config(@opts))
        |> Keyword.merge(opts)
      end

      defoverridable config: 1
    end
  end

  def call(path, body, opts) do
    {base_url, opts} = Keyword.pop!(opts, :base_url)
    {proxy_url, opts} = Keyword.pop(opts, :proxy_url)
    {timeout, opts} = Keyword.pop(opts, :timeout)

    Tesla.client(
      [
        {Tesla.Middleware.BaseUrl, base_url},
        {Tesla.Middleware.Headers, request_id_headers()},
        Tesla.Middleware.JSON,
        Tesla.Middleware.Telemetry,
        Tesla.Middleware.OpenTelemetry
      ],
      {Tesla.Adapter.Hackney, timeout_opts(timeout) ++ proxy_opts(proxy_url)}
    )
    |> Tesla.post(path, body, opts)
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"success" => true, "data" => data}}} ->
        {:ok, data}

      {:ok, %Tesla.Env{status: 200, body: %{"success" => false, "error" => error}}} ->
        {:error, error}

      {:ok, %Tesla.Env{status: status, body: body}} ->
        raise StatusNotOkError, status: status, body: body

      {:error, :timeout} ->
        raise TimeoutError

      {:error, error} ->
        raise UnhandledError, error
    end
  end

  defp request_id_headers do
    case Logger.metadata()[:request_id] do
      nil -> []
      request_id -> [{"x-request-id", request_id}]
    end
  end

  defp timeout_opts(nil), do: []
  defp timeout_opts(timeout), do: [recv_timeout: timeout]

  defp proxy_opts(proxy_url) when proxy_url in [nil, ""], do: []
  defp proxy_opts(proxy_url), do: [proxy: proxy_url]
end
