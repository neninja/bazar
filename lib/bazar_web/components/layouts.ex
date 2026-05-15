defmodule BazarWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use BazarWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :flash_action, :map, default: nil, doc: "an optional action link for the info flash"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <main class="px-4 py-20 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} flash_action={@flash_action} />
    """
  end

  @doc """
  Renders the public storefront layout
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :flash_action, :map, default: nil, doc: "an optional action link for the info flash"

  attr :current_scope, :map,
    default: nil,
    doc: "the current authenticated user scope, when available"

  attr :viewer_count, :integer,
    default: nil,
    doc: "the current number of viewers in the storefront"

  attr :viewer_label, :string,
    default: "na loja",
    doc: "the label shown next to the viewer count"

  slot :inner_block, required: true

  def storefront(assigns) do
    ~H"""
    <main>
      <nav class="navbar bg-base-100 border-b border-base-300 sticky top-0 z-30 shadow-sm">
        <div class="mx-auto flex w-full max-w-xl items-center justify-between px-3">
          <div class="flex items-center gap-3">
            <.link href={~p"/"} class="text-lg font-bold tracking-tight">
              Bazar
            </.link>

            <div
              :if={!is_nil(@viewer_count)}
              class="hidden sm:flex items-center gap-1.5 text-sm text-base-content/60"
            >
              <.icon name="hero-eye" class="size-4" />
              <span>{@viewer_count} {@viewer_label}</span>
            </div>
          </div>

          <ul class="menu menu-horizontal items-center gap-1 text-sm">
            <%= if @current_scope && @current_scope.user do %>
              <li>
                <.theme_toggle />
              </li>
              <li>
                {@current_scope.user.email}
              </li>
              <li>
                <.link
                  href={~p"/backoffice/products"}
                  aria-label="Ir para o backoffice"
                  title="Backoffice"
                >
                  <.icon name="hero-briefcase" class="size-5" />
                  <span class="sr-only">Backoffice</span>
                </.link>
              </li>
              <li class="hidden md:block">
                <.link
                  href={~p"/backoffice/users/settings"}
                  aria-label="Abrir configurações da conta"
                  title="Settings"
                >
                  <.icon name="hero-cog-6-tooth" class="size-5" />
                  <span class="sr-only">Settings</span>
                </.link>
              </li>
              <li>
                <.link
                  href={~p"/backoffice/users/log-out"}
                  method="delete"
                  aria-label="Sair da conta"
                  title="Sair"
                >
                  <.icon name="hero-arrow-right-start-on-rectangle" class="size-5" />
                  <span class="sr-only">Sair</span>
                </.link>
              </li>
            <% else %>
              <li>
                <.link href={~p"/backoffice/users/log-in"}>Entrar</.link>
              </li>
            <% end %>
          </ul>
        </div>
      </nav>

      <div
        :if={!is_nil(@viewer_count)}
        class="sm:hidden flex items-center justify-center gap-1.5 bg-base-100 border-b border-base-300 py-2 text-xs text-base-content/60"
      >
        <.icon name="hero-eye" class="size-4" />
        <span>{@viewer_count} {@viewer_label}</span>
      </div>

      {render_slot(@inner_block)}
    </main>

    <.flash_group flash={@flash} flash_action={@flash_action} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"
  attr :flash_action, :map, default: nil, doc: "an optional action link for the info flash"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} action={@flash_action} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides a compact light/dark theme toggle.
  """
  def theme_toggle(assigns) do
    ~H"""
    <button
      type="button"
      class="btn btn-ghost btn-circle btn-sm"
      phx-click={JS.dispatch("phx:set-theme")}
      data-phx-theme="toggle"
      aria-label="Alternar tema claro ou escuro"
      title="Alternar tema"
    >
      <.icon name="hero-moon" class="size-5 [[data-theme=dark]_&]:hidden" />
      <.icon name="hero-sun" class="size-5 hidden [[data-theme=dark]_&]:inline-block" />
      <span class="sr-only">Alternar tema claro ou escuro</span>
    </button>
    """
  end
end
