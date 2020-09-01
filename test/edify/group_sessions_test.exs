defmodule E.GroupSessionsTest do
  use E.DataCase, async: true
  alias E.GroupSessions
  alias GroupSessions.GroupSession

  describe "create_group_session_from_slug/1" do
    test "slugs are deduplicated" do
      assert %GroupSession{
               description: nil,
               scheduled_at: nil,
               slug: "slug",
               topic: "Slug"
             } = GroupSessions.create_group_session_from_slug("slug")

      assert %GroupSession{
               slug: "slug-1",
               topic: "Slug"
             } = GroupSessions.create_group_session_from_slug("slug")

      assert %GroupSession{
               description: nil,
               scheduled_at: nil,
               slug: "slug-2",
               topic: "Slug"
             } = GroupSessions.create_group_session_from_slug("slug")

      assert %GroupSession{
               description: nil,
               scheduled_at: nil,
               # TODO
               slug: "slug-1-1",
               topic: "Slug 1"
             } = GroupSessions.create_group_session_from_slug("slug-1")

      assert %GroupSession{
               description: nil,
               scheduled_at: nil,
               # TODO
               slug: "slug-1-2",
               topic: "Slug 1"
             } = GroupSessions.create_group_session_from_slug("slug-1")

      assert %GroupSession{
               description: nil,
               scheduled_at: nil,
               slug: "slug-2-1",
               topic: "Slug 2"
             } = GroupSessions.create_group_session_from_slug("slug-2")

      assert %GroupSession{
               description: nil,
               scheduled_at: nil,
               slug: "other-slug",
               topic: "Other slug"
             } = GroupSessions.create_group_session_from_slug("other-slug")

      assert %GroupSession{
               description: nil,
               scheduled_at: nil,
               # TODO?
               slug: "other-slug-",
               topic: "Other slug"
             } = GroupSessions.create_group_session_from_slug("other-slug-")

      assert %GroupSession{
               description: nil,
               scheduled_at: nil,
               # TODO
               slug: "other-slug--1",
               topic: "Other slug"
             } = GroupSessions.create_group_session_from_slug("other-slug-")
    end
  end

  describe "search_group_sessions/1" do
    test "with no group sessions" do
      assert [] == GroupSessions.search_group_sessions("")
      assert [] == GroupSessions.search_group_sessions("something")
    end

    test "only matches returned" do
      assert {:ok, _} =
               GroupSessions.create_group_session(%{
                 slug: "some-group-session",
                 topic: "Some group session",
                 scheduled_at: in_minutes(10)
               })

      assert [] == GroupSessions.search_group_sessions("some")
      assert [%{slug: "some-group-session"}] = GroupSessions.search_group_sessions("group")
      assert [%{slug: "some-group-session"}] = GroupSessions.search_group_sessions("session")
      assert [] == GroupSessions.search_group_sessions("nothing")
      assert [] == GroupSessions.search_group_sessions("so")

      assert {:ok, _} =
               GroupSessions.create_group_session(%{
                 slug: "nothing-alike",
                 topic: "Nothing alike",
                 scheduled_at: in_minutes(10)
               })

      assert [%{slug: "some-group-session"}] = GroupSessions.search_group_sessions("group")
      assert [%{slug: "some-group-session"}] = GroupSessions.search_group_sessions("session")
      assert [%{slug: "nothing-alike"}] = GroupSessions.search_group_sessions("nothing")
    end

    test "upcoming session (in 100 hours) is returned" do
      assert {:ok, _} =
               GroupSessions.create_group_session(%{
                 slug: "some-group-session",
                 topic: "Some group session",
                 scheduled_at: in_hours(100)
               })

      assert [%{slug: "some-group-session"}] = GroupSessions.search_group_sessions("session")
    end

    test "hour-old session is returned" do
      insert(:group_session,
        slug: "some-group-session",
        topic: "Some group session",
        scheduled_at: in_minutes(-59)
      )

      assert [%{slug: "some-group-session"}] = GroupSessions.search_group_sessions("session")
    end

    test "two hours old session is not returned" do
      insert(:group_session,
        slug: "some-group-session",
        topic: "Some group session",
        scheduled_at: in_hours(-2)
      )

      assert [] == GroupSessions.search_group_sessions("session")
    end
  end

  describe "get_or_create_group_session_for_slug/1" do
    test "get" do
      assert {:ok, _} =
               GroupSessions.create_group_session(%{
                 slug: "some-group-session",
                 topic: "Some group session"
               })

      assert %GroupSession{slug: "some-group-session", topic: "Some group session"} =
               GroupSessions.get_or_create_group_session_for_slug("some-group-session")
    end

    test "create" do
      assert %GroupSession{
               slug: "some-group-session",
               topic: "Some group session",
               scheduled_at: nil,
               description: nil
             } = GroupSessions.get_or_create_group_session_for_slug("some-group-session")
    end
  end
end
