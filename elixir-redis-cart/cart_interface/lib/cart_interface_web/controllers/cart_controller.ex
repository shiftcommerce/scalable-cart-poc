defmodule CartInterfaceWeb.CartController do

  use CartInterfaceWeb, :controller

  alias CartEngine.Cart

  def add(conn, %{"sku" => sku, "quantity" => quantity}) do
    cart_id = get_cart_id(conn) || new_cart()
    Cart.set_line_item(cart_id, sku, quantity)

    conn
    |> fetch_session()
    |> put_session("cart_id", cart_id)
    |> send_resp(201, "")
  end

  def show(conn, _params) do
    cart_id = get_cart_id(conn)
    cart = Cart.get(cart_id)
    json(conn, Enum.map(cart.line_items, fn({k, v}) -> %{sku: k, quantity: v} end))
  end

  def remove_item(conn, %{"sku" => sku}) do
    cart_id = get_cart_id(conn)
    Cart.delete_line_item(cart_id, sku)

    conn
    |> send_resp(200, "")
  end

  defp get_cart_id(conn) do
    conn
    |> fetch_session()
    |> get_session("cart_id")
  end

  defp new_cart() do
    {:ok, cart_id} = Cart.new()
    cart_id
  end
end