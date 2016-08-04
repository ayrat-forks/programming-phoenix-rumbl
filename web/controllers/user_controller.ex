defmodule Rumbl.UserController do
  use Rumbl.Web, :controller
  plug :authenticate_user when action in [:index, :show]
  alias Rumbl.User

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def index(conn, _params) do
    users = Rumbl.Repo.all(Rumbl.User)
    render conn, "index.html", users: users
  end

  def show(conn, %{"id" => id}) do
    {int_id, _} = Integer.parse(id)
    user = Rumbl.Repo.get(Rumbl.User, int_id)
    render conn, "show.html", user: user
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> Rumbl.Auth.login(user)
        |> put_flash(:info, "#{user.name} created!")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end
end
