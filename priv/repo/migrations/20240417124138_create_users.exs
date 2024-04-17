defmodule Users.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :date_of_birth, :date
      add :is_active, :boolean, default: true

      timestamps()  # Automatiskt hanterar inserted_at och updated_at
    end
    # Lägg till ett unikt index för att säkerställa att e-postadressen är unik i databasen
    create unique_index(:users, [:email])
  end
end
