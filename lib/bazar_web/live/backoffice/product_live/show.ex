defmodule BazarWeb.Backoffice.ProductLive.Show do
  use BazarWeb, :live_view

  alias Bazar.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <section class="space-y-5">
        <div class="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
          <div>
            <p class="text-sm font-medium text-primary">Backoffice</p>
            <h1 class="text-2xl font-bold tracking-tight text-base-content">Show Product</h1>
            <p class="mt-1 text-sm leading-6 text-base-content/70">
              Produto #{@product.id} no catálogo administrativo.
            </p>
          </div>

          <div class="grid grid-cols-2 gap-2 sm:flex">
            <.button
              navigate={~p"/backoffice/products"}
              class="btn btn-primary btn-soft gap-2 transition hover:-translate-y-0.5"
            >
              <.icon name="hero-arrow-left" class="size-4" /> Voltar
            </.button>
            <.button
              variant="primary"
              navigate={~p"/backoffice/products/#{@product}/edit?return_to=show"}
              class="btn btn-primary gap-2 transition hover:-translate-y-0.5"
            >
              <.icon name="hero-pencil-square" class="size-4" /> Edit product
            </.button>
          </div>
        </div>

        <article class="overflow-hidden rounded-lg border border-base-300 bg-base-100 shadow-sm">
          <div class="grid sm:grid-cols-[14rem_1fr]">
            <div class="bg-base-200">
              <img
                :if={present?(@product.image_url)}
                src={@product.image_url}
                alt={@product.title || "Imagem do produto"}
                class="h-64 w-full object-cover sm:h-full"
              />
              <div
                :if={!present?(@product.image_url)}
                class="flex h-64 items-center justify-center text-base-content/40 sm:h-full"
              >
                <.icon name="hero-photo" class="size-10" />
              </div>
            </div>

            <div class="space-y-5 p-4 sm:p-5">
              <div class="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
                <div class="space-y-2">
                  <p class="text-2xl font-bold text-primary">{format_price(@product.price)}</p>
                  <div class="flex flex-wrap gap-2">
                    <span class="rounded-full bg-base-200 px-2.5 py-1 text-xs font-medium text-base-content/70">
                      {@product.trade_policy || "Sem negociação"}
                    </span>
                    <span class={[
                      "rounded-full px-2.5 py-1 text-xs font-semibold",
                      @product.is_available && "bg-success/15 text-success",
                      !@product.is_available && "bg-base-200 text-base-content/50"
                    ]}>
                      <%= if @product.is_available do %>
                        Disponível
                      <% else %>
                        Indisponível
                      <% end %>
                    </span>
                  </div>
                </div>

                <div
                  :if={@product.tags not in [nil, []]}
                  class="flex flex-wrap gap-1.5 sm:justify-end"
                >
                  <span
                    :for={tag <- @product.tags}
                    class="rounded-full border border-base-300 px-2 py-0.5 text-xs text-base-content/70"
                  >
                    {tag}
                  </span>
                </div>
              </div>

              <div class="grid gap-4 border-y border-base-200 py-4 text-sm sm:grid-cols-2">
                <div>
                  <p class="text-xs font-semibold uppercase text-base-content/50">Condição</p>
                  <p class="mt-1 text-base-content/80">{@product.condition || "Não informada"}</p>
                </div>
                <div>
                  <p class="text-xs font-semibold uppercase text-base-content/50">
                    Condição em detalhe
                  </p>
                  <p class="mt-1 text-base-content/80">
                    {@product.condition_detail || "Não informada"}
                  </p>
                </div>
                <div>
                  <p class="text-xs font-semibold uppercase text-base-content/50">Image url</p>
                  <p class="mt-1 break-all text-base-content/80">
                    {@product.image_url || "Sem imagem"}
                  </p>
                </div>
                <div class="sm:col-span-2">
                  <p class="text-xs font-semibold uppercase text-base-content/50">Ludopedia link</p>
                  <p class="mt-1 break-all text-base-content/80">
                    {@product.ludopedia_link || "Sem link"}
                  </p>
                </div>
                <div class="sm:col-span-2">
                  <p class="text-xs font-semibold uppercase text-base-content/50">Youtube link</p>
                  <p class="mt-1 break-all text-base-content/80">
                    {@product.youtube_link || "Sem link"}
                  </p>
                </div>
              </div>

              <div class="space-y-4">
                <section>
                  <h2 class="text-sm font-semibold text-base-content/70">title</h2>
                  <p class="mt-1 whitespace-pre-line text-sm leading-6 text-base-content">
                    {@product.title}
                  </p>
                </section>

                <section :if={present?(@product.sale_reason)}>
                  <h2 class="text-sm font-semibold text-base-content/70">Sale reason</h2>
                  <p class="mt-1 whitespace-pre-line text-sm leading-6 text-base-content">
                    {@product.sale_reason}
                  </p>
                </section>

                <section :if={present?(@product.recommendation)}>
                  <h2 class="text-sm font-semibold text-base-content/70">Recommendation</h2>
                  <p class="mt-1 whitespace-pre-line text-sm leading-6 text-base-content">
                    {@product.recommendation}
                  </p>
                </section>
              </div>
            </div>
          </div>
        </article>
      </section>
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

  defp format_price(%Decimal{} = price) do
    value = price |> Decimal.round(2) |> Decimal.to_string()

    case String.split(value, ".") do
      [int] -> "R$ #{int},00"
      [int, dec] -> "R$ #{int},#{String.pad_trailing(dec, 2, "0")}"
    end
  end

  defp format_price(_), do: "Sem preço"

  defp present?(value), do: value not in [nil, ""]
end
