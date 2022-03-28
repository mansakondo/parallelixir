defmodule Parallelixir.Server do
  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :loop, []},
    }
  end

  def loop do
    receive do
      {:EXIT, _from, :shutdown} -> loop()

      _ -> loop()
    after
      6000 -> loop()
    end
  end
end
