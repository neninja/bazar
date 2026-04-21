defmodule BazarWeb.StoreLive.Index do
  use BazarWeb, :live_view

  alias Bazar.Catalog
  alias BazarWeb.Presence

  @lobby_topic "store:lobby"

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.store flash={@flash}>
      <div class="min-h-screen bg-base-200 pb-8">
        <header class="bg-base-100 border-b border-base-300 px-4 py-4 sticky top-0 z-10 shadow-sm">
          <div class="max-w-xl mx-auto flex items-center justify-between">
            <h1 class="text-2xl font-bold tracking-tight">Bazar</h1>
            <div class="flex items-center gap-1.5 text-sm text-base-content/60">
              <.icon name="hero-eye" class="size-4" />
              <span>{@viewer_count} na loja</span>
            </div>
          </div>
        </header>

        <div class="max-w-xl mx-auto px-3 pt-5">
          <div class="grid grid-cols-2 gap-3" id="store-products">
            <div :for={{dom_id, product} <- @streams.products} id={dom_id}>
              <div class="card bg-base-100 shadow-sm h-full">
                <figure :if={product.image_url && product.image_url != ""}>
                  <img
                    src={product.image_url}
                    loading="lazy"
                    class="w-full aspect-square object-cover"
                    alt={product.description}
                  />
                </figure>
                <div class="card-body p-3 gap-2">
                  <p class="font-bold text-primary text-lg">{format_price(product.price)}</p>
                  <p class="text-sm text-base-content/70 line-clamp-3">{product.description}</p>
                  <div :if={product.tags not in [nil, []]} class="flex flex-wrap gap-1">
                    <span :for={tag <- product.tags} class="badge badge-outline badge-xs">
                      {tag}
                    </span>
                  </div>
                  <div class="card-actions mt-auto pt-1">
                    <.button variant="primary" navigate={~p"/loja/#{product.id}"} class="btn-sm w-full">
                      Ver mais
                    </.button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.store>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      {:ok, _} = Presence.track(self(), @lobby_topic, socket.id, %{})
      BazarWeb.Endpoint.subscribe(@lobby_topic)
    end

    {:ok, assign(socket, :viewer_count, count_viewers(@lobby_topic))}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Bazar")
     |> stream(:products, Catalog.list_all_products())}
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", topic: @lobby_topic}, socket) do
    {:noreply, assign(socket, :viewer_count, count_viewers(@lobby_topic))}
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
