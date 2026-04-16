defmodule BazarWeb.ProductLive.Index do
  use BazarWeb, :live_view

  alias Bazar.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Products
        <:actions>
          <.button variant="primary" navigate={~p"/products/new"}>
            <.icon name="hero-plus" /> New Product
          </.button>
        </:actions>
      </.header>

      <.table
        id="products"
        rows={@streams.products}
        row_click={fn {_id, product} -> JS.navigate(~p"/products/#{product}") end}
      >
        <:col :let={{_id, product}} label="Image url">{product.image_url}</:col>
        <:col :let={{_id, product}} label="Ludopedia link">{product.ludopedia_link}</:col>
        <:col :let={{_id, product}} label="Description">{product.description}</:col>
        <:col :let={{_id, product}} label="Sale reason">{product.sale_reason}</:col>
        <:col :let={{_id, product}} label="Condition">{product.condition}</:col>
        <:col :let={{_id, product}} label="Recommendation">{product.recommendation}</:col>
        <:col :let={{_id, product}} label="Tags">{product.tags}</:col>
        <:col :let={{_id, product}} label="Price">{product.price}</:col>
        <:col :let={{_id, product}} label="Trade policy">{product.trade_policy}</:col>
        <:action :let={{_id, product}}>
          <div class="sr-only">
            <.link navigate={~p"/products/#{product}"}>Show</.link>
          </div>
          <.link navigate={~p"/products/#{product}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, product}}>
          <.link
            phx-click={JS.push("delete", value: %{id: product.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Catalog.subscribe_products(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Products")
     |> stream(:products, list_products(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product = Catalog.get_product!(socket.assigns.current_scope, id)
    {:ok, _} = Catalog.delete_product(socket.assigns.current_scope, product)

    {:noreply, stream_delete(socket, :products, product)}
  end

  @impl true
  def handle_info({type, %Bazar.Catalog.Product{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :products, list_products(socket.assigns.current_scope), reset: true)}
  end

  defp list_products(current_scope) do
    Catalog.list_products(current_scope)
  end
end
