defmodule Users2.User do
  use Ecto.Schema
  import Ecto.Changeset

  # @primary_key {:id, :binary_id, autogenerate: true}
  schema "users_2" do
    field(:name, :string)
    field(:email, :string)
    field(:date_of_birth, :date)
    field(:is_active, :boolean, default: true)

    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:name, :email, :date_of_birth, :is_active])
    |> validate_required([:name, :email, :date_of_birth])
    |> unique_constraint(:email)
  end

  def insert_user(params) do
    changeset = changeset(%Users2.User{}, params)

    case Users.Repo.insert(changeset) do
      {:ok, user} ->
        IO.puts("User #{user.email} created with id: #{user.id}")
        {:ok, user}

      {:error, changeset} ->
        IO.inspect(changeset.errors)
        {:error, changeset}
    end
  end
end
