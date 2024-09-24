defmodule Pento.CatalogTest do
  use Pento.DataCase

  alias Pento.Catalog

  describe "products" do
    alias Pento.Catalog.Product

    import Pento.CatalogFixtures

    @invalid_attrs %{name: nil, description: nil, unit_price: nil, sku: nil}

    setup do
      %{product: product_fixture()}
    end

    test "list_products/0 returns all products", %{product: product} do
      assert Catalog.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id", %{product: product} do
      assert Catalog.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      sku = unique_product_sku()

      valid_attrs = %{
        name: "some name",
        description: "some description",
        unit_price: 120.5,
        sku: sku
      }

      assert {:ok, %Product{} = product} = Catalog.create_product(valid_attrs)
      assert product.name == "some name"
      assert product.description == "some description"
      assert product.unit_price == 120.5
      assert product.sku == sku
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product", %{product: product} do
      update_attrs = %{
        name: "some updated name",
        description: "some updated description",
        unit_price: 456.7,
        sku: "1234567"
      }

      assert {:ok, %Product{} = product} = Catalog.update_product(product, update_attrs)
      assert product.name == "some updated name"
      assert product.description == "some updated description"
      assert product.unit_price == 456.7
      assert product.sku == "1234567"
    end

    test "update_product/2 with invalid data returns error changeset", %{product: product} do
      assert {:error, %Ecto.Changeset{}} = Catalog.update_product(product, @invalid_attrs)
      assert product == Catalog.get_product!(product.id)
    end

    test "delete_product/1 deletes the product", %{product: product} do
      assert {:ok, %Product{}} = Catalog.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset", %{product: product} do
      assert %Ecto.Changeset{} = Catalog.change_product(product)
    end
  end
end
