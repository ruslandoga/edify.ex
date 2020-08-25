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
          {:http_port, "HTTP_PORT"},
          {:url_host, "URL_HOST"}
        ]
      }
    ]

    Vapor.load!(providers)
  end

  defp endpoint_config(config) do
    [http: [port: config.http_port], url: [scheme: "https", host: config.url_host, port: 443]]
  end

  defp setup_repo(config) do
    opts = [url: config.db_url]
    before = Application.get_env(:edify, E.Repo)
    Application.put_env(:edify, E.Repo, Keyword.merge(before, opts))
  end
end
