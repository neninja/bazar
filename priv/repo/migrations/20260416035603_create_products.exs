defmodule Bazar.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :image_url, :string
      add :ludopedia_link, :string
      add :description, :text
      add :sale_reason, :text
      add :condition, :string
      add :recommendation, :text
      add :tags, {:array, :string}
      add :price, :decimal
      add :trade_policy, :string
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:products, [:user_id])
  end
end
