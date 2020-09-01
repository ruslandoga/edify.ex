defmodule EWeb.ErrorViewTest do
  use EWeb.ConnCase, async: true
  alias EWeb.ErrorView

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render(ErrorView, "404.json", []) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500.json" do
    assert render(ErrorView, "500.json", []) ==
             %{errors: %{detail: "Internal Server Error"}}
  end

  test "renders changeset.json" do
    data = %{}
    types = %{name: :string}
    params = %{}

    changeset =
      {data, types}
      |> Ecto.Changeset.cast(params, Map.keys(types))
      |> Ecto.Changeset.validate_required([:name])

    assert render(ErrorView, "changeset.json", changeset: changeset) == %{
             errors: %{detail: %{name: ["can't be blank"]}}
           }
  end
end
