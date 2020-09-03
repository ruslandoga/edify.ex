defmodule EWeb.GroupSessionView do
  use EWeb, :view

  def render("show.json", %{group_session: group_session}) do
    %{
      slug: slug,
      topic: topic,
      scheduled_at: scheduled_at,
      description: description
    } = group_session

    %{
      "slug" => slug,
      "topic" => topic,
      "scheduled_at" => scheduled_at,
      "description" => description
    }
  end

  def render("index.json", %{group_sessions: group_sessions}) do
    %{"group_sessions" => render_many(group_sessions, __MODULE__, "show.json")}
  end
end
