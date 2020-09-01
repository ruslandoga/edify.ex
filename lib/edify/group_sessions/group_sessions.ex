defmodule E.GroupSessions do
  alias E.Repo
  alias E.GroupSessions.GroupSession

  alias Ecto.Multi
  import Ecto.Query

  def search_group_sessions(query) when is_binary(query) do
    GroupSession
    |> where([s], fragment("? % ?", s.slug, ^query) or fragment("? % ?", s.topic, ^query))
    |> where([s], fragment("? + interval '1 hour' >= now()", s.scheduled_at))
    |> order_by([s],
      desc:
        fragment("similarity(?, ?)", s.slug, ^query) +
          fragment("similarity(?, ?)", s.topic, ^query)
    )
    |> limit(10)
    |> select([s], map(s, [:slug, :topic, :description, :scheduled_at]))
    |> Repo.all()
  end

  def get_or_create_group_session_for_slug(slug) when is_binary(slug) do
    get_group_session(slug) || create_group_session_from_slug(slug)
  end

  def update_group_session_by_slug(slug, attrs) when is_binary(slug) do
    slug
    |> get_group_session!()
    |> update_group_session(attrs)
  end

  def update_group_session(%GroupSession{} = group_session, attrs) do
    group_session
    |> GroupSession.changeset(attrs)
    |> Repo.update()
  end

  defp get_group_session!(slug) do
    GroupSession
    |> where(slug: ^slug)
    |> Repo.one!()
  end

  defp get_group_session(slug) do
    GroupSession
    |> where(slug: ^slug)
    |> Repo.one()
  end

  defp get_slug(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.get_field(changeset, :slug) || raise "missing slug in changeset"
  end

  defp increment_slug(slug, _no_duplicates = nil), do: slug
  defp increment_slug(slug, _only_one_duplicate = 0), do: slug <> "-1"

  defp increment_slug(slug, prev_duplicate_id) do
    slug <> "-#{prev_duplicate_id + 1}"
  end

  # TODO overwrite old?
  def create_group_session_from_slug(slug) do
    {:ok, group_session} = create_group_session(%{slug: slug, topic: unsluggify(slug)})
    group_session
  end

  defp unsluggify(slug) do
    slug
    |> String.split("-", trim: true)
    |> case do
      [first | rest] -> Enum.join([String.capitalize(first) | rest], " ")
      _other -> nil
    end
  end

  # TODO optimize
  def create_group_session(attrs) when is_map(attrs) do
    changeset = GroupSession.changeset(%GroupSession{}, attrs)

    Multi.new()
    # TODO it's only optimistically unique
    # TODO -> Repo.insert(changeset, on_conflict: increment_slug(changeset))
    |> Multi.run(:fetch_unique_slug, fn _repo, _changes ->
      slug = get_slug(changeset)
      pattern = "^#{slug}-?(\\d*)?$"

      prev_duplicate_id =
        GroupSession
        |> where([s], fragment("? ~ ?", s.slug, ^pattern))
        |> order_by([s], desc: fragment("1"))
        |> limit(1)
        |> select(
          [s],
          fragment("('0' || unnest(regexp_matches(?, ?, 'g')))::integer", s.slug, ^pattern)
        )
        |> Repo.one()

      {:ok, increment_slug(slug, prev_duplicate_id)}
    end)
    |> Multi.insert(:group_session, fn %{fetch_unique_slug: slug} ->
      Ecto.Changeset.put_change(changeset, :slug, slug)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{group_session: group_session}} -> {:ok, group_session}
      {:error, :group_session, %Ecto.Changeset{} = changeset, _changes} -> {:error, changeset}
    end
  end
end
