defmodule StorefrontTest do
  use PhoenixTest.Playwright.Case, async: false
  use BazarWeb, :verified_routes

  import Bazar.AccountsFixtures
  import Bazar.CatalogFixtures

  alias Bazar.Accounts.Scope

  setup do
    user = user_fixture()
    scope = Scope.for_user(user)
    {:ok, user: user, scope: scope}
  end

  defp track_extra_viewer(topic) do
    {:ok, _} =
      BazarWeb.Presence.track(self(), topic, "extra-viewer-#{System.unique_integer()}", %{})
  end

  describe "listagem de produtos" do
    setup %{scope: scope} do
      product1 =
        product_fixture(scope, %{
          description: "Catan - Colonizadores de Catan",
          price: "120.00",
          tags: ["Estratégia", "Euro"]
        })

      product2 =
        product_fixture(scope, %{
          description: "Ticket to Ride",
          price: "200.50",
          tags: ["Carteado"]
        })

      {:ok, products: [product1, product2]}
    end

    test "exibe os produtos cadastrados na página inicial", %{conn: conn, products: [p1, p2]} do
      conn
      |> visit(~p"/")
      |> assert_has("p", text: p1.description)
      |> assert_has("p", text: "R$ 120,00")
      |> assert_has("span", text: "Estratégia")
      |> assert_has("span", text: "Euro")
      |> assert_has("p", text: p2.description)
      |> assert_has("p", text: "R$ 200,50")
      |> assert_has("span", text: "Carteado")
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
          description: "Pandemic - O Jogo Cooperativo",
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
      |> assert_has("p", text: product.description)
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
end
