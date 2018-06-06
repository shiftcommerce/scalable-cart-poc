defmodule CartEngine.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: CartEngine.Worker.start_link(arg)
      # {CartEngine.Worker, arg},
      {Registry, keys: :unique, name: :cart_registry},
      CartEngine.RedisClient,
      {DynamicSupervisor, strategy: :one_for_one, name: CartEngine.CartSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CartEngine.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
