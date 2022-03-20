defmodule TcpAcceptor.Serve do
  def serve(socket) do
    socket
    |> read_line
    |> handle_socket_error_read(socket)
    |> remove_trailing_newline
    |> handle_request
    |> write_line(socket)
    |> handle_socket_error_write(socket)
    serve(socket)
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp write_line(data, socket) do
    :gen_tcp.send(socket, data)
  end

  defp handle_socket_error_read({:ok, data}, _) do data end

  defp handle_socket_error_read({:error, :closed}, socket) do
    handle_shutdown(socket)
  end

  defp handle_socket_error_write(:ok, _) do
    IO.puts("Write was successfull")
  end

  defp handle_socket_error_write({:error, :closed}, socket) do
    handle_shutdown(socket)
  end

  defp handle_shutdown(socket) do
    IO.puts("Connection was closed")
    :gen_tcp.close(socket)
    exit(:shutdown)
  end

  defp handle_request("who-am-i") do
    IO.puts("Asked who am i")
    AccessesCounter.increment()
    "Asked who am i\n"
  end

  defp handle_request("current") do
    count = AccessesCounter.current
    "Count => #{count}\n"
  end

  defp handle_request(data) do
    IO.puts("Can't interpret input => #{data}")
    "Can't interpret input => #{data}\n"
  end

  defp remove_trailing_newline(data) do
    String.replace_trailing(data, "\n", "")
  end
end
