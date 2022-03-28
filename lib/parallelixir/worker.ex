defmodule Parallelixir.Worker do
  def perform(payload) do
    port = Port.open({:spawn, "bundle exec rake parallelixir:job:perform"}, [
      {:packet, 4},
      :nouse_stdio,
      :exit_status,
      :binary,
      {:parallelism, true}
    ])

    port
    |> Port.command(encode({:payload, payload}))
  end

  defp encode(data) do
    data |> :erlang.term_to_binary
  end
end
