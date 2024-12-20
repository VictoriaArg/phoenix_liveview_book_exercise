defmodule PentoWeb.ProductLiveTest do
  use PentoWeb.ConnCase

  import Phoenix.LiveViewTest

  @create_attrs %{name: "some name", description: "some description", unit_price: 120.5, sku: 42}
  @update_attrs %{
    name: "some updated name",
    description: "some updated description",
    unit_price: 456.7,
    sku: 43
  }
  @invalid_attrs %{name: nil, description: nil, unit_price: nil, sku: nil}

  describe "Index" do
    setup [:create_product, :register_and_log_in_user]

    test "lists all products", %{conn: conn, product: product} do
      {:ok, _index_live, html} = live(conn, ~p"/products")

      assert html =~ "Listing Products"
      assert html =~ product.name
    end

    test "searching for products filters the product list", %{conn: conn, product: product} do
      %{product: new_product} =
        create_product(%{description: "latest game", name: "new game", sku: "1234567"})

      {:ok, index_live, html} = live(conn, ~p"/products")

      assert html =~ new_product.name
      assert html =~ product.name

      updated_index =
        index_live
        |> form("#product-search", "search[search_value]": "1234567")
        |> render_change()

      assert updated_index =~ new_product.name
      refute updated_index =~ product.name
    end

    test "searching for non-existent products shows an empty result message", %{
      conn: conn,
      product: product
    } do
      {:ok, index_live, html} = live(conn, ~p"/products")

      assert html =~ product.name

      updated_index =
        index_live
        |> form("#product-search", "search[search_value]": "0987654")
        |> render_change()

      assert updated_index =~ "No products found"
      refute updated_index =~ product.name
    end

    test "saves new product", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/products")

      assert index_live |> element("#new-product", "New Product") |> render_click() =~
               "New Product"

      assert_patch(index_live, ~p"/products/new")

      assert index_live
             |> form("#product-form", product: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#product-form", product: @create_attrs)
             |> render_submit()

      html = render(index_live)
      assert html =~ "some name"
    end

    test "updates product in listing", %{conn: conn, product: product} do
      {:ok, index_live, _html} = live(conn, ~p"/products")

      assert index_live |> element("#products-#{product.id} a", "Edit") |> render_click() =~
               "Edit Product"

      assert_patch(index_live, ~p"/products/#{product}/edit")

      assert index_live
             |> form("#product-form", product: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#product-form", product: @update_attrs)
             |> render_submit()

      html = render(index_live)
      assert html =~ "some updated name"
    end

    test "deletes product in listing", %{conn: conn, product: product} do
      {:ok, index_live, _html} = live(conn, ~p"/products")

      assert index_live |> element("#products-#{product.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#products-#{product.id}")
    end
  end

  describe "Show" do
    setup [:create_product, :register_and_log_in_user]

    test "displays product", %{conn: conn, product: product} do
      {:ok, _show_live, html} = live(conn, ~p"/products/#{product}")

      assert html =~ "Show Product"
      assert html =~ product.name
    end

    test "updates product within modal", %{conn: conn, product: product} do
      {:ok, show_live, _html} = live(conn, ~p"/products/#{product}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Product"

      assert_patch(show_live, ~p"/products/#{product}/show/edit")

      assert show_live
             |> form("#product-form", product: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#product-form", product: @update_attrs)
             |> render_submit()

      html = render(show_live)
      assert html =~ "some updated name"
    end
  end
end
