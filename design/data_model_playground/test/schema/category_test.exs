defmodule DataModelPlayground.Schema.CategoryTest do
  alias DataModelPlayground.Category
  use ExUnit.Case
  alias DataModelPlayground.Repo
  @valid_attributes %{
    title: "Something"
  }

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "it requires a title" do
    changeset =
      %Category{}
        |> Category.changeset(Map.delete(@valid_attributes, :title))

    refute changeset.valid?
    assert changeset.errors[:title] == {"can't be blank", [validation: :required]}
  end

  test "adding and retrieving categories" do
    # NOTE: We will not be doing repo stuff in the modules but i'm in a hurry
    assert [] == Category.categories

    Category.add("OTP")
    Category.add("Phoenix")

    assert [%{title: "OTP"}, %{title: "Phoenix"}] = Category.categories
  end

  test "tree structure" do
    {elixir, otp} = make_elixir_otp_tree()
    children =
      elixir
        |> Category.children
        |> Repo.all

    assert children == [otp]
  end

  defp make_elixir_otp_tree() do
    {:ok, elixir} =
      %Category{}
        |> Category.changeset(%{title: "Elixir"})
        |> Repo.insert

    {:ok, otp} =
      %Category{}
        |> Category.changeset(%{title: "OTP", parent_id: elixir.id})
        |> Repo.insert

    {elixir, otp}
  end
end