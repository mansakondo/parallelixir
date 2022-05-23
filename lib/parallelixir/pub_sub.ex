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
    Logger.info "#{inspect(ref)} subscribed to parallelixir:notifications channel"
    {:noreply, pubsub}
  end

  @impl true
  def handle_info({:redix_pubsub, pubsub, _ref, :message, %{channel: "parallelixir:notifications", payload: payload}}, _) do
    case payload |> JSON.decode do
      {:ok, %{"message" => "New job enqueued"}} ->
        Logger.info "New job enqueued"

        GenServer.cast(Parallelixir.EnqueuedJobsProcessor,
          :new_job_enqueued
        )

      {:ok, %{"message" => "New job scheduled", "schedule_time" => schedule_time}} ->
        Logger.info "New job scheduled"

        GenServer.cast(Parallelixir.Scheduler,
          {:new_job_scheduled, schedule_time}
        )
    end

    {:noreply, pubsub}
  end

  @impl true
  def handle_info(_, state), do: {:noreply, state}
end
