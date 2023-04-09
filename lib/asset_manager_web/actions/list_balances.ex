defmodule AssetManagerWeb.Actions.ListBalances do
  defmodule Request do
    use CommonLib.Constructor

    constructor do
      field :start_datetime, String.t(), constructor: required(:string)
      field :end_datetime, String.t(), constructor: required(:string)
    end
  end

  use ZrpcEx.Handler

  @impl ZrpcEx.Handler
  def validate(params), do: Request.new(params)

  @impl ZrpcEx.Handler
  def execute(%Request{} = request) do
    utc_start_datetime = get_utc_datetime(request.start_datetime)
    utc_end_datetime = get_utc_datetime(request.end_datetime)

    if DateTime.compare(utc_start_datetime, utc_end_datetime) in [:gt] do
      {:error, :start_datetime_should_be_prior_to_end_datetime}
    else
      balances = AssetManager.ServiceAccounts.list_balances(utc_start_datetime, utc_end_datetime)

      {:ok,
       balances
       |> Enum.map(fn %{hour: hour, amount: amount} ->
         %{
           "datetime" => hour |> Timex.format!("%Y-%m-%dT%H:%M:%S%:z", :strftime),
           "amount" => amount |> Decimal.normalize() |> Decimal.to_string(:normal)
         }
       end)}
    end
  end

  def get_utc_datetime(dt) do
    {:ok, datetime, _offset} = DateTime.from_iso8601(dt)
    {:ok, utc_datetime} = DateTime.shift_zone(datetime, "Etc/UTC")

    utc_datetime
  end
end
