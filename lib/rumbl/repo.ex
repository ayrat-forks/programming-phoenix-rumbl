defmodule Rumbl.Repo do
  # use Ecto.Repo, otp_app: :rumbl
  @moduledoc """
  in-memory repository
  """
  def all(Rumbl.User) do
    [%Rumbl.User{id: 1, name: "John Lennon", email: "lennon@gmail.com", password: "beatle1"},
     %Rumbl.User{id: 2, name: "Paul McCartney", email: "mccartney@gmail.com", password: "beatle2"},
     %Rumbl.User{id: 3, name: "George Harrison", email: "harrison@gmail.com", password: "beatle3"},
     %Rumbl.User{id: 4, name: "Ringo Starr", email: "starr@gmail.com", password: "beatle4"}]
  end

  def get(module, id) do
    Enum.find(all(module), fn map ->
                            map.id == id
                          end
            )
  end

  def all(_module), do: []

  def get_by(module, params) do
    Enum.find(all(module), fn map ->
                            Enum.all?(params,
                                      fn{key, val} ->
                                        Map.get(map,key) == val
                                      end
                                     )
                          end
             )
  end
end
