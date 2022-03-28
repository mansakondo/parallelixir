defmodule Parallelixir.WorkerServer do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__,
      args,
      name: __MODULE__
    )
  end

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:start_worker, payload}, _) do
    payload |> start_worker

    {:noreply, payload}
  end

  defp start_worker(payload) do
    Task.Supervisor.start_child(Parallelixir.TaskSupervisor,
      Parallelixir.Worker,
      :perform,
      [payload],
      restart: :transient
    )
  end
end
