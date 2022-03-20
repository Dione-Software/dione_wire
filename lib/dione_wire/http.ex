defmodule MyRouter do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/who-am-i" do
    # GenServer.cast(MyAccessCounter, :increment)
    MyRouter.AccessConn.conn_info_to_db(conn)
    AccessesCounter.increment()
    send_resp(conn, 200, "you are here")
  end

  get "/location" do
    MyRouter.AccessConn.conn_info_to_db(conn)
    AccessesCounter.increment()
    {longitude, latitude} = DioneConfig.Provider.location
    send_resp(conn, 200, "Longitude => #{longitude} Latitude => #{latitude}\n")
  end

  get "/counter" do
    # counter = GenServer.call(MyAccessCounter, :current)
    MyRouter.AccessConn.conn_info_to_db(conn)
    counter = AccessesCounter.current()
    send_resp(conn, 200, "Current count => #{counter}")
  end

  get "/teapot" do
    send_resp(conn, 418, "I'm a teapot")
  end

  get "/logs" do
    MyRouter.AccessConn.conn_info_to_db(conn)

    rows = DioneWire.JsonRows.init()
    json_map = DioneWire.Schema
      |> DioneWire.Repo.all
      |> Enum.map(fn x -> DioneWire.JsonRow.from_json(x) end)
      |> DioneWire.JsonRows.add_rows(rows)
      |> Map.get(:rows)

    string = Poison.encode!(json_map)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, string)
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end

defmodule MyRouter.AccessConn do
  def extract_ip(conn) do
    conn.remote_ip
  end

  def ip_to_string({a, b, c, d}) do
    "#{a}.#{b}.#{c}.#{d}"
  end

  def ip_to_string({a, b, c, d, e, f, g, h}) do
    "#{a}:#{b}:#{c}:#{d}:#{e}:#{f}:#{g}:#{h}"
  end

  def conn_info_to_db(conn) do
    ip_string = MyRouter.AccessConn.extract_ip(conn)
      |> MyRouter.AccessConn.ip_to_string()
    protocol = "http"
    url = "http://" <> conn.host <> conn.request_path
    DioneWire.Schema.insert_connection(ip_string, protocol, url)
  end
end
