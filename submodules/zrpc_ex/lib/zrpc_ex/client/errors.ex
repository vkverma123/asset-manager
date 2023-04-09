defmodule ZrpcEx.Client.TimeoutError do
  defexception message: "timeout"
end

defmodule ZrpcEx.Client.StatusNotOkError do
  defexception [:message, :status, :body]
  @impl true
  def exception(status: status, body: body) do
    %__MODULE__{message: "status=#{status} body=#{inspect(body)}", status: status, body: body}
  end
end

defmodule ZrpcEx.Client.UnhandledError do
  defexception [:message, :error]
  @impl true
  def exception(error) do
    %__MODULE__{message: inspect(error), error: error}
  end
end
