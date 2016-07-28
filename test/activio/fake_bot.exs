defmodule Activio.FakeBot do
  def start_link(_token, _client) do
    Agent.start_link fn -> [] end
  end
end
