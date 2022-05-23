defmodule Parallelixir.JobSupervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__,
      args,
      name: __MODULE__
    )
  end

  @impl true
  def init(args) do
    children = [
      {
        Redix,
        name: :redix,
        sync_connect: true,
        exit_on_disconnection: true
      },
      Parallelixir.PubSub,
      {Parallelixir.EnqueuedJobsProcessor, args},
      Parallelixir.Scheduler
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
