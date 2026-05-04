defmodule Bazar.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @available_tags ["Estratégia", "Carteado", "Party Game", "Cooperativo", "Euro", "Ameritrash"]
  @trade_options ["Somente Venda", "Venda ou Troca"]
  @conditions ["Seminovo", "Com marcas de uso", "Danificado"]

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
  def changeset(product, attrs, scope \\ nil) do
    product
    |> cast(attrs, [
      :image_url,
      :ludopedia_link,
      :description,
      :sale_reason,
      :condition,
      :recommendation,
      :tags,
      :price,
      :trade_policy
    ])
    |> maybe_put_user_id(scope)
    |> validate_required([:description, :price, :trade_policy])
    |> validate_subset(:tags, @available_tags)
    |> validate_inclusion(:trade_policy, @trade_options)
    |> validate_inclusion(:condition, @conditions)
  end

  defp maybe_put_user_id(changeset, nil), do: changeset
  defp maybe_put_user_id(changeset, scope), do: put_change(changeset, :user_id, scope.user.id)

  def available_tags, do: @available_tags
  def trade_options, do: @trade_options
  def conditions, do: @conditions
end
