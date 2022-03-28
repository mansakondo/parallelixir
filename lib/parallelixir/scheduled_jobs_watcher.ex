# defmodule Parallelixir.ScheduledJobsWatcher do
#   use GenServer
#
#   def start_link(options) do
#     GenServer.start_link(__MODULE__,
#       options,
#       name: __MODULE__
#     )
#   end
#
#   @impl true
#   def init(redis_config: redis_config) do
#     state = %{
#       redis_config: redis_config,
#       redis_connection: nil
#     }
#
#     {:ok, state, {:continue, :open_redis_connection}}
#   end
#
#   @impl true
#   def handle_continue(:open_redis_connection, state) do
#     {redis_config: redis_config} = state
#
#     {:ok, redis} = Redix.start_link(redis_config)
#
#     state |> Map.put(redis_connection: redis)
#
#     {:noreply, state, {:continue, :watch_scheduled_jobs}}
#   end
#
#   @impl true
#   def handle_continue(:watch_scheduled_jobs, state) do
#     %{redis_connection: redis} = state
#
#     available_jobs = get_available_jobs(redis)
#
#     enqueue_jobs(available_jobs, redis)
#
#     {:noreply, state, {:continue, :watch_scheduled_jobs}}
#   end
#
#   defp get_available_jobs(redis) do
#     redis
#     |> Redix.command(["ZRANGESCORE", "parallelixir:scheduled_jobs", "0", "0"])
#   end
#
#   defp enqueue_jobs(jobs, redis) do
#     jobs
#     |> Enum.each(fn (job) ->
#       enqueue_job(job, redis)
#     end)
#   end
#
#   defp enqueue_job(job, redis) do
#     {queue: queue} = job
#
#     redis
#     |> Redix.command(["RPUSH", queue, job])
#   end
# end
#
