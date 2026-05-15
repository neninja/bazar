defmodule StorefrontTest do
  use PhoenixTest.Playwright.Case, async: false
  use BazarWeb, :verified_routes

  import Ecto.Query
  import Bazar.AccountsFixtures
  import Bazar.CatalogFixtures

  alias Bazar.Accounts.Scope
  alias Bazar.Offers
  alias Bazar.Offers.Offer
  alias Bazar.Repo

  setup do
    user = user_fixture()
    scope = Scope.for_user(user)
    {:ok, user: user, scope: scope}
  end

  defp track_extra_viewer(topic) do
    {:ok, _} =
      BazarWeb.Presence.track(self(), topic, "extra-viewer-#{System.unique_integer()}", %{})
  end

  defp get_product_offer(product) do
    Repo.one!(from o in Offer, where: o.product_id == ^product.id)
  end

  describe "listagem de produtos" do
    setup %{scope: scope} do
      product1 =
        product_fixture(scope, %{
          title: "Catan - Colonizadores de Catan",
          price: "120.00",
          tags: ["Estratégia", "Euro"]
        })

      product2 =
        product_fixture(scope, %{
          title: "Ticket to Ride",
          price: "200.50",
          tags: ["Carteado"]
        })

      {:ok, products: [product1, product2]}
    end

    test "exibe os produtos cadastrados na página inicial", %{conn: conn, products: [p1, p2]} do
      conn
      |> visit(~p"/")
      |> assert_has("#storefront-products[phx-update='stream']")
      |> assert_has("p", text: p1.title)
      |> assert_has("p", text: "R$ 120,00")
      |> assert_has("span", text: "Estratégia")
      |> assert_has("span", text: "Euro")
      |> assert_has("p", text: p2.title)
      |> assert_has("p", text: "R$ 200,50")
      |> assert_has("span", text: "Carteado")
    end

    test "não exibe produtos indisponíveis", %{conn: conn, scope: scope} do
      product_fixture(scope, %{title: "Produto Já Vendido", is_available: false})

      conn
      |> visit(~p"/")
      |> refute_has("p", text: "Produto Já Vendido")
    end

    test "exibe contagem de visitantes presentes na loja", %{conn: conn} do
      track_extra_viewer("storefront:lobby")

      conn
      |> visit(~p"/")
      |> assert_has("span", text: "2 na loja")
    end
  end

  describe "detalhes de um produto" do
    setup %{scope: scope} do
      product =
        product_fixture(scope, %{
          title: "Pandemic - O Jogo Cooperativo",
          price: "180.00",
          sale_reason: "Presente duplicado, nunca usado",
          recommendation: "Ideal para 2 a 4 jogadores",
          condition: "Seminovo",
          trade_policy: "Somente Venda",
          tags: ["Cooperativo", "Estratégia"]
        })

      {:ok, product: product}
    end

    test "exibe informações específicas do produto", %{conn: conn, product: product} do
      conn
      |> visit(~p"/products/#{product.id}")
      |> assert_has("p", text: "R$ 180,00")
      |> assert_has("p", text: product.title)
      |> assert_has("span", text: "Cooperativo")
      |> assert_has("span", text: "Estratégia")
      |> assert_has("span", text: "Seminovo")
      |> assert_has("span", text: "Somente Venda")
      |> assert_has("p", text: product.sale_reason)
      |> assert_has("p", text: product.recommendation)
    end

    test "exibe contagem de usuários vendo o mesmo produto", %{conn: conn, product: product} do
      track_extra_viewer("storefront:product:#{product.id}")

      conn
      |> visit(~p"/products/#{product.id}")
      |> assert_has("span", text: "2 na loja")
    end
  end

  describe "propostas do visitante" do
    setup %{scope: scope} do
      product =
        product_fixture(scope, %{
          title: "Brass Birmingham",
          price: "320.00",
          trade_policy: "Venda ou Troca",
          tags: ["Estratégia", "Euro"]
        })

      {:ok, product: product}
    end

    test "envia proposta anonima pela página do produto", %{conn: conn, product: product} do
      conn
      |> visit(~p"/products/#{product.id}")
      |> assert_has("#visitor-offer-form")
      |> fill_in("Sua proposta", with: "Consigo pagar R$ 280 hoje")
      |> click_button("Enviar proposta")
      |> assert_has("[role=alert]", text: "Proposta enviada.")
      |> assert_has("#product-offer-panel", text: "Pendente")

      offer = get_product_offer(product)
      assert offer.body == "Consigo pagar R$ 280 hoje"
      assert offer.status == "pending"
    end

    test "edita proposta existente e volta para pendente", %{
      conn: conn,
      scope: scope,
      product: product
    } do
      session =
        conn
        |> visit(~p"/products/#{product.id}")
        |> assert_has("#product-offer-panel", text: "Nova")
        |> fill_in("Sua proposta", with: "Proposta inicial de R$ 260")
        |> click_button("Enviar proposta")
        |> assert_has("body", text: "Proposta enviada.")
        |> assert_has("#product-offer-panel", text: "Pendente")

      offer = get_product_offer(product)
      {:ok, _accepted_offer} = Offers.update_offer_status(scope, offer.id, "accepted")

      session
      |> assert_has("#product-offer-panel", text: "Aceita")
      |> fill_in("Sua proposta", with: "Atualizo para R$ 290")
      |> click_button("Enviar proposta")
      |> assert_has("[role=alert]", text: "Proposta enviada.")
      |> assert_has("#product-offer-panel", text: "Pendente")

      edited_offer = Repo.get!(Offer, offer.id)
      assert edited_offer.body == "Atualizo para R$ 290"
      assert edited_offer.status == "pending"
    end

    test "recebe notificação quando a situação da proposta muda", %{
      conn: conn,
      scope: scope,
      product: product
    } do
      session =
        conn
        |> visit(~p"/products/#{product.id}")
        |> assert_has("#product-offer-panel", text: "Nova")
        |> fill_in("Sua proposta", with: "Pago R$ 300 se puder retirar agora")
        |> click_button("Enviar proposta")
        |> assert_has("[role=alert]", text: "Proposta enviada.")
        |> assert_has("#product-offer-panel", text: "Pendente")

      offer = get_product_offer(product)

      session =
        session
        |> visit(~p"/")
        |> assert_has("#storefront-products", text: product.title)

      {:ok, _accepted_offer} = Offers.update_offer_status(scope, offer.id, "accepted")

      session
      |> assert_has("[role=alert]", text: "Sua proposta foi aceita em #{product.title}.")
      |> assert_has("[role=alert] a[href='/products/#{product.id}']", text: "Ver produto")
      |> click_link("[role=alert]", "Ver produto")
      |> assert_path(~p"/products/#{product.id}")
      |> assert_has("#product-offer-panel", text: "Aceita")
    end
  end
end
