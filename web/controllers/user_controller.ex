defmodule Rumbl.UserController do
  use Rumbl.Web, :controller

  def index(conn, _params) do
    users = Rumbl.Repo.all(Rumbl.User)
    render conn, "index.html", users: users
  end

  def show(conn, %{"id" => id}) do
    {int_id, _} = Integer.parse(id)
    user = Rumbl.Repo.get(Rumbl.User, int_id)
    render conn, "show.html", user: user
  end

end
