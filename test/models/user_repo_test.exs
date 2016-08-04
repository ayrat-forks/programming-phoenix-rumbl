defmodule Rumbl.UserRepoTest do
  use Rumbl.ModelCase
  alias Rumbl.User

  @valid_attrs %{name: "A User", email: "eva555@gmail.com"}

  test "converts unique_constraint on username to error" do
    insert_user(email: "eric555@gmail.com")
    attrs = Map.put(@valid_attrs, :email, "eric555@gmail.com")
    changeset = User.changeset(%User{}, attrs)

    assert {:error, changeset} = Repo.insert(changeset)
    assert {:email, {"has already been taken", []}} in changeset.errors
  end
end
