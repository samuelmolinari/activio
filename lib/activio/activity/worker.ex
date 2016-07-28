defmodule Activio.Activity.Worker do
  use GenServer

  def start_link(type) do
    GenServer.start_link(__MODULE__, {:ok, type}, name: {:global, name(type)})
  end

  def init({:ok, type}) do
    {:ok, %Activio.Activity{type: type}}
  end

  def find(type) do
    :global.whereis_name(name(type))
  end

  def name(type) do
    {:activity, type}
  end

  def put_participant(server, user) do
    GenServer.cast(server, {:add_participant, user})
  end

  def shuffle_teams(server) do
    GenServer.call(server, {:shuffle_teams})
  end

  def set_teams_size(server, size) do
    GenServer.cast(server, {:set_teams_size, size})
  end

  def is_participant?(server, user) do
    GenServer.call(server, {:is_paricipant, user})
  end

  def handle_cast({:add_participant, user}, activity) do
    {:noreply, Activio.Activity.put_participant(activity, user)}
  end

  def handle_cast({:set_teams_size, size}, activity) do
    {:noreply, Activio.Activity.set_teams_size(activity, size)}
  end

  def handle_call({:is_paricipant, user}, _, activity) do
    {:reply, Activio.Activity.is_participant?(activity, user), activity}
  end

  def handle_call({:shuffle_teams}, _, activity) do
    activity = activity |> Activio.Activity.shuffle_teams
    {:reply, activity.teams, activity}
  end
end
