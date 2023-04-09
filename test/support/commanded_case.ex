defmodule AssetManager.CommandedCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import AssetManager.CommandedCase
      import Commanded.Assertions.EventAssertions
    end
  end

  setup do
    AssetManager.Storage.reset!()

    start_supervised!(AssetManager.CommandedApp)

    :ok
  end

  def append_event!(event, stream_uuid, metadata \\ %{}) do
    event_data =
      event
      |> Commanded.Event.Mapper.map_to_event_data(metadata: metadata)
      |> Commanded.EventStore.Adapters.EventStore.Mapper.to_event_data()
      |> Map.put(:event_id, metadata[:event_id])

    :ok = AssetManager.EventStore.append_to_stream(stream_uuid, :any_version, [event_data])
    :ok
  end

  def append_events!(events, stream_uuid, metadata \\ %{}) do
    for event <- events do
      :ok = append_event!(event, stream_uuid, metadata)
    end

    :ok
  end

  def wait_event_handler!(event_handler_pid, retries \\ 10, delay_ms \\ 500) do
    %Commanded.Event.Handler{last_seen_event: last_seen_event} = :sys.get_state(event_handler_pid)

    {:ok, [%EventStore.RecordedEvent{event_number: ^last_seen_event}]} =
      AssetManager.EventStore.read_all_streams_backward(-1, 1)

    :ok
  rescue
    _ ->
      if retries <= 0 do
        raise "wait projector timeout"
      else
        :timer.sleep(delay_ms)
        wait_event_handler!(event_handler_pid, retries - 1, delay_ms)
      end
  end
end
