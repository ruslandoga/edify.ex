defmodule E.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    config = config()
    setup_repo(config)

    children = [
      # Start the Ecto repository
      E.Repo,
      # Start the Telemetry supervisor
      EWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: E.PubSub},
      # Start the Endpoint (http/https)
      {EWeb.Endpoint, endpoint_config(config)}
      # Start a worker by calling: E.Worker.start_link(arg)
      # {E.Worker, arg}
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
          {:db_poolsize, "POOL_SIZE", default: 10, map: &String.to_integer/1},
          {:http_port, "HTTP_PORT", map: &String.to_integer/1},
          {:url_host, "URL_HOST"},
          {:secret_key_base, "SECRET_KEY_BASE"}
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
    opts = [url: config.db_url, pool_size: config.pool_size]
    before = Application.get_env(:edify, E.Repo)
    Application.put_env(:edify, E.Repo, Keyword.merge(before, opts))
  end
end
