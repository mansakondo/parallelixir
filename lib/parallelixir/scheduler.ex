defmodule Parallelixir.Scheduler do
  use GenServer
  require Logger

  def start_link(options) do
    GenServer.start_link(__MODULE__,
      options,
      name: __MODULE__
    )
  end

  @impl true
  def init([]) do
    {:ok, [], {:continue, :schedule}}
  end

  @impl true
  def handle_continue(:schedule, state) do
    schedule_jobs()

    {:noreply, state}
  end

  @impl true
  def handle_cast({:new_job_scheduled, schedule_time}, state) do
    job = get_job_by schedule_time: schedule_time

    schedule job

    {:noreply, state}
  end

  @impl true
  def handle_info({:enqueue, job}, state) do
    enqueue job

    {:noreply, state}
  end

  defp scheduled_jobs do
    {:ok, result} = :redix
    |> Redix.command(["ZRANGE", "parallelixir:scheduled-jobs", "0", "-1", "WITHSCORES"])

    result |> Stream.chunk_every(2)
  end

  defp schedule_jobs do
    scheduled_jobs()
    |> Enum.each(fn (job) ->
      job |> schedule
    end)
  end

  defp schedule(job) do
    [payload, schedule_time] = job

    {:ok, decoded} = payload |> JSON.decode

    Process.send_after(self(),
      {:enqueue, job},
      compute_real_schedule_time(schedule_time)
    )

    Logger.info "Job #{decoded["id"]} scheduled"
  end

  defp get_job_by(schedule_time: schedule_time) do
    {:ok, result} = :redix
    |> Redix.command(["ZRANGE", "parallelixir:scheduled-jobs", "#{schedule_time}", "#{schedule_time}", "WITHSCORES"])

    result |> Enum.take(2)
  end

  defp enqueue(job) do
    [payload, schedule_time] = job

    {:ok, decoded} = payload |> JSON.decode

    queue = decoded["queue"]

    {:ok, notification} = %{message: "New job enqueued"} |> JSON.encode

    :redix
    |> Redix.transaction_pipeline([
      ["ZREMRANGEBYSCORE", "parallelixir:scheduled-jobs", schedule_time, schedule_time],
      ["RPUSH", queue, payload],
      ["PUBLISH", "parallelixir:notifications", notification]
    ])

    Logger.info "Job #{decoded["id"]} enqueued"
  end

  defp compute_real_schedule_time(schedule_time) do
    unix_time = DateTime.utc_now() |> DateTime.to_unix
    result    = String.to_integer(schedule_time) - (unix_time * 1000)

    case result do
      time when time < 0 -> 0
      time -> time
    end
  end
end

