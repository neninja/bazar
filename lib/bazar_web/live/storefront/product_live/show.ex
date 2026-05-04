defmodule BazarWeb.Storefront.ProductLive.Show do
  use BazarWeb, :live_view

  alias Bazar.Catalog
  alias BazarWeb.Presence

  @lobby_topic "storefront:lobby"

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.storefront
      flash={@flash}
      current_scope={@current_scope}
      viewer_count={@viewer_count}
      viewer_label="na loja"
    >
      <div class="min-h-screen bg-base-200 pb-8">
        <div :if={@product} class="max-w-xl mx-auto">
          <figure :if={@product.image_url && @product.image_url != ""}>
            <img
              src={@product.image_url}
              class="w-full aspect-square object-cover"
              alt={@product.description}
            />
          </figure>

          <div class="px-4 pt-5 space-y-4">
            <div>
              <p class="text-3xl font-bold text-primary">{format_price(@product.price)}</p>
              <div :if={@product.tags not in [nil, []]} class="flex flex-wrap gap-1.5 mt-2">
                <span :for={tag <- @product.tags} class="badge badge-outline badge-sm">{tag}</span>
              </div>
            </div>

            <div class="divider my-0"></div>

            <div class="space-y-2 text-sm">
              <div :if={@product.condition && @product.condition != ""}>
                <span class="font-semibold text-base-content/70">Condição:</span>
                <span class="ml-1">{@product.condition}</span>
              </div>
              <div>
                <span class="font-semibold text-base-content/70">Troca:</span>
                <span class="ml-1">{@product.trade_policy}</span>
              </div>
            </div>

            <div class="divider my-0"></div>

            <div>
              <p class="font-semibold text-base-content/70 text-sm mb-1">Descrição</p>
              <p class="text-sm leading-relaxed">{@product.description}</p>
            </div>

            <div :if={@product.sale_reason && @product.sale_reason != ""}>
              <p class="font-semibold text-base-content/70 text-sm mb-1">Por que estou vendendo</p>
              <p class="text-sm leading-relaxed">{@product.sale_reason}</p>
            </div>

            <div :if={@product.recommendation && @product.recommendation != ""}>
              <p class="font-semibold text-base-content/70 text-sm mb-1">Recomendo para</p>
              <p class="text-sm leading-relaxed">{@product.recommendation}</p>
            </div>

            <div :if={@product.ludopedia_link && @product.ludopedia_link != ""}>
              <a
                href={@product.ludopedia_link}
                target="_blank"
                rel="noopener noreferrer"
                class="btn btn-outline btn-sm gap-2 w-full"
              >
                <.icon name="hero-arrow-top-right-on-square" class="size-4" /> Ver no Ludopedia
              </a>
            </div>
          </div>
        </div>
      </div>
    </Layouts.storefront>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, viewer_count: 0, product: nil, product_id: nil)}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    product_topic = "storefront:product:#{id}"

    if connected?(socket) do
      {:ok, _} = Presence.track(self(), @lobby_topic, socket.id, %{})
      {:ok, _} = Presence.track(self(), product_topic, socket.id, %{})
      BazarWeb.Endpoint.subscribe(@lobby_topic)
      BazarWeb.Endpoint.subscribe(product_topic)
    end

    case Catalog.get_store_product(id) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Produto não encontrado.")
         |> push_navigate(to: ~p"/")}

      product ->
        {:noreply,
         assign(socket,
           page_title: "Produto",
           product: product,
           product_id: id,
           viewer_count: count_viewers(product_topic)
         )}
    end
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", topic: @lobby_topic}, socket) do
    {:noreply, socket}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff"}, socket) do
    case socket.assigns.product_id do
      nil ->
        {:noreply, socket}

      id ->
        {:noreply, assign(socket, :viewer_count, count_viewers("storefront:product:#{id}"))}
    end
  end

  defp count_viewers(topic), do: topic |> Presence.list() |> map_size()

  defp format_price(%Decimal{} = price) do
    value = price |> Decimal.round(2) |> Decimal.to_string()

    case String.split(value, ".") do
      [int] -> "R$ #{int},00"
      [int, dec] -> "R$ #{int},#{String.pad_trailing(dec, 2, "0")}"
    end
  end
end
