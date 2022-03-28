defmodule Parallelixir.WorkerSupervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__,
      args,
      name: __MODULE__
    )
  end

  @impl true
  def init(_args) do
    children = [
      {
        Task.Supervisor,
        name: Parallelixir.TaskSupervisor
      },
      Parallelixir.WorkerServer,
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
