defmodule TestTablesSchema do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "test_tables" do
    field(:test_field_one, :string, size: 100, null: false)
    field(:test_field_two, :string, size: 100, null: false)
    timestamps(type: :utc_datetime)
  end

  @all_fields ~w(test_field_one test_field_two)a
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@all_fields)
    |> validate_length(:test_field_one, min: 10)
    |> validate_length(:test_field_two, min: 10)
  end
end
