defmodule E.Release do
  @app :edify

  def migrate do
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end

  def mark_ready do
    Application.put_env(@app, :ready?, true)
  end

  @spec ready? :: boolean | nil
  def ready? do
    Application.get_env(@app, :ready?)
  end

  def to_bool(bool) do
    bool = bool |> String.downcase() |> String.trim()
    bool not in ["0", "false", "no"]
  end
end
