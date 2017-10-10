defmodule Rumbl.Videos.Annotation do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rumbl.Videos.Annotation


  schema "annotations" do
    field :at, :integer
    field :body, :string
    #field :user_id, :id
    belongs_to :user, Rumbl.User
    #field :video_id, :id
    belongs_to :video, Rumbl.Videos.Video

    timestamps()
  end

  @doc false
  def changeset(%Annotation{} = annotation, attrs) do
    annotation
    |> cast(attrs, [:body, :at])
    |> validate_required([:body, :at])
  end
end
