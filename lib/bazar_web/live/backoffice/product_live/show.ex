defmodule BazarWeb.Backoffice.ProductLive.Show do
  use BazarWeb, :live_view

  alias Bazar.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Product {@product.id}
        <:subtitle>This is a product record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/backoffice/products"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/backoffice/products/#{@product}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit product
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Image url">{@product.image_url}</:item>
        <:item title="Ludopedia link">{@product.ludopedia_link}</:item>
        <:item title="Description">{@product.description}</:item>
        <:item title="Sale reason">{@product.sale_reason}</:item>
        <:item title="Condition">{@product.condition}</:item>
        <:item title="Recommendation">{@product.recommendation}</:item>
        <:item title="Tags">{@product.tags}</:item>
        <:item title="Price">{@product.price}</:item>
        <:item title="Trade policy">{@product.trade_policy}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Catalog.subscribe_products(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Product")
     |> assign(:product, Catalog.get_product!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Bazar.Catalog.Product{id: id} = product},
        %{assigns: %{product: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :product, product)}
  end

  def handle_info(
        {:deleted, %Bazar.Catalog.Product{id: id}},
        %{assigns: %{product: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current product was deleted.")
     |> push_navigate(to: ~p"/backoffice/products")}
  end

  def handle_info({type, %Bazar.Catalog.Product{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
