defmodule DioneWire.Schema do
  use Ecto.Schema

  schema "connection" do
    field :address
  end
end
