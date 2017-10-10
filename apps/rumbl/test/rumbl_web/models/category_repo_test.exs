defmodule Rumbl.CategoryRepoTest do
  use Rumbl.DataCase
  alias Rumbl.Category

  test "alphabetically/1 orders by name" do
    Repo.insert!(%Category{name: "c"})
    Repo.insert!(%Category{name: "a"})
    Repo.insert!(%Category{name: "b"})

    query = Category |> Category.alphabetically()
    query = from c in query, select: c.name
    assert Repo.all(query) == ["a", "b", "c"]
    assert Repo.all(query) == ~w(a b c)
  end
end
