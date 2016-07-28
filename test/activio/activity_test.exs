defmodule Activio.ActivityTest do
  use ExUnit.Case
  alias Activio.Activity

  doctest Activity

  setup do
    activity = %Activity{}

    activity_with_participants = activity
               |> Activity.put_participant("user1")
               |> Activity.put_participant("user2")
               |> Activity.put_participant("user3")

    {:ok, [activity: activity, activity_with_participants: activity_with_participants]}
  end

  test "default state", %{activity: activity} do
    assert activity.type == nil
    assert activity.participants == %{}
    assert activity.teams_size == 1
    assert activity.teams == []
  end

  test "put_participant", %{activity: activity} do
    assert Activity.put_participant(activity, "user1").participants == %{"user1" => true}
  end

  test "is_participant?", %{activity: activity} do
    refute Activity.is_participant?(activity, "user1")
    activity = Activity.put_participant(activity, "user1")
    assert Activity.is_participant?(activity, "user1")
  end

  test "set_teams_size", %{activity: activity} do
    activity = Activity.set_teams_size(activity, 99)
    assert activity.teams_size == 99
  end

  test "set_teams_size less than 1", %{activity: activity} do
    assert {:error, _} = Activity.set_teams_size(activity, 0)
  end

  test "shuffle_teams, teams of 1", %{activity_with_participants: activity} do
    assert [[_], [_], [_]] = Activity.shuffle_teams(activity).teams
  end

  test "shuffle_teams, teams with left over", %{activity_with_participants: activity} do
    activity = Activity.set_teams_size(activity, 2)

    assert [[_, _], [_]] = Activity.shuffle_teams(activity).teams
  end

  test "shuffle_teams, teams of greater size than there are participants", %{activity_with_participants: activity} do
    activity = Activity.set_teams_size(activity, 11)

    assert [[_, _, _]] = Activity.shuffle_teams(activity).teams
  end
end
