defmodule Parallelixir.EnqueuedJobsProcessor do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__,
      args,
      name: __MODULE__
    )
  end

  @impl true
  def init([queues]) do
    {:ok, [queues], {:continue, :watch_queues}}
  end

  @impl true
  def handle_continue(:watch_queues, queues) do
    process queues

    {:noreply, queues}
  end

  @impl true
  def handle_cast(:new_job_enqueued, queues) do
    process queues

    {:noreply, queues}
  end

  defp process(queues) do
    queues |> Enum.each(fn (queue_name) ->
      {:ok, queue} = :redix |> Redix.command(["LRANGE", queue_name, 0, -1])

      queue |> Enum.each(fn (_) ->
        {:ok, payload} = :redix |> Redix.command(["LPOP", queue_name])

        start_worker(payload)
      end)
    end)
  end

  defp start_worker(payload) do
    GenServer.cast(
      Parallelixir.WorkerServer,
      {:start_worker, payload}
    )
  end
end
