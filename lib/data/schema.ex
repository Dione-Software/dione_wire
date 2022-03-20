defmodule DioneWire.Schema do
  use Ecto.Schema

  schema "connection" do
    field :address
    field :protocol
    field :time, :utc_datetime_usec
    field :url, :string
  end

  def insert_connection(address, protocol, url) do
    date_time = DateTime.utc_now()
    %DioneWire.Schema{address: address, protocol: protocol, time: date_time, url: url}
    |> DioneWire.Repo.insert!()
  end
end

defmodule DioneWire.JsonRow do
  @derive [Poison.Encoder]
  defstruct [:address, :protocol, :time, :url]

  def from_json(schema) do
    address = Map.get(schema, :address)
    protocol = Map.get(schema, :protocol)
    time = Map.get(schema, :time)
    url = Map.get(schema, :url)
    %DioneWire.JsonRow{address: address, protocol: protocol, time: time, url: url}
  end
end

defmodule DioneWire.JsonRows do
  @derive [Poison.Encoder]
  defstruct [:rows]

  def init() do
    %DioneWire.JsonRows{rows: []}
  end

  def add_row(row, rows) do
    current_rows = Map.get(rows, :rows)
    new_rows = [row | current_rows]
    %DioneWire.JsonRows{rows: new_rows}
  end

  def add_rows([], ret) do
    ret
  end
  def add_rows(rows, ret) do
    [head | tail] = rows
    new_ret = add_row(head, ret)
    add_rows(tail, new_ret)
  end
end
