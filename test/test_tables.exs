defmodule MishkaDeveloperTools.Repo.Migrations.TestTables do
  use Ecto.Migration

  def change do
    create table(:test_tables, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:test_field_one, :string, null: false)
      add(:test_field_two, :string, null: false)
      timestamps()
    end
  end
end
