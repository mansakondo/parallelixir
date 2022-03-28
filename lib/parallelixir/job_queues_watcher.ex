defmodule Parallelixir.JobQueuesWatcher do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__,
      args,
      name: __MODULE__
    )
  end

  @impl true
  def init([queues]) do
    {:ok, queues}
  end

  @impl true
  def handle_cast(:new_job_enqueued, queues) do
    watch queues
  end

  defp watch(queues) do
    queues |> Enum.each(fn (queue_name) ->
      {:ok, queue} = :redix |> Redix.command(["LRANGE", queue_name, 0, -1])

      queue |> Enum.each(fn (_) ->
        {:ok, payload} = :redix |> Redix.command(["LPOP", queue_name])

        start_worker(payload)
      end)
    end)

    {:noreply, queues}
  end

  defp start_worker(payload) do
    GenServer.cast(
      Parallelixir.WorkerServer,
      {:start_worker, payload}
    )
  end
end
