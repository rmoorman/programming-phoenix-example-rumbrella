defmodule Rumbl.Videos.Video do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rumbl.Videos.Video

  @primary_key {:id, Rumbl.Permalink, autogenerate: true}

  schema "videos" do
    field :description, :string
    field :title, :string
    field :url, :string
    field :slug, :string
    #field :user_id, :id
    belongs_to :user, Rumbl.User
    belongs_to :category, Rumbl.Category
    has_many :annotations, Rumbl.Videos.Annotation

    timestamps()
  end


  @permitted_fields [:url, :title, :description, :category_id]
  @required_fields [:url, :title, :description]

  @doc false
  def changeset(%Video{} = video, attrs) do
    video
    |> cast(attrs, @permitted_fields)
    |> slugify_title()
    |> assoc_constraint(:category)
    |> validate_required(@required_fields)
  end

  defp slugify_title(changeset) do
    if title = get_change(changeset, :title) do
      put_change(changeset, :slug, slugify(title))
    else
      changeset
    end
  end

  defp slugify(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/u, "-")
  end
end


defimpl Phoenix.Param, for: Rumbl.Videos.Video do
  def to_param(%{slug: slug, id: id}) do
    "#{id}-#{slug}"
  end
end
