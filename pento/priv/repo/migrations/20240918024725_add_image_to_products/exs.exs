defmodule :"Elixir.Pento.Repo.Migrations.AddImageToProducts.exs" do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :image_upload, :string
    end
  end
end
