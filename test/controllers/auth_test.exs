defmodule Rumbl.AuthTest do
  use Rumbl.ConnCase
  alias Rumbl.Auth

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(Rumbl.Router, :browser)
      |> get("/")

    {:ok, %{conn: conn}}
  end

  test "authenticate_user halts when no current_user exists",
    %{conn: conn} do
      conn =
      conn
      |> assign(:current_user, nil)
      |> Auth.authenticate_user([])

      assert conn.halted
  end

  test "authenticate_user continues when current_user exists",
    %{conn: conn} do
      conn
      |> assign(:current_user, %Rumbl.User{})
      |> Auth.authenticate_user([])

      refute conn.halted
  end

  test "login puts user in the session",
    %{conn: conn} do
    login_conn =
      conn
      |> Auth.login(%Rumbl.User{id: 123})
      |> send_resp(:ok, "")

    next_conn = get(login_conn, "/")
    assert get_session(next_conn, :user_id) == 123
   end

  test "logout drops session", %{conn: conn}  do
    logout_conn =
      conn
      |> put_session(:user_id, 123)
      |> Auth.logout()
      |> send_resp(:ok, "")

    next_conn = get(logout_conn, "/")
    refute get_session(next_conn, :user_id)
  end

  test "call places user from sessions into assigns", %{conn: conn} do
    user = insert_user()
    conn =
      conn
      |> put_session(:user_id, user.id)
      |> Auth.call(Repo)

    assert conn.assigns.current_user.id == user.id
  end

  test "call with no session sets current user to nil", %{conn: conn} do
    conn = Auth.call(conn, Repo)
    assert conn.assigns.current_user == nil
  end

  test "login with a valid username and pass", %{conn: conn} do
    user = insert_user(email: "me12345678910", password: "secret", name: "mine")
    {:ok, conn} =
      Auth.login_by_email_and_pass(conn, "me12345678910", "secret", repo: Repo)

    assert conn.assigns.current_user.id == user.id
  end

  test "login with a not found user", %{conn: conn} do
    assert {:error, :not_found, _conn} =
      Auth.login_by_email_and_pass(conn, "me12345678910", "secret", repo: Repo)
  end

  test "login with password mismatch", %{conn: conn} do
    _ = insert_user(email: "me12345678910", password: "secret", name: "mine")
    assert {:error, :unauthorized, _conn} =
      Auth.login_by_email_and_pass(conn, "me12345678910", "wrong", repo: Repo)
  end
end
