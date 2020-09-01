defmodule EWeb.GroupSessionChannelTest do
  use EWeb.ChannelCase, async: true
  alias E.GroupSessions

  setup do
    assert {:ok, _} =
             GroupSessions.create_group_session(%{
               slug: "some-slug",
               topic: "some topic",
               description: "some description"
             })

    {:ok, _, socket} =
      socket(EWeb.UserSocket)
      |> subscribe_and_join(EWeb.GroupSessionChannel, "group_session:some-slug")

    %{socket: socket}
  end

  describe "update" do
    test "with valid payload update is saved and broadcast", %{socket: socket} do
      ref = push(socket, "update", %{"group_session" => %{"topic" => "some other topic"}})
      assert_reply ref, :ok, _
      assert_broadcast "update", broadcast

      # TODO send diff?
      assert broadcast == %{
               "description" => "some description",
               "scheduled_at" => nil,
               "slug" => "some-slug",
               "topic" => "some other topic"
             }
    end

    test "with invalid payload, error is returned", %{socket: socket} do
      ref =
        push(socket, "update", %{"group_session" => %{"scheduled_at" => "2020-01-01T20:00:00Z"}})

      assert_reply ref, :error, reply
      assert reply == %{errors: %{detail: %{scheduled_at: ["should be in the future"]}}}
      refute_broadcast "update", _anything
    end
  end
end
