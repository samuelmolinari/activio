defmodule Activio.Activity do
  defstruct type: nil, participants: %{}, teams_size: 1, teams: []

  def put_participant(activity, user) do
    %Activio.Activity{activity | participants: Map.put(activity.participants, user, true)}
  end

  def is_participant?(activity, user) do
    Map.has_key?(activity.participants, user)
  end

  def set_teams_size(activity, 0) do
    {:error, "Can't set teams size below 1"}
  end

  def set_teams_size(activity, size) do
    %Activio.Activity{activity | teams_size: size}
  end

  def shuffle_teams(activity) do
    teams_size = activity.teams_size

    teams = activity.participants
            |> Stream.filter(fn {_, bool} -> bool end)
            |> Stream.map(fn {user, _} -> user end)
            |> Enum.shuffle
            |> Enum.chunk(teams_size, 2, [])

    %Activio.Activity{activity | teams: teams}
  end
end
