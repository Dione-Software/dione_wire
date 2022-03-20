defmodule MyRouter do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/who-am-i" do
    # GenServer.cast(MyAccessCounter, :increment)
    AccessesCounter.increment()
    send_resp(conn, 200, "you are here")
  end

  get "/location" do
    AccessesCounter.increment()
    {longitude, latitude} = DioneConfig.Provider.location
    send_resp(conn, 200, "Longitude => #{longitude} Latitude => #{latitude}\n")
  end

  get "/counter" do
    # counter = GenServer.call(MyAccessCounter, :current)
    counter = AccessesCounter.current()
    send_resp(conn, 200, "Current count => #{counter}")
  end

  get "/hello" do
    send_resp(conn, 200, "world")
  end

  get "/teapot" do
    send_resp(conn, 418, "I'm a teapot")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
