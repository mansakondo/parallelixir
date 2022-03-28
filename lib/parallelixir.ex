defmodule Parallelixir do
  use Application

  def start(_type, _args) do
    queues = [
      "parallelixir:queue:default"
    ]

    children = [
      Parallelixir.WorkerSupervisor,
      {
        Parallelixir.WatcherSupervisor,
        [queues]
      },
      Parallelixir.Server
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
