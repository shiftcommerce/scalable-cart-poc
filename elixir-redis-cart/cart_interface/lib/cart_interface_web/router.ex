defmodule CartInterfaceWeb.Router do
  use CartInterfaceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CartInterfaceWeb do
    pipe_through :api

    post "/add_item_to_cart", CartController, :add
    get "/cart", CartController, :show
    post "/update_cart_item_quantity", CartController, :add
    post "/remove_item_from_cart", CartController, :remove_item
  end
end
