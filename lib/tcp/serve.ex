defmodule TcpAcceptor.Serve do
  def serve(socket) do

    socket
    |> read_line
    |> handle_socket_error_read(socket)
    |> remove_trailing_newline
    |> handle_request
    |> extract_info(socket)
    |> write_line(socket)
    |> handle_socket_error_write(socket)
    serve(socket)
  end

  defp address(socket) do
    {:ok, {address, port}} = :inet.peername(socket)
    {address, port}
  end

  defp host_address(socket) do
    {:ok, {address, port}} = :inet.sockname(socket)
    {address, port}
  end

  defp address_to_string({{a, b, c, d}, port}) do
    "#{a}:#{b}:#{c}:#{d}:#{port}"
  end

  defp address_to_string({{a, b, c, d, e, f, g, h}, port}) do
    "#{a}:#{b}:#{c}:#{d}:#{e}:#{f}:#{g}:#{h}:#{port}"
  end

  defp extract_info({data, request_type}, socket) do
    address_string = address(socket) |> address_to_string()
    protocol = "tcp"
    request_type_string = Atom.to_string(request_type)
    host_address_string = host_address(socket) |> address_to_string()
    url = "tcp://" <> host_address_string <> "/" <> request_type_string
    DioneWire.Schema.insert_connection(address_string, protocol, url)
    data
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

  defp handle_socket_error_write(:ok, _) do  end

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
    {"Asked who am i\n", :whoami}
  end

  defp handle_request("current") do
    count = AccessesCounter.current
    {"Count => #{count}\n", :current}
  end

  defp handle_request("location") do
    {longitude, latitude} = DioneConfig.Provider.location
    {"Longitude => #{longitude} Latitude => #{latitude}\n", :location}
  end

  defp handle_request(data) do
    IO.puts("Can't interpret input => #{data}")
    "Can't interpret input => #{data}\n"
  end

  defp remove_trailing_newline(data) do
    String.replace_trailing(data, "\n", "")
  end
end
