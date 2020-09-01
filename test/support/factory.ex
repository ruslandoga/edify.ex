defmodule E.Factory do
  use ExMachina.Ecto, repo: E.Repo

  def group_session_factory do
    %E.GroupSessions.GroupSession{}
  end

  def in_seconds(seconds, from \\ DateTime.utc_now()) do
    DateTime.add(from, seconds)
  end

  def in_minutes(minutes, from \\ DateTime.utc_now()) do
    in_seconds(minutes * 60, from)
  end

  def in_hours(hours, from \\ DateTime.utc_now()) do
    in_minutes(hours * 60, from)
  end
end
