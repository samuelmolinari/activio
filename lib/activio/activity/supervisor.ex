defmodule Activio.Activity.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
      worker(Activio.Activity.Worker, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def start_activity(type) do
    Supervisor.start_child(__MODULE__, [type])
  end
end
