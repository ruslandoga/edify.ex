defmodule EWeb.SearchChannel do
  use EWeb, :channel
  alias E.GroupSessions
  # TODO test

  @impl true
  def join("search", _params, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in("search", %{"query" => query}, socket) do
    group_sessions = GroupSessions.search_group_sessions(query)
    resp = render_many(group_sessions, EWeb.GroupSessionView, "show.json")
    {:reply, {:ok, %{"group_sessions" => resp}}, socket}
  end
end
