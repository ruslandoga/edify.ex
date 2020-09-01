defmodule EWeb.GroupSessionChannel do
  use EWeb, :channel
  alias E.GroupSessions
  alias EWeb.{GroupSessionView, ErrorView}

  @impl true
  def join("group_session:" <> slug, _params, socket) do
    {:ok, assign(socket, slug: slug)}
  end

  @impl true
  def handle_in("update", %{"group_session" => params}, socket) do
    case GroupSessions.update_group_session_by_slug(socket.assigns.slug, params) do
      {:ok, group_session} ->
        broadcast_payload = render(GroupSessionView, "show.json", group_session: group_session)
        broadcast!(socket, "update", broadcast_payload)
        {:reply, :ok, socket}

      {:error, changeset} ->
        {:reply, {:error, render(ErrorView, "changeset.json", changeset: changeset)}, socket}
    end
  end
end
