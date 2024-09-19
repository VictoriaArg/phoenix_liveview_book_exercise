defmodule Pento.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "products" do
    field :name, :string
    field :description, :string
    field :unit_price, :float
    field :sku, :string
    field :image_upload, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :description, :unit_price, :sku, :image_upload])
    |> validate_required([:name, :description, :unit_price, :sku])
    |> unique_constraint(:sku)
    |> validate_format(:sku, ~r/^\d{7}$/)
  end

  def unit_price_changeset(product, attrs) do
    product
    |> cast(attrs, [:unit_price])
    |> validate_required([:unit_price])
    |> validate_number(:unit_price, greater_than: 0)
    |> validate_number(:unit_price, less_than: product.unit_price)
  end

  def search_by_sku_query(value) do
    from p in Pento.Catalog.Product,
      where: p.sku == ^value
  end
end
