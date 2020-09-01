defmodule EWeb.GroupSessionViewTest do
  use EWeb.ConnCase, async: true
  alias EWeb.GroupSessionView
  alias E.GroupSessions.GroupSession

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders show.json" do
    group_session = %GroupSession{
      slug: "some-slug",
      topic: "some topic",
      description: "some description",
      scheduled_at: ~U[2020-01-01 20:00:00Z]
    }

    assert render(GroupSessionView, "show.json", group_session: group_session) == %{
             "description" => "some description",
             "scheduled_at" => ~U[2020-01-01 20:00:00Z],
             "slug" => "some-slug",
             "topic" => "some topic"
           }
  end
end
