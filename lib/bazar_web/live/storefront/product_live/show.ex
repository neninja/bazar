defmodule BazarWeb.Storefront.ProductLive.Show do
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
      flash_action={@flash_action}
      current_scope={@current_scope}
      viewer_count={@viewer_count}
      viewer_label="investigando esse jogo"
    >
      <div class="min-h-screen bg-base-200 pb-8">
        <div :if={@product} class="max-w-xl mx-auto">
          <figure :if={@product.image_url && @product.image_url != ""}>
            <img
              src={@product.image_url}
              class="w-full aspect-square object-cover"
              alt={@product.title}
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
              <div>
                <p class="text-xl leading-relaxed">{@product.title}</p>
              </div>
              <div :if={@product.condition && @product.condition != ""}>
                <span class="font-semibold text-base-content/70">Condição:</span>
                <span class="ml-1">{@product.condition}</span>
              </div>
              <div :if={@product.condition_detail && @product.condition_detail != ""}>
                <span class="font-semibold text-base-content/70">Condição em detalhe:</span>
                <span class="ml-1">{@product.condition_detail}</span>
              </div>
              <div>
                <span class="font-semibold text-base-content/70">Negócio:</span>
                <span class="ml-1">{@product.trade_policy}</span>
              </div>
            </div>

            <div class="divider my-0"></div>

            <div :if={@product.recommendation && @product.recommendation != ""}>
              <p class="font-semibold text-base-content/70 text-sm mb-1">Recomendação pessoal</p>
              <p class="text-sm leading-relaxed">{@product.recommendation}</p>
            </div>

            <div :if={@product.sale_reason && @product.sale_reason != ""}>
              <p class="font-semibold text-base-content/70 text-sm mb-1">Motivo do desapego</p>
              <p class="text-sm leading-relaxed">{@product.sale_reason}</p>
            </div>

            <div class="flex gap-2">
              <div :if={@product.ludopedia_link && @product.ludopedia_link != ""}>
                <a
                  href={@product.ludopedia_link}
                  target="_blank"
                  rel="noopener noreferrer"
                  class="btn btn-outline btn-sm gap-2 w-full"
                >
                  <.icon name="hero-arrow-top-right-on-square" class="size-4" />Ludopedia
                </a>
              </div>
              <div :if={@product.youtube_link && @product.youtube_link != ""}>
                <a
                  href={@product.youtube_link}
                  target="_blank"
                  rel="noopener noreferrer"
                  class="btn btn-outline btn-sm gap-2 w-full"
                >
                  <.icon name="hero-arrow-top-right-on-square" class="size-4" />Youtube
                </a>
              </div>
            </div>

            <section
              id="product-offer-panel"
              class={[
                "rounded-lg border bg-base-100 p-4 shadow-sm transition",
                offer_panel_class(@offer)
              ]}
            >
              <div class="flex items-start justify-between gap-3">
                <div>
                  <h2 class="text-base font-bold text-base-content">Fazer proposta</h2>
                  <p class="mt-1 text-xs leading-5 text-base-content/60">
                    Propostas aceitas não reservam o produto automaticamente. Combine a retirada presencialmente no evento.
                  </p>
                </div>

                <span class={[
                  "shrink-0 rounded-full px-2.5 py-1 text-xs font-semibold",
                  offer_status_class(@offer)
                ]}>
                  {offer_status_label(@offer)}
                </span>
              </div>

              <.form
                for={@offer_form}
                id="visitor-offer-form"
                phx-change="validate_offer"
                phx-submit="save_offer"
                class="mt-4 space-y-3"
              >
                <.input
                  field={@offer_form[:body]}
                  type="textarea"
                  label="Sua proposta"
                  rows="4"
                  maxlength="800"
                  placeholder="Ex.: Tenho interesse por R$ 150 ou troca por..."
                  class="w-full textarea textarea-bordered min-h-28 resize-y text-sm"
                />

                <.button
                  variant="primary"
                  class="btn btn-primary w-full gap-2 transition hover:-translate-y-0.5"
                >
                  <.icon name="hero-paper-airplane" class="size-4" /> Enviar proposta
                </.button>
              </.form>
            </section>
          </div>
        </div>
      </div>
    </Layouts.storefront>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       viewer_count: 0,
       product: nil,
       product_id: nil,
       offer: nil,
       flash_action: nil,
       offer_form: to_form(Offers.change_offer(%Offer{}))
     )}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    product_topic = "storefront:product:#{id}"

    if connected?(socket) do
      {:ok, _} = Presence.track(self(), @lobby_topic, socket.id, %{})
      {:ok, _} = Presence.track(self(), product_topic, socket.id, %{})
      BazarWeb.Endpoint.subscribe(@lobby_topic)
      BazarWeb.Endpoint.subscribe(product_topic)
      Catalog.subscribe_storefront_products()
      Offers.subscribe_visitor_offers(socket.assigns.anonymous_session_id)
    end

    case Catalog.get_store_product(id) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Produto não encontrado.")
         |> push_navigate(to: ~p"/")}

      %Bazar.Catalog.Product{is_available: false} = product ->
        {:noreply, redirect_unavailable_product(socket, product)}

      product ->
        offer = Offers.get_offer_for_session(product.id, socket.assigns.anonymous_session_id)

        {:noreply,
         assign(socket,
           page_title: "Produto",
           product: product,
           product_id: id,
           offer: offer,
           offer_form: to_offer_form(offer || %Offer{}),
           viewer_count: count_viewers(product_topic)
         )}
    end
  end

  @impl true
  def handle_event("validate_offer", %{"offer" => offer_params}, socket) do
    offer = socket.assigns.offer || %Offer{}

    form =
      offer
      |> Offers.change_offer(offer_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, :offer_form, form)}
  end

  def handle_event("save_offer", %{"offer" => offer_params}, socket) do
    case Offers.upsert_visitor_offer(
           socket.assigns.product,
           socket.assigns.anonymous_session_id,
           offer_params
         ) do
      {:ok, offer} ->
        {:noreply,
         socket
         |> put_flash(:info, "Proposta enviada.")
         |> assign(:flash_action, nil)
         |> assign(:offer, offer)
         |> assign(:offer_form, to_offer_form(offer))}

      {:error, :throttled} ->
        {:noreply,
         put_flash(socket, :error, "Aguarde alguns segundos antes de atualizar sua proposta.")}

      {:error, changeset} ->
        {:noreply, assign(socket, :offer_form, to_form(changeset, action: :insert))}
    end
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", topic: @lobby_topic}, socket) do
    {:noreply, socket}
  end

  def handle_info({:offer_saved, %Offer{product_id: product_id} = offer}, socket)
      when product_id == socket.assigns.product.id do
    {:noreply, assign(socket, offer: offer, offer_form: to_offer_form(offer))}
  end

  def handle_info({:offer_updated, %Offer{product_id: product_id} = offer}, socket)
      when product_id == socket.assigns.product.id do
    {:noreply,
     socket
     |> put_flash(:info, offer_flash_message(offer))
     |> assign(:flash_action, offer_flash_action(offer))
     |> assign(:offer, offer)
     |> assign(:offer_form, to_offer_form(offer))}
  end

  def handle_info({:updated, %Bazar.Catalog.Product{id: id} = product}, socket)
      when id == socket.assigns.product.id do
    if product.is_available do
      {:noreply, assign(socket, :product, product)}
    else
      {:noreply, redirect_unavailable_product(socket, product)}
    end
  end

  def handle_info({:deleted, %Bazar.Catalog.Product{id: id} = product}, socket)
      when id == socket.assigns.product.id do
    {:noreply, redirect_unavailable_product(socket, product)}
  end

  def handle_info({_type, %Bazar.Catalog.Product{}}, socket), do: {:noreply, socket}

  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff"}, socket) do
    case socket.assigns.product_id do
      nil ->
        {:noreply, socket}

      id ->
        {:noreply, assign(socket, :viewer_count, count_viewers("storefront:product:#{id}"))}
    end
  end

  defp count_viewers(topic), do: topic |> Presence.list() |> map_size()

  defp to_offer_form(%Offer{} = offer), do: offer |> Offers.change_offer() |> to_form()

  defp offer_panel_class(%Offer{status: "accepted"}), do: "border-success/40 bg-success/5"
  defp offer_panel_class(%Offer{status: "rejected"}), do: "border-error/40 bg-error/5"
  defp offer_panel_class(%Offer{status: "pending"}), do: "border-warning/40 bg-warning/5"
  defp offer_panel_class(_), do: "border-base-300"

  defp offer_status_label(%Offer{status: "accepted"}), do: "Aceita"
  defp offer_status_label(%Offer{status: "rejected"}), do: "Recusada"
  defp offer_status_label(%Offer{status: "pending"}), do: "Pendente"
  defp offer_status_label(_), do: "Nova"

  defp offer_status_class(%Offer{status: "accepted"}), do: "bg-success/15 text-success"
  defp offer_status_class(%Offer{status: "rejected"}), do: "bg-error/15 text-error"
  defp offer_status_class(%Offer{status: "pending"}), do: "bg-warning/15 text-warning"
  defp offer_status_class(_), do: "bg-base-200 text-base-content/60"

  defp offer_flash_message(%Offer{status: "accepted"} = offer),
    do: "Sua proposta foi aceita em #{product_name(offer)}."

  defp offer_flash_message(%Offer{status: "rejected"} = offer),
    do: "Sua proposta foi recusada em #{product_name(offer)}."

  defp offer_flash_message(%Offer{} = offer),
    do: "Sua proposta foi atualizada em #{product_name(offer)}."

  defp product_name(%Offer{} = offer),
    do: offer.product.title || "Produto #{offer.product_id}"

  defp redirect_unavailable_product(socket, product) do
    socket
    |> put_flash(:info, "O produto #{product.title} foi vendido.")
    |> push_navigate(to: ~p"/")
  end

  defp offer_flash_action(%Offer{} = offer) do
    %{to: ~p"/products/#{offer.product_id}", label: "Ver produto"}
  end

  defp format_price(%Decimal{} = price) do
    value = price |> Decimal.round(2) |> Decimal.to_string()

    case String.split(value, ".") do
      [int] -> "R$ #{int},00"
      [int, dec] -> "R$ #{int},#{String.pad_trailing(dec, 2, "0")}"
    end
  end
end
