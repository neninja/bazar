defmodule Bazar.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bazar.Catalog` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        condition: "some condition",
        description: "some description",
        image_url: "some image_url",
        ludopedia_link: "some ludopedia_link",
        price: "120.5",
        recommendation: "some recommendation",
        sale_reason: "some sale_reason",
        tags: ["Estratégia", "Carteado"],
        trade_policy: "Somente Venda"
      })

    {:ok, product} = Bazar.Catalog.create_product(scope, attrs)
    product
  end
end
