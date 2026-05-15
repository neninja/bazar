defmodule OfferFeatureTest do
  use PhoenixTest.Playwright.Case, async: false
  use BazarWeb, :verified_routes

  import Bazar.AccountsFixtures
  import Bazar.CatalogFixtures

  alias Bazar.Accounts
  alias Bazar.Accounts.Scope
  alias Bazar.Offers.Offer
  alias Bazar.Repo

  setup do
    user = user_fixture()
    scope = Scope.for_user(user)

    product =
      product_fixture(scope, %{
        description: "Brass Birmingham",
        price: "320.00",
        trade_policy: "Venda ou Troca",
        tags: ["Estratégia", "Euro"]
      })

    {:ok, user: user, scope: scope, product: product}
  end

  defp log_in(conn, user) do
    add_session_cookie(
      conn,
      [value: %{user_token: Accounts.generate_user_session_token(user)}],
      BazarWeb.Endpoint.session_options()
    )
  end

  describe "backoffice de propostas" do
    setup %{product: product} do
      offer = offer_fixture(product, "feature-visitor", body: "Pago R$ 275")
      {:ok, offer: offer}
    end

    test "lista propostas relacionadas aos produtos", %{
      conn: conn,
      user: user,
      product: product,
      offer: offer
    } do
      conn
      |> log_in(user)
      |> visit(~p"/backoffice/offers")
      |> assert_has("h1", text: "Propostas")
      |> assert_has("#offers", text: product.description)
      |> assert_has("#offers", text: offer.body)
      |> assert_has("#offers", text: "Pendente")
      |> click_link(product.description)
      |> assert_path(~p"/backoffice/products/#{product.id}")
    end

    test "aceita proposta pelo painel", %{conn: conn, user: user, offer: offer} do
      conn
      |> log_in(user)
      |> visit(~p"/backoffice/offers")
      |> click("#accept-offer-#{offer.id}")
      |> assert_has("#offer-status-#{offer.id}", text: "Aceita")

      assert Repo.get!(Offer, offer.id).status == "accepted"
    end

    test "recusa proposta pelo painel", %{conn: conn, user: user, offer: offer} do
      conn
      |> log_in(user)
      |> visit(~p"/backoffice/offers")
      |> click("#reject-offer-#{offer.id}")
      |> assert_has("#offer-status-#{offer.id}", text: "Recusada")

      assert Repo.get!(Offer, offer.id).status == "rejected"
    end
  end
end
