defmodule EWeb.GroupSessionControllerTest do
  use EWeb.ConnCase, async: true
  alias E.GroupSessions

  describe "GET /api/group_sessions/:slug" do
    test "it works", %{conn: conn} do
      # creates a new room since it doesn't yet exist
      #  get
      assert %{
               "description" => nil,
               "scheduled_at" => _,
               "slug" => "some-slug",
               "topic" => "Some slug"
             } =
               conn
               |> get("/api/group_sessions/some-slug")
               |> json_response(200)

      assert %{
               "description" => nil,
               "scheduled_at" => _,
               "slug" => "some-slug",
               "topic" => "Some slug"
             } =
               conn
               |> get("/api/group_sessions/some-slug")
               |> json_response(200)

      assert {:ok, _} =
               GroupSessions.create_group_session(%{
                 slug: "some-other-slug",
                 scheduled_at: ~U[2021-01-01 20:00:00Z],
                 topic: "Some other topic"
               })

      assert conn
             |> get("/api/group_sessions/some-other-slug")
             |> json_response(200) == %{
               "description" => nil,
               "scheduled_at" => "2021-01-01T20:00:00Z",
               "slug" => "some-other-slug",
               "topic" => "Some other topic"
             }
    end
  end
end
