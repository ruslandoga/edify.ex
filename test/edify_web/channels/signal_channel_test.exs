defmodule EWeb.SignalChannelTest do
  use EWeb.ChannelCase, async: true

  setup do
    uuid = "cf75d868-486a-48b6-a671-1633047d6b7f"

    {:ok, _, socket} =
      EWeb.UserSocket
      |> socket("user_socket:#{uuid}", %{id: uuid})
      |> subscribe_and_join(EWeb.SignalChannel, "signal:some-topic", %{username: "joe"})

    %{socket: socket}
  end

  test "username change is propagated to everyone and future users", %{socket: socket} do
    ref = push(socket, "username:set", %{"username" => "not-joe"})
    assert_reply ref, :ok, reply
    assert reply == %{}

    assert_broadcast "presence_diff",
                     %{
                       joins: %{
                         "cf75d868-486a-48b6-a671-1633047d6b7f" => %{
                           metas: [%{username: "not-joe"}]
                         }
                       },
                       leaves: %{
                         "cf75d868-486a-48b6-a671-1633047d6b7f" => %{
                           metas: [%{username: "joe"}]
                         }
                       }
                     }
  end

  test "signals travel", %{socket: socket} do
    ref =
      push(socket, "signal", %{
        "data" => "{some: 'data'}",
        "to" => "3152c939-d8e9-4fd3-bd38-a642b45338f6"
      })

    assert_reply ref, :ok, reply
    assert reply == %{}

    assert_broadcast "signal", %{
      "data" => "{some: 'data'}",
      "from" => "cf75d868-486a-48b6-a671-1633047d6b7f",
      "to" => "3152c939-d8e9-4fd3-bd38-a642b45338f6"
    }
  end
end
