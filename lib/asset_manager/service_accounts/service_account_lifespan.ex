defmodule AssetManager.ServiceAccounts.ServiceAccountLifespan do
  @behaviour Commanded.Aggregates.AggregateLifespan

  @default_idle_timeout :timer.minutes(5)

  @impl true
  def after_event(_event), do: @default_idle_timeout

  @impl true
  def after_command(_command), do: @default_idle_timeout

  @impl true
  def after_error(_error), do: @default_idle_timeout
end
