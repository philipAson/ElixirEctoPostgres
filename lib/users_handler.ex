defmodule Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "users" do
    field(:name, :string)
    field(:email, :string)
    field(:date_of_birth, :date)
    field(:is_active, :boolean, default: true)

    # Sätter tidstämpel för när användaren skapades samt uppdaterades automatiskt i databasen
    timestamps()
  end

  @doc false
  # changeset endast vid skapandet av en ny användare?
  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:name, :email, :date_of_birth, :is_active])
    |> validate_required([:name, :email, :date_of_birth])
    |> unique_constraint(:email)

    # |> put_change(:updated_at, Ecto.DateTime.utc_now())
  end

  def insert_user(params) do
    changeset = changeset(%Users.User{}, params)

    case Users.Repo.insert(changeset) do
      {:ok, user} ->
        IO.puts("User #{user.email} created with id: #{user.id}")
        {:ok, user}

      {:error, changeset} ->
        IO.inspect(changeset.errors)
        {:error, changeset}
    end
  end

  def update_user(user, changes) do
    changeset = changeset(user, changes)

    case Users.Repo.update(changeset) do
      {:ok, user} ->
        IO.puts("User #{user.email} updated")
        {:ok, user}

      {:error, changeset} ->
        IO.inspect(changeset.errors)
        {:error, changeset}
    end
  end

  def insert_users(users) do
    Enum.each(users, fn user -> insert_user(user) end)
  end

  def get_date_from_age(age) do
    Date.utc_today() |> Date.add(-(age * 365))
  end

  def get_filtered_users(params) do
    query = from(user in Users.User)

    query
    # |> apply_sort(params[:sort])
    |> apply_age_filter(params)
    |> apply_status_filter(params)
    |> apply_email_filter(params)
    |> apply_name_filter(params)
    |> apply_sort(params)
    |> apply_limit(params)
    # |> Users.Repo.all()
    |> get_users_and_apply_age()

    # Apply Age
  end

  defp apply_age_filter(query, %{age_from: from, age_to: to}) do
    from_date = get_date_from_age(from)
    to_date = get_date_from_age(to)

    from(user in query,
      where: user.date_of_birth >= ^to_date and user.date_of_birth <= ^from_date
    )
  end
  defp apply_age_filter(query, _), do: query

  defp apply_status_filter(query, %{is_active: status}) when is_boolean(status) do
    from(user in query,
      where: user.is_active == ^status
    )
  end
  defp apply_status_filter(query, _), do: query

  defp apply_email_filter(query, %{email: partition}) do
    from(user in query,
      where: ilike(user.email, ^"%#{partition}%")
    )
  end
  defp apply_email_filter(query, _), do: query

  defp apply_name_filter(query, %{name: partition}) do
    from(user in query,
      where: ilike(user.name, ^"%#{partition}%")
    )
  end
  defp apply_name_filter(query, _), do: query

  defp apply_sort(query, sorter) do
    case sorter do
      "age" -> sort_users_by_age(query)
      "name" -> sort_users_by_name(query)
      "join_date" -> sort_by_join_date(query)
      _ -> query
    end
  end
  defp apply_sort(query, _), do: query

  defp sort_users_by_age(query) do
    from(user in query,
      order_by: [asc: user.date_of_birth]
    )
  end

  defp sort_users_by_name(query) do
    from(user in query,
      order_by: [asc: user.name])
  end

  defp sort_by_join_date(users) do
    from(user in users,
      order_by: [asc: user.inserted_at]
    )
  end

  defp apply_limit(query, %{limit: limit}) do
    from(user in query,
      limit: ^limit
    )
  end
  defp apply_limit(query, _), do: query

  defp get_users_and_apply_age(enumarable) do
    users = Users.Repo.all(enumarable)

    Enum.map(users, fn user ->
      Map.put(user, :age, Date.diff(Date.utc_today(), user.date_of_birth) / 365)
    end)
  end
end
