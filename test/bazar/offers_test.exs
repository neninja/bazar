defmodule Bazar.OffersTest do
  use Bazar.DataCase

  import Bazar.AccountsFixtures, only: [user_scope_fixture: 0]
  import Bazar.CatalogFixtures

  alias Bazar.Offers
  alias Bazar.Offers.Offer

  describe "offers" do
    test "upsert_visitor_offer/3 creates one offer per product and anonymous session" do
      scope = user_scope_fixture()
      product = product_fixture(scope)

      assert {:ok, %Offer{} = offer} =
               Offers.upsert_visitor_offer(product, "anon-1", %{"body" => "Pago R$ 90"})

      assert offer.status == "pending"
      assert offer.product_id == product.id
      assert offer.anonymous_session_id == "anon-1"

      assert {:ok, %Offer{} = updated_offer} =
               Offers.upsert_visitor_offer(product, "anon-1", %{"body" => "Pago R$ 100"})

      assert updated_offer.id == offer.id
      assert updated_offer.body == "Pago R$ 100"
      assert updated_offer.status == "pending"
    end

    test "editing an accepted offer resets it to pending" do
      scope = user_scope_fixture()
      product = product_fixture(scope)
      offer = offer_fixture(product, "anon-2")

      assert {:ok, accepted_offer} = Offers.update_offer_status(scope, offer.id, "accepted")
      assert accepted_offer.status == "accepted"

      assert {:ok, edited_offer} =
               Offers.upsert_visitor_offer(product, "anon-2", %{"body" => "Atualizei para R$ 110"})

      assert edited_offer.id == offer.id
      assert edited_offer.status == "pending"
    end

    test "list_offers/1 returns only offers for products owned by the scope" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      product = product_fixture(scope)
      other_product = product_fixture(other_scope)
      offer = offer_fixture(product, "anon-3")
      _other_offer = offer_fixture(other_product, "anon-4")

      assert [%Offer{id: offer_id, product: loaded_product}] = Offers.list_offers(scope)
      assert offer_id == offer.id
      assert loaded_product.id == product.id
      assert [%Offer{}] = Offers.list_offers(other_scope)
    end

    test "update_offer_status/3 requires scoped product ownership" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      product = product_fixture(scope)
      offer = offer_fixture(product, "anon-5")

      assert_raise Ecto.NoResultsError, fn ->
        Offers.update_offer_status(other_scope, offer.id, "accepted")
      end
    end

    test "repeated identical proposal is throttled" do
      scope = user_scope_fixture()
      product = product_fixture(scope)

      assert {:ok, _offer} =
               Offers.upsert_visitor_offer(product, "anon-6", %{"body" => "Pago R$ 90"})

      assert {:error, :throttled} =
               Offers.upsert_visitor_offer(product, "anon-6", %{"body" => "Pago R$ 90"})
    end
  end
end
