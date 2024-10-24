defmodule PentoWeb.Admin.SurveyResultsLive do
  use PentoWeb, :live_component

  alias Pento.Catalog
  alias Pento.Survey.Demographic
  alias PentoWeb.Helpers.BarChart

  @gender_options Enum.concat(Demographic.gender_options(), ["all"])
  @age_group_options Demographic.age_group_options()

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_age_group_filter()
     |> assign_gender_filter()
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

  def handle_event("change_gender", %{"gender_filter" => filter}, socket) do
    {:noreply,
     socket
     |> assign_gender_filter(filter)
     |> assign_products_with_average_ratings()
     |> assign_dataset()
     |> assign_chart()
     |> assign_chart_svg()}
  end

  def assign_gender_filter(socket) do
    assign(socket, :gender_filter, "all")
  end

  def assign_gender_filter(socket, filter) when filter in @gender_options do
    assign(socket, :gender_filter, filter)
  end

  def assign_age_group_filter(socket) do
    assign(socket, :age_group_filter, "all")
  end

  def assign_age_group_filter(socket, filter) when filter in @age_group_options do
    assign(socket, :age_group_filter, filter)
  end

  def assign_products_with_average_ratings(
        %{assigns: %{age_group_filter: age_group_filter, gender_filter: gender_filter}} = socket
      ) do
    socket
    |> assign(
      :products_with_average_ratings,
      get_products_with_average_ratings(%{
        age_group_filter: age_group_filter,
        gender_filter: gender_filter
      })
    )
  end

  defp assign_dataset(
         %{
           assigns: %{
             products_with_average_ratings: products_with_average_ratings
           }
         } = socket
       ) do
    assign(socket, :dataset, BarChart.make_dataset(products_with_average_ratings))
  end

  defp assign_chart(%{assigns: %{dataset: dataset}} = socket) do
    assign(socket, :chart, BarChart.make(dataset))
  end

  defp assign_chart_svg(%{assigns: %{chart: chart}} = socket) do
    assign(socket, :chart_svg, BarChart.render(chart))
  end

  defp get_products_with_average_ratings(filter) do
    case Catalog.products_with_average_ratings(filter) do
      [] -> Catalog.products_with_zero_ratings()
      products -> products
    end
  end
end
