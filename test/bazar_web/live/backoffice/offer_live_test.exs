defmodule BazarWeb.Backoffice.OfferLiveTest do
  use BazarWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bazar.CatalogFixtures

  alias Bazar.Offers

  setup :register_and_log_in_user

  defp create_offer(%{scope: scope}) do
    product = product_fixture(scope, title: "Azul edição nacional")
    offer = offer_fixture(product, "visitor-1", body: "Pago R$ 120")

    %{product: product, offer: offer}
  end

  describe "Index" do
    setup [:create_offer]

    test "lists offers with product details", %{conn: conn, product: product, offer: offer} do
      {:ok, _view, html} = live(conn, ~p"/backoffice/offers")

      assert html =~ "Propostas"
      assert html =~ product.title
      assert html =~ offer.body
      assert html =~ "Pendente"
    end

    test "accepts an offer", %{conn: conn, scope: scope, offer: offer} do
      {:ok, view, _html} = live(conn, ~p"/backoffice/offers")

      view
      |> element("#accept-offer-#{offer.id}")
      |> render_click()

      assert [%{status: "accepted"}] = Offers.list_offers(scope)
      assert has_element?(view, "#offers-#{offer.id}", "Aceita")
    end

    test "rejects an offer", %{conn: conn, scope: scope, offer: offer} do
      {:ok, view, _html} = live(conn, ~p"/backoffice/offers")

      view
      |> element("#reject-offer-#{offer.id}")
      |> render_click()

      assert [%{status: "rejected"}] = Offers.list_offers(scope)
      assert has_element?(view, "#offers-#{offer.id}", "Recusada")
    end
  end
end
