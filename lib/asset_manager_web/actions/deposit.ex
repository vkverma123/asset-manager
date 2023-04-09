defmodule AssetManagerWeb.Actions.Deposit do
  defmodule Request do
    use CommonLib.Constructor

    constructor do
      field :amount, Decimal.t(), constructor: required(:pos_decimal)
      field :datetime, String.t(), constructor: required(:string)
    end
  end

  use ZrpcEx.Handler

  @impl ZrpcEx.Handler
  def validate(params), do: Request.new(params)

  @impl ZrpcEx.Handler
  def execute(%Request{} = request) do
    request
    |> Map.from_struct()
    |> AssetManager.ServiceAccounts.deposit()
    |> case do
      :ok ->
        :ok

      {:error, :invalid_amount} ->
        {:error, "invalid_amount"}

      {:error, :invalid_datetime} ->
        {:error, "invalid_datetime"}
    end
  end
end
