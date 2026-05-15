defmodule BazarWeb.Storefront.ProductLive.Index do
  use BazarWeb, :live_view

  alias Bazar.Catalog
  alias Bazar.Offers
  alias Bazar.Offers.Offer
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
      offer_notification={@offer_notification}
    >
      <div class="min-h-screen bg-base-200 pb-8">
        <div class="max-w-xl mx-auto px-3 pt-5">
          <div
            id="storefront-products"
            phx-update="stream"
            class="grid grid-cols-2 gap-3"
          >
            <div
              id="storefront-products-empty"
              class="col-span-2 hidden rounded-lg border border-dashed border-base-300 bg-base-100/70 p-8 text-center text-sm text-base-content/60 only:block"
            >
              Nenhum produto disponível.
            </div>
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
                    <.button
                      variant="primary"
                      navigate={~p"/products/#{product.id}"}
                      class="btn-sm w-full"
                    >
                      Ver mais
                    </.button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.storefront>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      {:ok, _} = Presence.track(self(), @lobby_topic, socket.id, %{})
      BazarWeb.Endpoint.subscribe(@lobby_topic)
      Offers.subscribe_visitor_offers(socket.assigns.anonymous_session_id)
    end

    {:ok, assign(socket, viewer_count: count_viewers(@lobby_topic), offer_notification: nil)}
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

  def handle_info({:offer_saved, %Offer{}}, socket), do: {:noreply, socket}

  def handle_info({:offer_updated, %Offer{} = offer}, socket) do
    {:noreply, assign(socket, :offer_notification, offer_notification(offer))}
  end

  @impl true
  def handle_event("dismiss_offer_notification", _params, socket) do
    {:noreply, assign(socket, :offer_notification, nil)}
  end

  defp count_viewers(topic), do: topic |> Presence.list() |> map_size()

  defp offer_notification(%Offer{} = offer) do
    %{
      product_name: offer.product.description || "Produto #{offer.product_id}",
      product_path: ~p"/products/#{offer.product_id}",
      status_text: notification_status_text(offer)
    }
  end

  defp notification_status_text(%Offer{status: "accepted"}), do: "Sua proposta foi aceita em "
  defp notification_status_text(%Offer{status: "rejected"}), do: "Sua proposta foi recusada em "
  defp notification_status_text(_offer), do: "Sua proposta mudou em "

  defp format_price(%Decimal{} = price) do
    value = price |> Decimal.round(2) |> Decimal.to_string()

    case String.split(value, ".") do
      [int] -> "R$ #{int},00"
      [int, dec] -> "R$ #{int},#{String.pad_trailing(dec, 2, "0")}"
    end
  end
end
