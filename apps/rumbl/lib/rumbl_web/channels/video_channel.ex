defmodule RumblWeb.VideoChannel do
  use RumblWeb, :channel
  alias RumblWeb.AnnotationView
  import Ecto.Query

  def join("videos:" <> video_id, params, socket) do
    last_seen_id = params["last_seen_id"] || 0
    video_id = String.to_integer(video_id)
    video = Rumbl.Videos.get_video!(video_id)

    annotations = Rumbl.Repo.all(
      from a in Ecto.assoc(video, :annotations),
        where: a.id > ^last_seen_id,
        order_by: [asc: a.at, asc: a.id],
        limit: 200,
        preload: [:user]
    )
    res = %{annotations: Phoenix.View.render_many(annotations, AnnotationView, "annotation.json")}

    {:ok, res, assign(socket, :video_id, video_id)}
  end

  def handle_in(event, params, socket) do
    user = Rumbl.Repo.get(Rumbl.User, socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  def handle_in("new_annotation", params, user, socket) do
    changeset =
      user
      |> Ecto.build_assoc(:annotations, video_id: socket.assigns.video_id)
      |> Rumbl.Videos.Annotation.changeset(params)

    case Rumbl.Repo.insert(changeset) do
      {:ok, annotation} ->
        broadcast_annotation(socket, annotation)
        Task.start_link(fn -> compute_additional_info(annotation, socket) end)
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  defp broadcast_annotation(socket, annotation) do
    annotation = Rumbl.Repo.preload(annotation, :user)
    rendered_annotation = RumblWeb.AnnotationView.render("annotation.json", %{
      annotation: annotation,
    })
    broadcast! socket, "new_annotation", rendered_annotation
  end

  defp compute_additional_info(annotation, socket) do
    for result <- InfoSys.compute(annotation.body, limit: 1, timeout: 10_000) do
      attrs = %{url: result.url, body: result.text, at: annotation.at}
      info_changeset =
        Rumbl.Repo.get_by!(Rumbl.User, username: result.backend)
        |> Ecto.build_assoc(:annotations, video_id: annotation.video_id)
        |> Rumbl.Videos.Annotation.changeset(attrs)

      case Rumbl.Repo.insert(info_changeset) do
        {:ok, info_annotation} -> broadcast_annotation(socket, info_annotation)
        {:error, _changeset} -> :ignore
      end
    end
  end
end
