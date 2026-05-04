defmodule Bazar.CatalogTest do
  use Bazar.DataCase

  alias Bazar.Catalog

  describe "products" do
    alias Bazar.Catalog.Product

    import Bazar.AccountsFixtures, only: [user_scope_fixture: 0]
    import Bazar.CatalogFixtures

    @invalid_attrs %{
      description: nil,
      image_url: nil,
      ludopedia_link: nil,
      sale_reason: nil,
      condition: nil,
      recommendation: nil,
      tags: nil,
      price: nil,
      trade_policy: nil
    }

    test "list_products/1 returns all scoped products" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      product = product_fixture(scope)
      other_product = product_fixture(other_scope)
      assert Catalog.list_products(scope) == [product]
      assert Catalog.list_products(other_scope) == [other_product]
    end

    test "get_product!/2 returns the product with given id" do
      scope = user_scope_fixture()
      product = product_fixture(scope)
      other_scope = user_scope_fixture()
      assert Catalog.get_product!(scope, product.id) == product
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_product!(other_scope, product.id) end
    end

    test "create_product/2 with valid data creates a product" do
      valid_attrs = %{
        description: "some description",
        image_url: "some image_url",
        ludopedia_link: "some ludopedia_link",
        sale_reason: "some sale_reason",
        condition: "Seminovo",
        recommendation: "some recommendation",
        tags: ["Carteado"],
        price: "120.5",
        trade_policy: "Somente Venda"
      }

      scope = user_scope_fixture()

      assert {:ok, %Product{} = product} = Catalog.create_product(scope, valid_attrs)
      assert product.description == "some description"
      assert product.image_url == "some image_url"
      assert product.ludopedia_link == "some ludopedia_link"
      assert product.sale_reason == "some sale_reason"
      assert product.condition == "Seminovo"
      assert product.recommendation == "some recommendation"
      assert product.tags == ["Carteado"]
      assert product.price == Decimal.new("120.5")
      assert product.trade_policy == "Somente Venda"
      assert product.user_id == scope.user.id
    end

    test "create_product/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.create_product(scope, @invalid_attrs)
    end

    test "update_product/3 with valid data updates the product" do
      scope = user_scope_fixture()
      product = product_fixture(scope)

      update_attrs = %{
        description: "some updated description",
        image_url: "some updated image_url",
        ludopedia_link: "some updated ludopedia_link",
        sale_reason: "some updated sale_reason",
        condition: "Danificado",
        recommendation: "some updated recommendation",
        tags: ["Carteado"],
        price: "456.7",
        trade_policy: "Somente Venda"
      }

      assert {:ok, %Product{} = product} = Catalog.update_product(scope, product, update_attrs)
      assert product.description == "some updated description"
      assert product.image_url == "some updated image_url"
      assert product.ludopedia_link == "some updated ludopedia_link"
      assert product.sale_reason == "some updated sale_reason"
      assert product.condition == "Danificado"
      assert product.recommendation == "some updated recommendation"
      assert product.tags == ["Carteado"]
      assert product.price == Decimal.new("456.7")
      assert product.trade_policy == "Somente Venda"
    end

    test "update_product/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      product = product_fixture(scope)

      assert_raise MatchError, fn ->
        Catalog.update_product(other_scope, product, %{})
      end
    end

    test "update_product/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      product = product_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Catalog.update_product(scope, product, @invalid_attrs)
      assert product == Catalog.get_product!(scope, product.id)
    end

    test "delete_product/2 deletes the product" do
      scope = user_scope_fixture()
      product = product_fixture(scope)
      assert {:ok, %Product{}} = Catalog.delete_product(scope, product)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_product!(scope, product.id) end
    end

    test "delete_product/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      product = product_fixture(scope)
      assert_raise MatchError, fn -> Catalog.delete_product(other_scope, product) end
    end

    test "change_product/2 returns a product changeset" do
      scope = user_scope_fixture()
      product = product_fixture(scope)
      assert %Ecto.Changeset{} = Catalog.change_product(scope, product)
    end
  end
end
