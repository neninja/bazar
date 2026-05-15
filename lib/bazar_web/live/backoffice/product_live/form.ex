defmodule BazarWeb.Backoffice.ProductLive.Form do
  use BazarWeb, :live_view

  alias Bazar.Catalog
  alias Bazar.Catalog.Product

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <section class="space-y-5">
        <div>
          <p class="text-sm font-medium text-primary">Backoffice</p>
          <h1 class="text-2xl font-bold tracking-tight text-base-content">{@page_title}</h1>
          <p class="mt-1 text-sm leading-6 text-base-content/70">
            Use este formulário para manter as informações comerciais do produto.
          </p>
        </div>

        <.form
          for={@form}
          id="product-form"
          phx-change="validate"
          phx-submit="save"
          class="space-y-5 rounded-lg border border-base-300 bg-base-100 p-4 shadow-sm sm:p-5"
        >
          <div class="grid gap-4 sm:grid-cols-2">
            <div class="sm:col-span-2">
              <.input field={@form[:image_url]} type="text" label="Image url" />
            </div>
            <div class="sm:col-span-2">
              <.input field={@form[:ludopedia_link]} type="text" label="Ludopedia link" />
            </div>
            <div class="sm:col-span-2">
              <.input field={@form[:youtube_link]} type="text" label="Youtube link" />
            </div>
            <div class="sm:col-span-2">
              <.input field={@form[:description]} type="textarea" label="Description" rows="5" />
            </div>
            <div class="sm:col-span-2">
              <.input field={@form[:sale_reason]} type="textarea" label="Sale reason" rows="4" />
            </div>
            <.input
              field={@form[:condition]}
              type="select"
              prompt="Selecione a condição"
              label="Condition"
              options={Bazar.Catalog.Product.conditions()}
            />
            <div class="sm:col-span-2">
              <.input field={@form[:condition_detail]} type="text" label="Condição em detalhe" />
            </div>
            <.input field={@form[:price]} type="number" label="Price" step="any" />
            <div class="sm:col-span-2">
              <.input
                field={@form[:recommendation]}
                type="textarea"
                label="Recommendation"
                rows="4"
              />
            </div>
            <.input
              field={@form[:tags]}
              type="select"
              multiple
              label="Tags"
              options={Bazar.Catalog.Product.available_tags()}
            />
            <.input
              field={@form[:trade_policy]}
              type="select"
              prompt="Selecione uma opção"
              label="Negociação"
              options={Bazar.Catalog.Product.trade_options()}
            />
          </div>

          <footer class="grid gap-2 border-t border-base-200 pt-5 sm:flex sm:justify-end">
            <.button
              navigate={return_path(@current_scope, @return_to, @product)}
              class="btn btn-primary btn-soft order-2 w-full sm:order-1 sm:w-auto"
            >
              Cancel
            </.button>
            <.button
              phx-disable-with="Saving..."
              variant="primary"
              class="btn btn-primary order-1 w-full gap-2 transition hover:-translate-y-0.5 sm:order-2 sm:w-auto"
            >
              <.icon name="hero-check" class="size-4" /> Save Product
            </.button>
          </footer>
        </.form>
      </section>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    product = Catalog.get_product!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Product")
    |> assign(:product, product)
    |> assign(:form, to_form(Catalog.change_product(socket.assigns.current_scope, product)))
  end

  defp apply_action(socket, :new, _params) do
    product = %Product{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Product")
    |> assign(:product, product)
    |> assign(:form, to_form(Catalog.change_product(socket.assigns.current_scope, product)))
  end

  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    changeset =
      Catalog.change_product(socket.assigns.current_scope, socket.assigns.product, product_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    save_product(socket, socket.assigns.live_action, product_params)
  end

  defp save_product(socket, :edit, product_params) do
    case Catalog.update_product(
           socket.assigns.current_scope,
           socket.assigns.product,
           product_params
         ) do
      {:ok, product} ->
        {:noreply,
         socket
         |> put_flash(:info, "Product updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, product)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_product(socket, :new, product_params) do
    case Catalog.create_product(socket.assigns.current_scope, product_params) do
      {:ok, product} ->
        {:noreply,
         socket
         |> put_flash(:info, "Product created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, product)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _product), do: ~p"/backoffice/products"
  defp return_path(_scope, "show", product), do: ~p"/backoffice/products/#{product}"
end
