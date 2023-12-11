ExUnit.start()
alias Ecto.Integration.TestRepo

# postgresql://postgres:postgres@localhost:${{job.services.postgres.ports[5432]}}/mishka_developer_tools_test
Application.put_env(
  :ecto,
  TestRepo,
  adapter: Ecto.Adapters.Postgres,
  url:
    System.get_env(
      "DATABASE_DEVELOPERT_URL",
      "postgresql://postgres:postgres@localhost:5432/mishka_developer_tools_test"
    ),
  pool: Ecto.Adapters.SQL.Sandbox
)

defmodule Ecto.Integration.TestRepo do
  use Ecto.Repo,
    otp_app: :ecto,
    adapter: Ecto.Adapters.Postgres
end

{:ok, _} = Ecto.Adapters.Postgres.ensure_all_started(TestRepo, :temporary)

_ = Ecto.Adapters.Postgres.storage_down(TestRepo.config())
:ok = Ecto.Adapters.Postgres.storage_up(TestRepo.config())

{:ok, _pid} = TestRepo.start_link()

Code.require_file("test_tables.exs", __DIR__)

:ok = Ecto.Migrator.up(TestRepo, 0, MishkaDeveloperTools.Repo.Migrations.TestTables, log: false)
Ecto.Adapters.SQL.Sandbox.mode(TestRepo, :manual)
Process.flag(:trap_exit, true)

defmodule TestTablesSchema do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "test_tables" do
    field(:test_field_one, :string)
    field(:test_field_two, :string)
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

defmodule User do
  defstruct name: "Shahryar"
end

defmodule ConditionalFieldValidatorTestValidators do
  def is_string_data(field, value) do
    if is_binary(value), do: {:ok, field, value}, else: {:error, field, "It is not string"}
  end

  def is_map_data(field, value) do
    if is_map(value), do: {:ok, field, value}, else: {:error, field, "It is not map"}
  end

  def is_list_data(field, value) do
    if is_list(value), do: {:ok, field, value}, else: {:error, field, "It is not list"}
  end

  def is_int_data(field, value) do
    if is_integer(value), do: {:ok, field, value}, else: {:error, field, "It is not integer"}
  end
end
