defmodule Parallelixir.PubSub do
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__,
      args,
      name: __MODULE__
    )
  end

  @impl true
  def init(_) do
    {:ok, pubsub} = Redix.PubSub.start_link()

    pubsub |> Redix.PubSub.subscribe("parallelixir:notifications", self())

    {:ok, pubsub}
  end

  @impl true
  def handle_info({:redix_pubsub, pubsub, ref, :subscribed, %{channel: "parallelixir:notifications"}}, _) do
    Logger.info "#{inspect(ref)} subscribed to parallelixir:queues:notifications channel"
    {:noreply, pubsub}
  end

  @impl true
  def handle_info({:redix_pubsub, pubsub, _ref, :message, %{channel: "parallelixir:notifications", payload: "New job enqueued"}}, _) do
    Logger.info "New job enqueued"

    notify_watcher()

    {:noreply, pubsub}
  end

  @impl true
  def handle_info(_, state), do: {:noreply, state}

  defp notify_watcher do
    GenServer.cast(
      Parallelixir.JobQueuesWatcher,
      :new_job_enqueued
    )
  end
end
