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
      utc_start_datetime_to_prev_hour = round_datetime_to_next_hour(utc_start_datetime)
      utc_end_datetime_to_next_hour = round_datetime_to_next_hour(utc_end_datetime)

      balances =
        AssetManager.ServiceAccounts.list_balances(
          utc_start_datetime_to_prev_hour,
          utc_end_datetime_to_next_hour
        )

      result = calculate(balances, utc_start_datetime_to_prev_hour, utc_end_datetime_to_next_hour)

      {:ok,
       result
       |> Enum.map(fn {hour, amount} ->
         %{
           "datetime" => hour |> Timex.format!("%Y-%m-%dT%H:%M:%S%:z", :strftime),
           "amount" => format_amount(amount)
         }
       end)}
    end
  end

  @spec calculate(list(), DateTime.t(), DateTime.t()) :: list()
  defp calculate(data, start_time, end_time) do
    duration = DateTime.diff(end_time, start_time)
    hours = div(duration, 3600) + 1

    timestamps =
      for i <- 0..(hours - 1),
          do: DateTime.add(start_time, i * 3600) |> Timex.set(microsecond: {0, 6})

    amounts =
      data
      |> Enum.reduce(%{}, fn %{amount: amount, hour: hour}, acc ->
        Map.put(acc, hour, amount)
      end)

    result =
      timestamps
      |> Enum.reduce(%{}, fn timestamp, acc ->
        if timestamp < Map.get(amounts, :hour) do
          Map.put(acc, timestamp, 0)
        else
          case Map.get(amounts, timestamp) do
            nil ->
              Map.put(acc, timestamp, Map.get(acc, timestamp |> Timex.shift(hours: -1)))

            amount ->
              Map.put(acc, timestamp, amount)
          end
        end
      end)

    result
  end

  def get_utc_datetime(dt) do
    {:ok, datetime, _offset} = DateTime.from_iso8601(dt)
    {:ok, utc_datetime} = DateTime.shift_zone(datetime, "Etc/UTC")

    utc_datetime
  end

  defp round_datetime_to_next_hour(%DateTime{} = dt) do
    dt
    |> Timex.shift(microseconds: -1)
    |> Timex.shift(hours: 1)
    |> Timex.set(minute: 0, second: 0, microsecond: {0, 6})
  end

  defp format_amount(nil), do: 0
  defp format_amount(amount), do: amount |> Decimal.normalize() |> Decimal.to_string(:normal)
end
