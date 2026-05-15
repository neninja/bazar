defmodule Bazar.Repo.Migrations.CreateOffers do
  use Ecto.Migration

  def change do
    create table(:offers) do
      add :anonymous_session_id, :string, null: false
      add :body, :text, null: false
      add :status, :string, null: false, default: "pending"
      add :product_id, references(:products, type: :id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:offers, [:product_id])
    create index(:offers, [:anonymous_session_id])
    create index(:offers, [:status])

    create unique_index(:offers, [:product_id, :anonymous_session_id],
             name: :offers_product_id_anonymous_session_id_index
           )
  end
end
