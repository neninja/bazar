defmodule Bazar.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @available_tags ["Estratégia", "Carteado", "Party Game", "Cooperativo", "Euro", "Ameritrash"]
  @trade_options ["Somente Venda", "Venda ou Troca"]

  schema "products" do
    field :image_url, :string
    field :ludopedia_link, :string
    field :description, :string
    field :sale_reason, :string
    field :condition, :string
    field :recommendation, :string
    field :tags, {:array, :string}
    field :price, :decimal
    field :trade_policy, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
      product
      |> cast(attrs, [:image_url, :ludopedia_link, :description, :sale_reason, :condition, :recommendation, :tags, :price, :trade_policy])
      |> validate_required([:description, :price, :trade_policy])
      |> validate_subset(:tags, @available_tags)
      |> validate_inclusion(:trade_policy, @trade_options)
    end

    def available_tags, do: @available_tags
    def trade_options, do: @trade_options
end
