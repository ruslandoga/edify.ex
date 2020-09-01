defmodule EWeb.SignalChannel do
  use EWeb, :channel

  @impl true
  def join("signal:" <> _slug, %{"username" => username}, socket) do
    send(self(), :after_join)
    {:ok, %{"id" => socket.assigns.id}, assign(socket, username: username)}
  end

  @impl true
  def handle_in("signal", %{"data" => _data, "to" => _to} = payload, socket) do
    # TODO open separate channel for from-to
    broadcast_from!(socket, "signal", Map.put(payload, "from", socket.assigns.id))
    {:reply, :ok, socket}
  end

  def handle_in("username:set", %{"username" => username}, socket) do
    %{id: id} = socket.assigns
    {:ok, _} = Presence.update(socket, id, %{username: username})
    {:reply, :ok, assign(socket, username: username)}
  end

  @impl true
  def handle_info(:after_join, socket) do
    %{id: id, username: username} = socket.assigns
    {:ok, _} = Presence.track(socket, id, %{username: username})
    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end
end
