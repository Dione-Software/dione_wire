defmodule AccessesCounter do
  use GenServer

  def start_link(num) do
    GenServer.start_link(__MODULE__, num, name: MyAccessCounter)
  end

  @impl true
  @spec init(integer) :: {:ok, integer}
  def init(counter) do
    {:ok, counter}
  end

  @impl true
  def handle_call(:current, _from, counter) do
    {:reply, counter, counter}
  end

  @impl true
  def handle_call(:increment_and_return, _from, counter) do
    new_counter = counter + 1
    {:reply, new_counter, new_counter}
  end

  @impl true
  def handle_call(:reset_and_return, _from, counter) do
    previous_value = counter
    {:reply, previous_value, 0}
  end

  @impl true
  def handle_cast(:increment, counter) do
    {:noreply, counter + 1}
  end

  @impl true
  def handle_cast(:reset, _counter) do
    {:noreply, 0}
  end

  def increment(pid) do
    GenServer.cast(pid, :increment)
  end

  def increment() do
    GenServer.cast(MyAccessCounter, :increment)
  end

  def current(pid) do
    GenServer.call(pid, :current)
  end

  def current() do
    GenServer.call(MyAccessCounter, :current)
  end
end
