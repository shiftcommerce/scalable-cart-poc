defmodule CartEngine.RedisClient do
  use GenServer

  alias CartEngine.Cart

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def save_cart(cart) do
    GenServer.call(__MODULE__, {:save_cart, cart})
  end

  def fetch_cart(cart_id) do
    GenServer.call(__MODULE__, {:fetch_cart, cart_id})
  end

  def init(_args) do
    {:ok, _conn} = Redix.start_link()
  end

  def handle_call({:save_cart, %Cart{cart_id: cart_id} = cart}, _from, conn) do
    {:ok, r} = Redix.command(conn, ["SET", cart_id, :erlang.term_to_binary(cart)])
    {:reply, nil, conn}
  end

  def handle_call({:fetch_cart, cart_id}, _from, conn) do
    {:ok, cart_binary} = Redix.command(conn, ["GET", cart_id])
    if cart_binary do
      {:reply, {:ok, :erlang.binary_to_term(cart_binary)}, conn}
    else
      {:reply, {:error, :cart_not_found}, conn}
    end
  end
end