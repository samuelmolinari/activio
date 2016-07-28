use Mix.Config

config :activio, :websocket_client, FakeWebsocketClient
config :activio, Activio.Bot, Activio.FakeBot
config :activio, :token, "token"
