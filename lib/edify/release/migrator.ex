defmodule E.Release.Migrator do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(run_migrations?: run_migrations?) do
    if run_migrations?, do: E.Release.migrate()
    :ignore
  end
end
