defmodule BazarWeb.Backoffice.OfferLive.Index do
  use BazarWeb, :live_view

  alias Bazar.Offers
  alias Bazar.Offers.Offer

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <section class="space-y-5">
        <div class="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
          <div>
            <p class="text-sm font-medium text-primary">Backoffice</p>
            <h1 class="text-2xl font-bold tracking-tight text-base-content">Propostas</h1>
            <p class="mt-1 text-sm leading-6 text-base-content/70">
              Analise propostas anonimas por produto e responda em tempo real.
            </p>
          </div>

          <.button
            navigate={~p"/backoffice/products"}
            class="btn btn-primary btn-soft w-full gap-2 transition hover:-translate-y-0.5 sm:w-auto"
          >
            <.icon name="hero-arrow-left" class="size-4" /> Produtos
          </.button>
        </div>

        <div id="offers" phx-update="stream" class="space-y-3">
          <div
            id="offers-empty"
            class="hidden only:block rounded-lg border border-dashed border-base-300 bg-base-100/70 p-8 text-center text-sm text-base-content/60"
          >
            Nenhuma proposta recebida.
          </div>

          <article
            :for={{id, offer} <- @streams.offers}
            id={id}
            class="overflow-hidden rounded-lg border border-base-300 bg-base-100 shadow-sm transition hover:border-primary/40 hover:shadow-md"
          >
            <div class="grid sm:grid-cols-[7rem_1fr]">
              <.link
                navigate={~p"/backoffice/products/#{offer.product}"}
                class="block bg-base-200"
                aria-label={"Abrir produto #{offer.product_id}"}
              >
                <img
                  :if={present?(offer.product.image_url)}
                  src={offer.product.image_url}
                  alt={offer.product.title || "Imagem do produto"}
                  class="h-36 w-full object-cover sm:h-full"
                  loading="lazy"
                />
                <div
                  :if={!present?(offer.product.image_url)}
                  class="flex h-36 items-center justify-center text-base-content/40 sm:h-full"
                >
                  <.icon name="hero-photo" class="size-8" />
                </div>
              </.link>

              <div class="space-y-4 p-4">
                <div class="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
                  <div class="min-w-0 space-y-2">
                    <div class="flex flex-wrap items-center gap-2">
                      <span
                        id={"offer-status-#{offer.id}"}
                        class={[
                          "rounded-full px-2.5 py-1 text-xs font-semibold",
                          status_class(offer)
                        ]}
                      >
                        {status_label(offer)}
                      </span>
                      <span class="rounded-full bg-base-200 px-2.5 py-1 text-xs font-medium text-base-content/60">
                        Atualizada {format_datetime(offer.updated_at)}
                      </span>
                    </div>

                    <.link
                      navigate={~p"/backoffice/products/#{offer.product}"}
                      class="block text-base font-semibold leading-6 text-base-content transition hover:text-primary"
                    >
                      {offer.product.title || "Produto sem descrição"}
                    </.link>
                  </div>

                  <div class="grid grid-cols-2 gap-2 sm:flex">
                    <button
                      id={"accept-offer-#{offer.id}"}
                      type="button"
                      class="inline-flex items-center justify-center gap-2 rounded-md border border-success/30 px-3 py-2 text-sm font-semibold text-success transition hover:bg-success hover:text-success-content disabled:cursor-not-allowed disabled:opacity-50"
                      phx-click={JS.push("accept", value: %{id: offer.id})}
                      disabled={offer.status == "accepted"}
                    >
                      <.icon name="hero-check" class="size-4" /> Aceitar
                    </button>
                    <button
                      id={"reject-offer-#{offer.id}"}
                      type="button"
                      class="inline-flex items-center justify-center gap-2 rounded-md border border-error/30 px-3 py-2 text-sm font-semibold text-error transition hover:bg-error hover:text-error-content disabled:cursor-not-allowed disabled:opacity-50"
                      phx-click={JS.push("reject", value: %{id: offer.id})}
                      disabled={offer.status == "rejected"}
                    >
                      <.icon name="hero-x-mark" class="size-4" /> Recusar
                    </button>
                  </div>
                </div>

                <p class="whitespace-pre-line rounded-lg bg-base-200/70 p-3 text-sm leading-6 text-base-content/80">
                  {offer.body}
                </p>
              </div>
            </div>
          </article>
        </div>
      </section>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Offers.subscribe_offers(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Propostas")
     |> stream(:offers, Offers.list_offers(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("accept", %{"id" => id}, socket) do
    {:ok, _offer} = Offers.update_offer_status(socket.assigns.current_scope, id, "accepted")
    {:noreply, socket}
  end

  def handle_event("reject", %{"id" => id}, socket) do
    {:ok, _offer} = Offers.update_offer_status(socket.assigns.current_scope, id, "rejected")
    {:noreply, socket}
  end

  @impl true
  def handle_info({event, %Offer{}}, socket) when event in [:offer_upserted, :offer_updated] do
    {:noreply,
     stream(socket, :offers, Offers.list_offers(socket.assigns.current_scope), reset: true)}
  end

  defp status_label(%Offer{status: "accepted"}), do: "Aceita"
  defp status_label(%Offer{status: "rejected"}), do: "Recusada"
  defp status_label(%Offer{status: "pending"}), do: "Pendente"

  defp status_class(%Offer{status: "accepted"}), do: "bg-success/15 text-success"
  defp status_class(%Offer{status: "rejected"}), do: "bg-error/15 text-error"
  defp status_class(%Offer{status: "pending"}), do: "bg-warning/15 text-warning"

  defp format_datetime(%DateTime{} = datetime) do
    Calendar.strftime(datetime, "%d/%m %H:%M")
  end

  defp present?(value), do: value not in [nil, ""]
end
