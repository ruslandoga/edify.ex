defmodule EWeb.GroupSessionView do
  use EWeb, :view
  alias E.GroupSessions.GroupSession

  def render("show.json", %{group_session: group_session}) do
    %GroupSession{slug: slug, topic: topic, scheduled_at: scheduled_at, description: description} =
      group_session

    %{
      "slug" => slug,
      "topic" => topic,
      "scheduled_at" => scheduled_at,
      "description" => description
    }
  end
end
