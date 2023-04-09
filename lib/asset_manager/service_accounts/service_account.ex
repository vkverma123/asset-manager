defmodule AssetManager.ServiceAccounts.ServiceAccount do
  require Logger

  alias Commanded.Aggregates.ExecutionContext
  alias AssetManager.ServiceAccounts.AggregateIdentity
  alias AssetManager.ServiceAccounts.Commands.Deposit
  alias AssetManager.ServiceAccounts.Events.Deposited

  @derive Jason.Encoder
  defstruct request_id: nil,
            created_at: nil,
            balance: Decimal.new(0)

  defimpl Commanded.Serialization.JsonDecoder do
    def decode(state) do
      %{state | balance: Decimal.new(state.balance)}
    end
  end

  def identity(request_id, created_at, balance) do
    "account:#{request_id}:#{created_at}:#{balance}"
  end

  def before_execute(%__MODULE__{}, %ExecutionContext{command: cmd}) do
    Logger.metadata(stream_uuid: AggregateIdentity.identity(cmd))
    :ok
  end

  def execute(state, command)

  def execute(%__MODULE__{}, %Deposit{
        request_id: request_id,
        amount: amount,
        created_at: created_at
      }) do
    cond do
      not Decimal.gt?(amount, 0) ->
        {:error, :invalid_amount}

      DateTime.compare(DateTime.utc_now(), created_at) not in [:gt, :eq] ->
        {:error, :invalid_datetime}

      true ->
        %Deposited{
          request_id: request_id,
          amount: amount,
          created_at: created_at
        }
    end
  end

  def apply(state, event)

  def apply(%__MODULE__{} = state, %Deposited{} = evt) do
    if new_state?(state) do
      %__MODULE__{
        request_id: evt.request_id,
        created_at: evt.created_at,
        balance: Decimal.new(evt.amount)
      }
    else
      state
    end
  end

  defp new_state?(%__MODULE__{request_id: nil, created_at: nil}), do: true
  defp new_state?(%__MODULE__{}), do: false
end
