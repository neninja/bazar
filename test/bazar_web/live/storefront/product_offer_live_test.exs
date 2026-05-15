defmodule BazarWeb.Storefront.ProductOfferLiveTest do
  use BazarWeb.ConnCase

  import Ecto.Query
  import Phoenix.LiveViewTest
  import Bazar.AccountsFixtures
  import Bazar.CatalogFixtures

  alias Bazar.Accounts.Scope
  alias Bazar.Offers
  alias Bazar.Offers.Offer
  alias Bazar.Repo

  setup do
    user = user_fixture()
    scope = Scope.for_user(user)
    product = product_fixture(scope, description: "Cascadia", price: "180.00")

    {:ok, scope: scope, product: product}
  end

  test "visitor creates an anonymous offer from product page", %{conn: conn, product: product} do
    {:ok, view, _html} = live(conn, ~p"/products/#{product.id}")

    assert has_element?(view, "#visitor-offer-form")

    view
    |> form("#visitor-offer-form", offer: %{body: "Pago R$ 150 hoje"})
    |> render_submit()

    assert Repo.one(from o in Offer, where: o.product_id == ^product.id).body ==
             "Pago R$ 150 hoje"

    assert has_element?(view, "#product-offer-panel", "Pendente")
  end

  test "visitor sees offer status changes", %{conn: conn, scope: scope, product: product} do
    {:ok, view, _html} = live(conn, ~p"/products/#{product.id}")

    view
    |> form("#visitor-offer-form", offer: %{body: "Pago R$ 150 hoje"})
    |> render_submit()

    offer = Repo.one(from o in Offer, where: o.product_id == ^product.id)
    assert {:ok, _offer} = Offers.update_offer_status(scope, offer.id, "accepted")

    assert has_element?(view, "#product-offer-panel", "Aceita")
  end
end
