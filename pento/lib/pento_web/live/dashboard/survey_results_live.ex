defmodule PentoWeb.Admin.SurveyResultsLive do
  use PentoWeb, :live_component

  alias Pento.Catalog
  alias Contex.Plot
  alias Pento.Survey.Demographic

  @gender_options Demographic.gender_options()
  @age_group_options Demographic.age_group_options()

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_age_group_filter()
     |> assign_products_with_average_ratings()
     |> assign_dataset()
     |> assign_chart()
     |> assign_chart_svg()
     |> assign(gender_options: @gender_options)
     |> assign(age_group_options: @age_group_options)}
  end

  def handle_event("change_age_group", %{"age_group_filter" => filter}, socket) do
    {:noreply,
     socket
     |> assign_age_group_filter(filter)
     |> assign_products_with_average_ratings()
     |> assign_dataset()
     |> assign_chart()
     |> assign_chart_svg()}
  end

  defp assign_age_group_filter(socket) do
    assign(socket, :age_group_filter, "all")
  end

  defp assign_age_group_filter(socket, filter) when filter in @age_group_options do
    assign(socket, :age_group_filter, filter)
  end

  defp assign_products_with_average_ratings(
         %{assigns: %{age_group_filter: age_group_filter}} = socket
       ) do
    socket
    |> assign(
      :products_with_average_ratings,
      get_products_with_average_ratings(%{age_group_filter: age_group_filter})
    )
  end

  defp assign_dataset(
         %{
           assigns: %{
             products_with_average_ratings: products_with_average_ratings
           }
         } = socket
       ) do
    assign(socket, :dataset, make_bar_chart_dataset(products_with_average_ratings))
  end

  defp assign_chart(%{assigns: %{dataset: dataset}} = socket) do
    assign(socket, :chart, make_bar_chart(dataset))
  end

  defp assign_chart_svg(%{assigns: %{chart: chart}} = socket) do
    assign(socket, :chart_svg, render_bar_chart(chart))
  end

  defp make_bar_chart_dataset(data) do
    Contex.Dataset.new(data)
  end

  defp make_bar_chart(dataset) do
    Contex.BarChart.new(dataset)
  end

  defp render_bar_chart(chart) do
    Plot.new(500, 400, chart)
    |> Plot.titles(title(), subtitle())
    |> Plot.axis_labels(x_axis(), y_axis())
    |> Plot.to_svg()
  end

  defp title, do: "Product Ratings"

  defp subtitle, do: "average star ratings per product"

  defp x_axis, do: "products"

  defp y_axis, do: "stars"

  defp get_products_with_average_ratings(filter) do
    case Catalog.products_with_average_ratings(filter) do
      [] -> Catalog.products_with_zero_ratings()
      products -> products
    end
  end
end
