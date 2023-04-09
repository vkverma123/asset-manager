defmodule AssetManager.ServiceAccounts.Events.Deposited do
  @derive Jason.Encoder
  defstruct [
    :request_id,
    :created_at,
    :amount
  ]

  defimpl Commanded.Serialization.JsonDecoder do
    def decode(evt) do
      {:ok, datetime, _offset} = DateTime.from_iso8601(evt.created_at)
      {:ok, utc_datetime} = DateTime.shift_zone(datetime, "Etc/UTC")

      %{
        evt
        | amount: Decimal.new(evt.amount),
          created_at: round_datetime_to_next_hour(utc_datetime)
      }
    end

    defp round_datetime_to_next_hour(%DateTime{} = dt) do
      dt
      |> Timex.shift(microseconds: -1)
      |> Timex.shift(hours: 1)
      |> Timex.set(minute: 0, second: 0, microsecond: {0, 6})
    end
  end
end
