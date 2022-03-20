defmodule DioneConfig.Provider do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, 0, name: MyConfigProvider)
  end

  def location do
    GenServer.call(MyConfigProvider, :location)
  end

  @impl true
  def init(_) do
    config = DioneConfig.Resolver.config()
    {:ok, config}
  end

  @impl true
  def handle_call(:location, _from, config) do
    loc = Map.get(config, :location)
    {:reply, loc, config}
  end
end
