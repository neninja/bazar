defmodule Bazar.Offers do
  @moduledoc """
  The Offers context.
  """

  import Ecto.Query, warn: false

  alias Bazar.Accounts.Scope
  alias Bazar.Catalog.Product
  alias Bazar.Offers.Offer
  alias Bazar.Repo

  @throttle_seconds 2
  @visitor_topic_prefix "visitor"

  def subscribe_offers(%Scope{} = scope) do
    Phoenix.PubSub.subscribe(Bazar.PubSub, admin_topic(scope.user.id))
  end

  def subscribe_visitor_offers(anonymous_session_id) when is_binary(anonymous_session_id) do
    Phoenix.PubSub.subscribe(Bazar.PubSub, visitor_topic(anonymous_session_id))
  end

  def list_offers(%Scope{} = scope) do
    from(o in Offer,
      join: p in assoc(o, :product),
      where: p.user_id == ^scope.user.id,
      preload: [product: p],
      order_by: [
        asc:
          fragment(
            "CASE ? WHEN 'pending' THEN 0 WHEN 'accepted' THEN 1 WHEN 'rejected' THEN 2 ELSE 3 END",
            o.status
          ),
        desc: o.updated_at
      ]
    )
    |> Repo.all()
  end

  def get_offer_for_session(product_id, anonymous_session_id)
      when is_binary(anonymous_session_id) do
    Offer
    |> where([o], o.product_id == ^product_id and o.anonymous_session_id == ^anonymous_session_id)
    |> preload(:product)
    |> Repo.one()
  end

  def change_offer(%Offer{} = offer, attrs \\ %{}) do
    Offer.visitor_changeset(offer, attrs)
  end

  def upsert_visitor_offer(%Product{} = product, anonymous_session_id, attrs)
      when is_binary(anonymous_session_id) do
    existing_offer = get_offer_for_session(product.id, anonymous_session_id)

    with :ok <- throttle(existing_offer, attrs),
         {:ok, offer} <-
           insert_or_update_offer(product, anonymous_session_id, existing_offer, attrs) do
      offer = Repo.preload(offer, :product)
      broadcast_offer(product.user_id, {:offer_upserted, offer})
      broadcast_visitor_offer(anonymous_session_id, {:offer_saved, offer})
      {:ok, offer}
    end
  end

  def update_offer_status(%Scope{} = scope, id, status) when status in ["accepted", "rejected"] do
    offer = get_scoped_offer!(scope, id)

    with {:ok, offer} <- offer |> Offer.status_changeset(status) |> Repo.update() do
      offer = Repo.preload(offer, :product)
      broadcast_offer(scope.user.id, {:offer_updated, offer})
      broadcast_visitor_offer(offer.anonymous_session_id, {:offer_updated, offer})
      {:ok, offer}
    end
  end

  defp insert_or_update_offer(product, anonymous_session_id, nil, attrs) do
    %Offer{product_id: product.id, anonymous_session_id: anonymous_session_id}
    |> Offer.visitor_changeset(attrs)
    |> Repo.insert()
  end

  defp insert_or_update_offer(_product, _anonymous_session_id, %Offer{} = offer, attrs) do
    offer
    |> Offer.visitor_changeset(attrs)
    |> Repo.update()
  end

  defp get_scoped_offer!(%Scope{} = scope, id) do
    from(o in Offer,
      join: p in assoc(o, :product),
      where: o.id == ^id and p.user_id == ^scope.user.id,
      preload: [product: p]
    )
    |> Repo.one!()
  end

  defp throttle(nil, _attrs), do: :ok

  defp throttle(%Offer{updated_at: nil}, _attrs), do: :ok

  defp throttle(%Offer{body: body, updated_at: updated_at}, attrs) do
    new_body = attrs["body"] || attrs[:body]

    if String.trim(to_string(body)) == String.trim(to_string(new_body)) &&
         DateTime.diff(DateTime.utc_now(:second), updated_at, :second) < @throttle_seconds do
      {:error, :throttled}
    else
      :ok
    end
  end

  defp broadcast_offer(user_id, message) do
    Phoenix.PubSub.broadcast(Bazar.PubSub, admin_topic(user_id), message)
  end

  defp broadcast_visitor_offer(anonymous_session_id, message) do
    Phoenix.PubSub.broadcast(Bazar.PubSub, visitor_topic(anonymous_session_id), message)
  end

  defp admin_topic(user_id), do: "user:#{user_id}:offers"

  defp visitor_topic(anonymous_session_id),
    do: "#{@visitor_topic_prefix}:#{anonymous_session_id}:offers"
end
