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
    |> ensure_scheduled()
    |> ensure_has_slug()
    |> unique_constraint(:slug, name: :group_sessions_pkey)
    |> validate_length(:description, max: 3000)
    |> validate_scheduled_in_future()
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

  # TODO test
  defp ensure_scheduled(changeset) do
    scheduled_at =
      if scheduled_at = get_field(changeset, :scheduled_at) do
        scheduled_at
      else
        # schedule in 15 minutes
        DateTime.add(DateTime.utc_now(), 750)
      end

    put_change(changeset, :scheduled_at, DateTime.truncate(scheduled_at, :second))
  end

  # TODO test
  defp ensure_has_slug(changeset) do
    if get_field(changeset, :slug) do
      changeset
    else
      topic = get_change(changeset, :topic) || ""
      scheduled_at = get_change(changeset, :scheduled_at)
      %DateTime{year: year, month: month, day: day, hour: hour, minute: minute} = scheduled_at
      slug = "#{slugify(topic)}-#{year}-#{month}-#{day}-#{hour}-#{minute}"
      put_change(changeset, :slug, slug)
    end
  end

  defp slugify(topic) do
    String.split(topic)
    |> Enum.map(fn segment -> String.downcase(segment) end)
    |> Enum.join("-")
  end
end
