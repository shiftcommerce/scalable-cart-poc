defmodule CartEngineTest do
  use ExUnit.Case

  alias CartEngine.Cart

  setup do
    {:ok, cart_id} = Cart.new()
    %{cart_id: cart_id}
  end

  test "fetches the cart by id", %{cart_id: cart_id} do
    %Cart{} = Cart.get(cart_id)
  end

  test "adds a new line item", %{cart_id: cart_id} do
    Cart.set_line_item(cart_id, "SKU1", 2)
    cart = Cart.get(cart_id)

    assert length(Map.keys(cart.line_items)) == 1
    assert cart.line_items["SKU1"] == 2
  end

  test "overrides the line item quantity", %{cart_id: cart_id} do
    Cart.set_line_item(cart_id, "SKU1", 2)
    Cart.set_line_item(cart_id, "SKU1", 3)
    cart = Cart.get(cart_id)

    assert length(Map.keys(cart.line_items)) == 1
    assert cart.line_items["SKU1"] == 3
  end

  test "deletes the line item", %{cart_id: cart_id} do
    Cart.set_line_item(cart_id, "SKU1", 2)
    Cart.delete_line_item(cart_id, "SKU1")
    cart = Cart.get(cart_id)

    assert length(Map.keys(cart.line_items)) == 0
  end

  test "persists the state of a cart when a process terminates", %{cart_id: cart_id} do
    Cart.set_line_item(cart_id, "SKU1", 5)
    [{cart_pid, _value}] = Registry.lookup(:cart_registry, cart_id)

    Process.flag(:trap_exit, true)
    Process.exit(cart_pid, :normal)
    Registry.unregister(:cart_registry, Cart.via_tuple(cart_id))

    cart = Cart.get(cart_id)

    assert length(Map.keys(cart.line_items)) == 1
  end
end
