defmodule ActivioTest do
  use ExUnit.Case

  doctest Activio

  setup_all do
    Code.require_file("test/activio/fake_bot.exs")
    Application.ensure_all_started(:activio)

    :ok
  end

  test "starts bot" do
    assert Process.whereis(Activio.Bot)
  end

  test "starts activity supervisor" do
    assert Process.whereis(Activio.Activity.Supervisor)
  end
end
