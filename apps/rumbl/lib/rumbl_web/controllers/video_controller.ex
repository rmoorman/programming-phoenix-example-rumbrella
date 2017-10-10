defmodule RumblWeb.VideoController do
  use RumblWeb, :controller

  alias Rumbl.Repo
  alias Rumbl.Videos
  alias Rumbl.Videos.Video
  alias Rumbl.Category

  plug :load_categories when action in [:new, :create, :edit, :update]

  defp load_categories(conn, _) do
    query =
      Category
      |> Category.alphabetically
      |> Category.names_and_ids
    categories = Repo.all query
    assign conn, :categories, categories
  end

  def index(conn, _params, user) do
    videos = Rumbl.Repo.all(user_videos(user))
    render(conn, "index.html", videos: videos)
  end

  def new(conn, _params, _user) do
    changeset = Videos.change_video(%Video{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"video" => video_params}, user) do
    case Videos.create_video_for_user(video_params, user) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video created successfully.")
        |> redirect(to: video_path(conn, :show, video))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    video = Rumbl.Repo.get!(user_videos(user), id)
    render(conn, "show.html", video: video)
  end

  def edit(conn, %{"id" => id}, user) do
    video = Rumbl.Repo.get!(user_videos(user), id)
    changeset = Videos.change_video(video)
    render(conn, "edit.html", video: video, changeset: changeset)
  end

  def update(conn, %{"id" => id, "video" => video_params}, user) do
    video = Rumbl.Repo.get!(user_videos(user), id)

    case Videos.update_video(video, video_params) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video updated successfully.")
        |> redirect(to: video_path(conn, :show, video))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", video: video, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    video = Rumbl.Repo.get!(user_videos(user), id)
    {:ok, _video} = Videos.delete_video(video)

    conn
    |> put_flash(:info, "Video deleted successfully.")
    |> redirect(to: video_path(conn, :index))
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
  end

  defp user_videos(user) do
    Ecto.assoc(user, :videos)
  end
end
