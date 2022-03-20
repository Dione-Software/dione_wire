defmodule DioneWire.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: DioneWire.Worker.start_link(arg)
      # {DioneWire.Worker, arg}
      {AccessesCounter, 0},
      {Plug.Cowboy, scheme: :http, plug: MyRouter, options: [port: 4001]},
      {Task.Supervisor, name: TcpAcceptor.ClientSupervisor},
      {Task, fn -> TcpAcceptor.Acceptor.accept(4040) end}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DioneWire.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
