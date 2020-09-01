defmodule EWeb.GroupSessionController do
  use EWeb, :controller
  alias E.GroupSessions
  alias GroupSessions.GroupSession

  def show(conn, %{"slug" => slug}) do
    %GroupSession{} = group_session = GroupSessions.get_or_create_group_session_for_slug(slug)
    render(conn, "show.json", group_session: group_session)
  end
end
