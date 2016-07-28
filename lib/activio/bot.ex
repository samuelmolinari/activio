defmodule Activio.Bot do
  use Slack

  @websocket_client Application.get_env(:activio, :websocket_client)
  @bot Application.get_env(:activio, __MODULE__)

  def start_link do
    return = {:ok, server} = @bot.start_link(token, @websocket_client)
    Process.register(server, __MODULE__)
    return
  end

  def token do
    Application.get_env(:activio, :token)
  end

  def handle_connect(slack) do
    IO.puts "Connected as #{slack.me.name}"
  end

  def handle_message(message = %{type: "message", text: text}, slack) do
    bot = user(slack.me.id)

    [recipient | cmd] = text |> String.split(" ")
    cmd = cmd |> Enum.map(&String.downcase/1)

    if recipient == bot or recipient == bot <> ":" do
      [action | args] = cmd
      handle_cmd(action, args, message)
      |> send_message(message.channel, slack)
    end
  end

  def handle_message(_,_), do: :ok

  def handle_cmd("create", [activity | _], _) do
    case Activio.Activity.Supervisor.start_activity(activity) do
      {:ok, _} ->
        "*#{activity}* activity has been created!"
      {:error, {:already_started, _}} ->
        "*#{activity}* already exists."
    end
  end

  def handle_cmd("list", _, _) do
    activities = ["ping-pong", "foosball", "pool"]
    "List of activities: \n\n" <> Enum.join(activities, "\n")
  end

  def handle_cmd("join", [activity | _], %{user: user}) do
    case Activio.Activity.Worker.find(activity) do
      :undefined ->
        "Activity #{activity} does not exists"
      server ->
        Activio.Activity.Worker.put_participant(server, user)
        "#{user(user)} has joined *#{activity}*"
    end
  end

  def handle_cmd("add", ["me", "to", activity | _], message) do
    handle_cmd("join", [activity], message)
  end

  def handle_cmd("set", [activity, "teams", "size", "to", size | _], _) do
    case Activio.Activity.Worker.find(activity) do
      :undefined ->
        "Activity #{activity} does not exists"
      server ->
        {size, _} = Integer.parse(size)
        Activio.Activity.Worker.set_teams_size(server, size)
    end
  end

  def handle_cmd("shuffle", [activity, "teams" | _], _) do
    case Activio.Activity.Worker.find(activity) do
      :undefined ->
        "Activity #{activity} does not exists"
      server ->
        "#{activity} teams: \n\n"

        Activio.Activity.Worker.shuffle_teams(server)
        |> Enum.with_index(1)
        |> Enum.map(fn {team, index} ->
          "Team #{index}: #{team |> Enum.map(&Activio.Bot.user/1) |> Enum.join(", ")}"
        end)
        |> Enum.join("\n")
    end
  end

  def handle_cmd(_, _, _) do
    [response | _] = [
      "No comprendo amigo!",
      "Yeeaaaahhh right, I didn't quite get that."
    ] |> Enum.shuffle

    response
  end

  def handle_command(_) do
  end

  def user(id) do
    "<@#{id}>"
  end

  def handle_info({:message, text, channel}, slack) do
    IO.puts "Sending your message, captain!"

    send_message(text, channel, slack)

    {:ok}
  end

  def handle_info(_, _), do: :ok
end
