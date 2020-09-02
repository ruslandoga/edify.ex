defmodule E.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    config = config()
    setup_repo(config)

    children = [
      {Phoenix.PubSub, name: E.PubSub},
      EWeb.Presence,
      {EWeb.Endpoint, endpoint_config(config)},
      E.Repo,
      EWeb.Telemetry,
      {E.Release.Migrator, run_migrations?: config.run_migrations?}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: E.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    EWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def config do
    alias Vapor.Provider.{Dotenv, Env}

    providers = [
      %Dotenv{},
      %Env{
        bindings: [
          {:db_url, "DB_URL"},
          {:http_port, "HTTP_PORT", map: &String.to_integer/1},
          {:url_host, "URL_HOST"},
          {:secret_key_base, "SECRET_KEY_BASE"},
          {:run_migrations?, "RUN_MIGRATIONS", map: &E.Release.to_bool/1}
        ]
      }
    ]

    Vapor.load!(providers)
  end

  defp endpoint_config(config) do
    [
      http: [port: config.http_port, transport_options: [socket_opts: [:inet6]]],
      url: [scheme: "https", host: config.url_host, port: 443],
      secret_key_base: config.secret_key_base
    ]
  end

  defp setup_repo(config) do
    opts = [url: config.db_url]

    opts =
      if before = Application.get_env(:edify, E.Repo) do
        Keyword.merge(before, opts)
      else
        opts
      end

    Application.put_env(:edify, E.Repo, opts)
  end
end
