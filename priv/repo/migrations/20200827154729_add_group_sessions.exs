defmodule E.Repo.Migrations.AddGroupSessions do
  use Ecto.Migration

  def up do
    create table(:group_sessions, primary_key: false) do
      add :slug, :string, primary_key: true
      add :topic, :text
      add :description, :text
      add :scheduled_at, :timestamptz

      timestamps()
    end

    # TODO check if used in search
    execute """
    create index group_sessions_topic_index
    on group_sessions
    using gin (topic gin_trgm_ops)
    """
  end

  def down do
    drop table(:group_sessions)
  end
end
