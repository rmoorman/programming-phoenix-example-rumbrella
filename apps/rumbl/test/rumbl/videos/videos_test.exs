defmodule Rumbl.VideosTest do
  use Rumbl.DataCase

  alias Rumbl.Videos

  describe "videos" do
    alias Rumbl.Videos.Video

    @valid_attrs %{description: "some description", title: "some title", url: "some url"}
    @update_attrs %{description: "some updated description", title: "some updated title", url: "some updated url"}
    @invalid_attrs %{description: nil, title: nil, url: nil}

    def video_fixture(attrs \\ %{}) do
      {:ok, video} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Videos.create_video()

      video
    end

    test "list_videos/0 returns all videos" do
      video = video_fixture()
      assert Videos.list_videos() == [video]
    end

    test "get_video!/1 returns the video with given id" do
      video = video_fixture()
      assert Videos.get_video!(video.id) == video
    end

    test "create_video/1 with valid data creates a video" do
      assert {:ok, %Video{} = video} = Videos.create_video(@valid_attrs)
      assert video.description == "some description"
      assert video.title == "some title"
      assert video.url == "some url"
    end

    test "create_video/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Videos.create_video(@invalid_attrs)
    end

    test "update_video/2 with valid data updates the video" do
      video = video_fixture()
      assert {:ok, video} = Videos.update_video(video, @update_attrs)
      assert %Video{} = video
      assert video.description == "some updated description"
      assert video.title == "some updated title"
      assert video.url == "some updated url"
    end

    test "update_video/2 with invalid data returns error changeset" do
      video = video_fixture()
      assert {:error, %Ecto.Changeset{}} = Videos.update_video(video, @invalid_attrs)
      assert video == Videos.get_video!(video.id)
    end

    test "delete_video/1 deletes the video" do
      video = video_fixture()
      assert {:ok, %Video{}} = Videos.delete_video(video)
      assert_raise Ecto.NoResultsError, fn -> Videos.get_video!(video.id) end
    end

    test "change_video/1 returns a video changeset" do
      video = video_fixture()
      assert %Ecto.Changeset{} = Videos.change_video(video)
    end
  end

  describe "annotations" do
    alias Rumbl.Videos.Annotation

    @valid_attrs %{at: 42, body: "some body"}
    @update_attrs %{at: 43, body: "some updated body"}
    @invalid_attrs %{at: nil, body: nil}

    def annotation_fixture(attrs \\ %{}) do
      {:ok, annotation} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Videos.create_annotation()

      annotation
    end

    test "list_annotations/0 returns all annotations" do
      annotation = annotation_fixture()
      assert Videos.list_annotations() == [annotation]
    end

    test "get_annotation!/1 returns the annotation with given id" do
      annotation = annotation_fixture()
      assert Videos.get_annotation!(annotation.id) == annotation
    end

    test "create_annotation/1 with valid data creates a annotation" do
      assert {:ok, %Annotation{} = annotation} = Videos.create_annotation(@valid_attrs)
      assert annotation.at == 42
      assert annotation.body == "some body"
    end

    test "create_annotation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Videos.create_annotation(@invalid_attrs)
    end

    test "update_annotation/2 with valid data updates the annotation" do
      annotation = annotation_fixture()
      assert {:ok, annotation} = Videos.update_annotation(annotation, @update_attrs)
      assert %Annotation{} = annotation
      assert annotation.at == 43
      assert annotation.body == "some updated body"
    end

    test "update_annotation/2 with invalid data returns error changeset" do
      annotation = annotation_fixture()
      assert {:error, %Ecto.Changeset{}} = Videos.update_annotation(annotation, @invalid_attrs)
      assert annotation == Videos.get_annotation!(annotation.id)
    end

    test "delete_annotation/1 deletes the annotation" do
      annotation = annotation_fixture()
      assert {:ok, %Annotation{}} = Videos.delete_annotation(annotation)
      assert_raise Ecto.NoResultsError, fn -> Videos.get_annotation!(annotation.id) end
    end

    test "change_annotation/1 returns a annotation changeset" do
      annotation = annotation_fixture()
      assert %Ecto.Changeset{} = Videos.change_annotation(annotation)
    end
  end
end
