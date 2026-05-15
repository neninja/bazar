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
        condition: "Seminovo",
        condition_detail: "some detail",
        description: "some description",
        image_url: "some image_url",
        ludopedia_link: "some ludopedia_link",
        youtube_link: "some ludopedia_link",
        price: "120.5",
        recommendation: "some recommendation",
        sale_reason: "some sale_reason",
        tags: ["Estratégia", "Carteado"],
        is_available: true,
        trade_policy: "Somente Venda"
      })

    {:ok, product} = Bazar.Catalog.create_product(scope, attrs)
    product
  end

  def offer_fixture(product, anonymous_session_id \\ "visitor-session", attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        body: "Tenho interesse por R$ 100"
      })

    {:ok, offer} = Bazar.Offers.upsert_visitor_offer(product, anonymous_session_id, attrs)
    offer
  end
end
