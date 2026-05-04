defmodule ProductCrudTest do
  use PhoenixTest.Playwright.Case, async: false
  use BazarWeb, :verified_routes

  import Bazar.AccountsFixtures
  import Bazar.CatalogFixtures

  alias Bazar.Accounts
  alias Bazar.Accounts.Scope

  setup do
    user = user_fixture()
    scope = Scope.for_user(user)
    {:ok, user: user, scope: scope}
  end

  defp log_in(conn, user) do
    add_session_cookie(
      conn,
      [value: %{user_token: Accounts.generate_user_session_token(user)}],
      BazarWeb.Endpoint.session_options()
    )
  end

  describe "cadastro de produto" do
    test "cria um novo produto a partir da listagem", %{conn: conn, user: user} do
      conn
      |> log_in(user)
      |> visit(~p"/backoffice/products")
      |> click_link("New Product")
      |> assert_has("h1", text: "New Product")
      |> fill_in("Image url", with: "http://exemplo.com/imagem.jpg")
      |> fill_in("Ludopedia link", with: "http://ludopedia.com.br/jogo/exemplo")
      |> fill_in("Description", with: "Excelente jogo de estratégia para toda a família")
      |> fill_in("Sale reason", with: "Já jogamos bastante, hora de passar adiante")
      |> select("Condition", option: "Seminovo", exact: false)
      |> fill_in("Recommendation", with: "Recomendo para 3 a 5 jogadores")
      |> select("Tags", option: "Estratégia", exact: false)
      |> fill_in("Price", with: "150")
      |> select("Negociação", option: "Somente Venda", exact: false)
      |> click_button("Save Product")
      |> assert_has("[role=alert]", text: "Product created successfully")
    end
  end

  describe "edição de produto" do
    setup %{scope: scope} do
      product = product_fixture(scope)
      {:ok, product: product}
    end

    test "edita um produto a partir da listagem", %{conn: conn, user: user, product: product} do
      conn
      |> log_in(user)
      |> visit(~p"/backoffice/products")
      |> assert_has("td", text: product.description)
      |> click_link("Edit")
      |> assert_has("h1", text: "Edit Product")
      |> fill_in("Description", with: "Descrição atualizada via e2e", exact: false)
      |> fill_in("Price", with: "200")
      |> click_button("Save Product")
      |> assert_has("[role=alert]", text: "Product updated successfully")
      |> assert_has("td", text: "Descrição atualizada via e2e")
    end

    test "edita um produto a partir da página de detalhes", %{
      conn: conn,
      user: user,
      product: product
    } do
      conn
      |> log_in(user)
      |> visit(~p"/backoffice/products/#{product}")
      |> assert_has("h1", text: "Product")
      |> click_link("Edit product")
      |> assert_has("h1", text: "Edit Product")
      |> fill_in("Sale reason", with: "Motivo de venda atualizado", exact: false)
      |> select("Negociação", option: "Venda ou Troca", exact: false)
      |> click_button("Save Product")
      |> assert_has("[role=alert]", text: "Product updated successfully")
    end
  end
end
