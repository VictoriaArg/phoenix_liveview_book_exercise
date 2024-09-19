defmodule Pento.Repo.Migrations.ChangeSkuToString do
  use Ecto.Migration

  def change do
    alter table(:products) do
      modify :sku, :string
    end
  end
end
