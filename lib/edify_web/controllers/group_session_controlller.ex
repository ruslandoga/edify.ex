defmodule EWeb.GroupSessionController do
  use EWeb, :controller
  alias E.GroupSessions
  alias GroupSessions.GroupSession

  def show(conn, %{"slug" => slug}) do
    %GroupSession{} = group_session = GroupSessions.get_or_create_group_session_for_slug(slug)
    render(conn, "show.json", group_session: group_session)
  end

  # TODO test
  def index(conn, %{"q" => query}) do
    group_sessions = GroupSessions.search_group_sessions(query)
    render(conn, "index.json", group_sessions: group_sessions)
  end

  # TODO test
  def create(conn, %{"group_session" => params}) do
    {:ok, group_session} = GroupSessions.create_group_session(params)
    render(conn, "show.json", group_session: group_session)
  end
end
