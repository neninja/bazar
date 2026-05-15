defmodule BazarWeb.Router do
  use BazarWeb, :router

  import BazarWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug BazarWeb.AnonymousSession, :fetch
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :admin_browser do
    plug :browser
    plug :put_root_layout, html: {BazarWeb.Layouts, :root}
  end

  pipeline :public_browser do
    plug :browser
    plug :put_root_layout, html: {BazarWeb.Layouts, :storefront_root}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BazarWeb do
    pipe_through :public_browser

    live_session :storefront,
      on_mount: [{BazarWeb.UserAuth, :mount_current_scope}] do
      live "/", Storefront.ProductLive.Index, :index
      live "/products/:id", Storefront.ProductLive.Show, :show
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", BazarWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:bazar, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :admin_browser

      live_dashboard "/dashboard", metrics: BazarWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/backoffice", BazarWeb do
    pipe_through [:admin_browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{BazarWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", Backoffice.UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", Backoffice.UserLive.Settings, :confirm_email

      live "/products", Backoffice.ProductLive.Index, :index
      live "/products/new", Backoffice.ProductLive.Form, :new
      live "/products/:id", Backoffice.ProductLive.Show, :show
      live "/products/:id/edit", Backoffice.ProductLive.Form, :edit
      live "/offers", Backoffice.OfferLive.Index, :index
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/backoffice", BazarWeb do
    pipe_through [:admin_browser]

    live_session :current_user,
      on_mount: [{BazarWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", Backoffice.UserLive.Registration, :new
      live "/login", Backoffice.UserLive.Login, :new
      live "/login/:token", Backoffice.UserLive.Confirmation, :new
    end

    post "/login", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
