defmodule FirestormData.Schema.PostTest do
  alias FirestormData.{
    Category,
    Thread,
    Post,
    Repo,
    User,
    View,
    Viewable,
  }
  use ExUnit.Case

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    user =
      %User{username: "knewter"}
      |> Repo.insert!
    {:ok, %{user: user}}
  end

  test "it requires a thread_id" do
    changeset =
      %Post{}
        |> Post.changeset(%{})

    refute changeset.valid?
    assert changeset.errors[:thread_id] == {"can't be blank", [validation: :required]}
  end

  test "it can have many views by users", %{user: user} do
    {:ok, {_elixir, _tests_thread, post}} = create_post(user)
    {:ok, _} = create_view(post, user)
    {:ok, _} = create_view(post, user)
    {:ok, _} = create_view(post, user)

    assert Viewable.view_count(post) == 3
  end

  test "it requires a body" do
    changeset =
      %Post{}
        |> Post.changeset(%{})

    refute changeset.valid?
    assert changeset.errors[:body] == {"can't be blank", [validation: :required]}
  end

  test "it requires a user_id" do
    changeset =
      %Post{}
        |> Post.changeset(%{})

    refute changeset.valid?
    assert changeset.errors[:user_id] == {"can't be blank", [validation: :required]}
  end

  test "it belongs to a category through its thread", %{user: user} do
    {:ok, {category, thread, saved_post}} = create_post(user)

    fetched_post =
      Post
      |> Repo.get(saved_post.id)
      |> Repo.preload([:thread, :category])

    assert fetched_post.thread.id == thread.id
    assert fetched_post.category.id == category.id
  end

  defp create_category_and_thread(category_title, thread_title) do
    category =
      %Category{title: category_title}
      |> Repo.insert!

    thread =
      %Thread{category_id: category.id, title: thread_title}
      |> Repo.insert!

    {category, thread}
  end

  defp create_post(user) do
    {category, thread} = create_category_and_thread("Elixir", "ITT: Tests")

    attributes =
      %{
        thread_id: thread.id,
        body: "some body",
        user_id: user.id
      }

    changeset =
      %Post{}
      |> Post.changeset(attributes)

    {:ok, saved_post} = Repo.insert(changeset)
    {:ok, {category, thread, saved_post}}
  end

  defp create_view(thread, user) do
    thread
    |> Ecto.build_assoc(:views, %{user_id: user.id})
    |> View.changeset(%{})
    |> Repo.insert
  end
end
