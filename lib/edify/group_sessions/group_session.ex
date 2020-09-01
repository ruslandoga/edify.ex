defmodule E.GroupSessions.GroupSession do
  use Ecto.Schema
  import EWeb.Gettext
  import Ecto.Changeset

  @primary_key false
  schema "group_sessions" do
    field :slug, :string, primary_key: true
    field :topic, :string
    field :description, :string
    field :scheduled_at, :utc_datetime

    timestamps()
  end

  def changeset(session, attrs) do
    session
    |> cast(attrs, [:slug, :topic, :description, :scheduled_at])
    |> validate_required([:slug])
    |> unique_constraint(:slug, name: :group_sessions_pkey)
    |> validate_length(:description, max: 3000)
    |> validate_scheduled_in_future()

    # TODO validate slug format?
  end

  # TODO test
  defp validate_scheduled_in_future(changeset) do
    if new_scheduled_at = get_change(changeset, :scheduled_at) do
      case DateTime.compare(DateTime.utc_now(), new_scheduled_at) do
        :lt ->
          changeset

        _other ->
          add_error(changeset, :scheduled_at, dgettext("errors", "should be in the future"))
      end
    else
      changeset
    end
  end
end
