defmodule Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:name, :string)
    field(:email, :string)
    field(:date_of_birth, :date)
    field(:is_active, :boolean, default: true)

    #Sätter tidstämpel för när användaren skapades samt uppdaterades automatiskt i databasen
    timestamps()
  end

  @doc false
  #changeset endast vid skapandet av en ny användare?
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
end
