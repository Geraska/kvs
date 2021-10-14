defmodule KeyValueStore.Repo.Migrations.AddKvs do
  use Ecto.Migration

  def change do
    create table(:params) do
    add :key, :text
    add :value, :text
    add :type, :text

    timestamps()
    end
  create unique_index(:params, [:key])
  end
end
