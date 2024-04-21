defmodule EmailIdCheck do
  import Ecto.Query

  def check(id, email) do
    user_query =
      from(u in Users.User,
        where: u.id == ^id or ilike(u.email, ^email),
        select: 1
      )

    user2_query =
      from(u in Users2.User,
        where: u.id == ^id or ilike(u.email, ^email),
        select: 1
      )

    user_exists = Users.Repo.exists?(user_query)
    user2_exists = Users.Repo.exists?(user2_query)

    user_exists or user2_exists
  end
end
