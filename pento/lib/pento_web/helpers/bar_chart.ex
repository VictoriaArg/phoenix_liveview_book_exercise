defmodule PentoWeb.Helpers.BarChart do
  alias Contex.{Dataset, BarChart, Plot}

  def make_dataset(data) do
    Dataset.new(data)
  end

  def make(dataset) do
    BarChart.new(dataset)
    |> BarChart.colours(["06BF9C"])
  end

  def render(chart) do
    Plot.new(500, 400, chart)
    |> Plot.titles(title(), "")
    |> Plot.to_svg()
  end

  defp title, do: "Average star ratings per product"
end
