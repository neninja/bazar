defmodule BazarWeb.Backoffice.ProductLive.Index do
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
            <h1 class="text-2xl font-bold tracking-tight text-base-content">Listing Products</h1>
            <p class="mt-1 text-sm leading-6 text-base-content/70">
              Gerencie catálogo, preço, disponibilidade e informações de venda.
            </p>
          </div>

          <div class="grid grid-cols-2 gap-2 sm:flex">
            <.button
              navigate={~p"/backoffice/offers"}
              class="btn btn-primary btn-soft gap-2 transition-transform hover:-translate-y-0.5"
            >
              <.icon name="hero-inbox" class="size-4" /> Propostas
            </.button>
            <.button
              variant="primary"
              navigate={~p"/backoffice/products/new"}
              class="btn btn-primary gap-2 transition-transform hover:-translate-y-0.5"
            >
              <.icon name="hero-plus" class="size-4" /> New Product
            </.button>
          </div>
        </div>

        <table class="w-full border-separate border-spacing-y-3">
          <thead class="sr-only">
            <tr>
              <th>Produto</th>
            </tr>
          </thead>
          <tbody id="products" phx-update="stream">
            <tr id="products-empty" class="hidden only:table-row">
              <td class="rounded-lg border border-dashed border-base-300 bg-base-100/70 p-8 text-center text-sm text-base-content/60">
                Nenhum produto cadastrado.
              </td>
            </tr>

            <tr :for={{id, product} <- @streams.products} id={id} class="group">
              <td class="p-0">
                <article class="overflow-hidden rounded-lg border border-base-300 bg-base-100 shadow-sm transition group-hover:border-primary/40 group-hover:shadow-md">
                  <div class="grid gap-0 sm:grid-cols-[8.5rem_1fr]">
                    <.link
                      navigate={~p"/backoffice/products/#{product}"}
                      class="block bg-base-200"
                      aria-label={"Abrir produto #{product.id}"}
                    >
                      <img
                        :if={present?(product.image_url)}
                        src={product.image_url}
                        alt={product.description || "Imagem do produto"}
                        class="h-44 w-full object-cover sm:h-full"
                        loading="lazy"
                      />
                      <div
                        :if={!present?(product.image_url)}
                        class="flex h-44 items-center justify-center text-base-content/40 sm:h-full"
                      >
                        <.icon name="hero-photo" class="size-8" />
                      </div>
                    </.link>

                    <div class="min-w-0 space-y-4 p-4">
                      <div class="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
                        <div class="min-w-0 space-y-2">
                          <div class="flex flex-wrap items-center gap-2">
                            <span class="rounded-full bg-primary/10 px-2.5 py-1 text-xs font-semibold text-primary">
                              {format_price(product.price)}
                            </span>
                            <span class="rounded-full bg-base-200 px-2.5 py-1 text-xs font-medium text-base-content/70">
                              {product.trade_policy || "Sem negociação"}
                            </span>
                            <span class={[
                              "rounded-full px-2.5 py-1 text-xs font-semibold",
                              product.is_available && "bg-success/15 text-success",
                              !product.is_available && "bg-base-200 text-base-content/50"
                            ]}>
                              <%= if product.is_available do %>
                                Disponível
                              <% else %>
                                Indisponível
                              <% end %>
                            </span>
                          </div>

                          <.link
                            navigate={~p"/backoffice/products/#{product}"}
                            class="block text-base font-semibold leading-6 text-base-content transition hover:text-primary"
                          >
                            {product.description || "Produto sem descrição"}
                          </.link>
                        </div>

                        <label class="flex shrink-0 items-center justify-between gap-3 rounded-lg bg-base-200 px-3 py-2 text-sm font-medium sm:justify-start">
                          <span class="text-base-content/70">Disponível</span>
                          <input
                            type="checkbox"
                            class="toggle toggle-success toggle-sm"
                            data-testid="toggle-availability"
                            data-available={to_string(product.is_available)}
                            checked={product.is_available}
                            phx-click="toggle_availability"
                            phx-value-id={product.id}
                          />
                        </label>
                      </div>

                      <div class="grid gap-3 text-sm sm:grid-cols-2">
                        <div>
                          <p class="text-xs font-semibold uppercase text-base-content/50">
                            Condição
                          </p>
                          <p class="mt-1 text-base-content/80">
                            {product.condition || "Não informada"}
                          </p>
                        </div>
                        <div>
                          <p class="text-xs font-semibold uppercase text-base-content/50">
                            Ludopedia
                          </p>
                          <p class="mt-1 truncate text-base-content/80">
                            {product.ludopedia_link || "Sem link"}
                          </p>
                        </div>
                        <div :if={present?(product.sale_reason)} class="sm:col-span-2">
                          <p class="text-xs font-semibold uppercase text-base-content/50">
                            Motivo da venda
                          </p>
                          <p class="mt-1 line-clamp-2 text-base-content/80">
                            {product.sale_reason}
                          </p>
                        </div>
                        <div :if={present?(product.recommendation)} class="sm:col-span-2">
                          <p class="text-xs font-semibold uppercase text-base-content/50">
                            Recomendação
                          </p>
                          <p class="mt-1 line-clamp-2 text-base-content/80">
                            {product.recommendation}
                          </p>
                        </div>
                      </div>

                      <div
                        :if={product.tags not in [nil, []]}
                        class="flex flex-wrap gap-1.5"
                        aria-label="Tags do produto"
                      >
                        <span
                          :for={tag <- product.tags}
                          class="rounded-full border border-base-300 px-2 py-0.5 text-xs text-base-content/70"
                        >
                          {tag}
                        </span>
                      </div>

                      <div class="grid grid-cols-2 gap-2 border-t border-base-200 pt-4 sm:flex sm:justify-end">
                        <.link
                          navigate={~p"/backoffice/products/#{product}"}
                          class="inline-flex items-center justify-center gap-2 rounded-md border border-base-300 px-3 py-2 text-sm font-semibold transition hover:border-primary hover:text-primary"
                        >
                          <.icon name="hero-eye" class="size-4" /> Show
                        </.link>
                        <.link
                          navigate={~p"/backoffice/products/#{product}/edit"}
                          class="inline-flex items-center justify-center gap-2 rounded-md border border-base-300 px-3 py-2 text-sm font-semibold transition hover:border-primary hover:text-primary"
                        >
                          <.icon name="hero-pencil-square" class="size-4" /> Edit
                        </.link>
                        <.link
                          phx-click={JS.push("delete", value: %{id: product.id}) |> hide("##{id}")}
                          data-confirm="Are you sure?"
                          class="col-span-2 inline-flex items-center justify-center gap-2 rounded-md border border-error/30 px-3 py-2 text-sm font-semibold text-error transition hover:bg-error hover:text-error-content sm:col-span-1"
                        >
                          <.icon name="hero-trash" class="size-4" /> Delete
                        </.link>
                      </div>
                    </div>
                  </div>
                </article>
              </td>
            </tr>
          </tbody>
        </table>
      </section>
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
  def handle_event("toggle_availability", %{"id" => id}, socket) do
    product = Catalog.get_product!(socket.assigns.current_scope, id)
    {:ok, product} = Catalog.toggle_availability(socket.assigns.current_scope, product)

    {:noreply, stream_insert(socket, :products, product)}
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
    {:noreply,
     stream(socket, :products, list_products(socket.assigns.current_scope), reset: true)}
  end

  defp list_products(current_scope) do
    Catalog.list_products(current_scope)
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
