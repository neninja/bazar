defmodule Bazar.Offers.Offer do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bazar.Catalog.Product

  @statuses ~w(pending accepted rejected)

  schema "offers" do
    field :anonymous_session_id, :string
    field :body, :string
    field :status, :string, default: "pending"

    belongs_to :product, Product

    timestamps(type: :utc_datetime)
  end

  def statuses, do: @statuses

  def visitor_changeset(offer, attrs) do
    offer
    |> cast(attrs, [:body])
    |> validate_required([:body])
    |> validate_length(:body, min: 2, max: 800)
    |> put_change(:status, "pending")
  end

  def status_changeset(offer, status) when status in @statuses do
    change(offer, status: status)
  end
end
