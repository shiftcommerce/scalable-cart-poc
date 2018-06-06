defmodule CartEngine.Cart do
  defstruct [:cart_id, line_items: %{}]

  alias CartEngine.{Cart, RedisClient, CartSupervisor}

  use GenServer

  def new() do
    cart_id = UUID.uuid4()
    {:ok, _pid} = start_supervised(%Cart{cart_id: cart_id})
    {:ok, cart_id}
  end

  def start_link(cart) do
    GenServer.start_link(__MODULE__, cart, name: via_tuple(cart.cart_id))
  end

  def get(cart_id) do
    cart_id
    |> prepare_cart()
    |> GenServer.call(:get)
  end

  def set_line_item(cart_id, sku, quantity) do
    cart_id
    |> prepare_cart()
    |> GenServer.call({:set_line_item, sku, quantity})
  end

  def delete_line_item(cart_id, sku) do
    cart_id
    |> prepare_cart()
    |> GenServer.call({:delete_line_item, sku})
  end

  # IMPLEMENTATION

  def init(cart_id) do
    {:ok, cart_id}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:set_line_item, sku, quantity}, _from, state) do
    if !Map.has_key?(state.line_items, sku) or quantity > Map.fetch!(state.line_items, sku) do
      Process.sleep(50)
    end

    state = %{state | line_items: Map.put(state.line_items, sku, quantity)}
    RedisClient.save_cart(state)
    {:reply, state, state}
  end

  def handle_call({:delete_line_item, sku}, _from, state) do
    state = %{state | line_items: Map.drop(state.line_items, [sku])}
    RedisClient.save_cart(state)
    {:reply, state, state}
  end

  # HELPERS

  def start_supervised(cart) do
    DynamicSupervisor.start_child(
      CartSupervisor,
      Supervisor.child_spec({__MODULE__, cart}, id: cart.cart_id)
    )
  end

  def via_tuple(cart_id) do
    {:via, Registry, {:cart_registry, cart_id}}
  end

  defp prepare_cart(cart_id) do
    cart_id
    |> ensure_alive()
    |> via_tuple()
  end

  defp ensure_alive(cart_id) do
    if cart_unregistered?(cart_id) or cart_dead?(cart_id) do
      {:ok, _pid} = restore(cart_id)
    end
    cart_id
  end

  defp restore(cart_id) do
    with {:ok, cart} <- RedisClient.fetch_cart(cart_id)
    do
      start_supervised(cart)
    else
      {:error, :cart_not_found} ->
        start_supervised(%Cart{cart_id: cart_id})
    end
  end

  defp cart_unregistered?(cart_id),
    do: Enum.empty?(Registry.lookup(:cart_registry, cart_id))

  defp cart_dead?(cart_id) do
    [{cart_pid, _}] = Registry.lookup(:cart_registry, cart_id)
    !Process.alive?(cart_pid)
  end
end