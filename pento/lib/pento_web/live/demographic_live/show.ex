defmodule PentoWeb.DemographicLive.Show do
  use Phoenix.Component

  alias PentoWeb.CoreComponents
  alias Pento.Survey.Demographic

  attr :demographic, Demographic, required: true

  def details(assigns) do
    ~H"""
    <div>
      <h2 class="font-medium text-2xl mb-8">Demographics</h2>
      <CoreComponents.table id="demographic-table" rows={[@demographic]}>
        <:col :let={demographic} label="Gender">
          <%= demographic.gender %>
        </:col>
        <:col :let={demographic} label="Year of Birth">
          <%= demographic.year_of_birth %>
        </:col>
        <:col :let={demographic} label="Education Level">
          <%= demographic.education_level %>
        </:col>
      </CoreComponents.table>
    </div>
    """
  end
end
