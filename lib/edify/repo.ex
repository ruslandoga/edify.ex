defmodule E.Repo do
  use Ecto.Repo,
    otp_app: :edify,
    adapter: Ecto.Adapters.Postgres
end
