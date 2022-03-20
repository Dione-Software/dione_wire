defmodule TcpAcceptor.Acceptor do
  def accept(port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(TcpAcceptor.ClientSupervisor, fn -> TcpAcceptor.Serve.serve(client) end)
    :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end
end
