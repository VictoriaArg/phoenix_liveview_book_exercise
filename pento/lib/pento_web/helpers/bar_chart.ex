defmodule PentoWeb.Helpers.BarChart do
  alias Contex.{Dataset, BarChart, Plot}

  def make_dataset(data) do
    Dataset.new(data)
  end

  def make(dataset) do
    BarChart.new(dataset)
  end

  def render(chart) do
    Plot.new(500, 400, chart)
    |> Plot.titles(title(), subtitle())
    |> Plot.axis_labels(x_axis(), y_axis())
    |> Plot.to_svg()
  end

  defp title, do: "Product Ratings"

  defp subtitle, do: "average star ratings per product"

  defp x_axis, do: "products"

  defp y_axis, do: "stars"
end
