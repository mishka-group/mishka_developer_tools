defmodule MishkaDeveloperToolsTest.Macro.DB.CrudMacroTest do
  use ExUnit.Case, async: true
  doctest MishkaDeveloperTools
  alias Ecto.Integration.TestRepo

  @right_info %{
    "test_field_one" => "this is a test with test",
    "test_field_two" => "this is a test with test"
  }

  use MishkaDeveloperTools.DB.CRUD,
    module: TestTablesSchema,
    repo: TestRepo,
    id: :uuid

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(TestRepo)
  end

  describe "Happy | CRUD Macro with users DB (▰˘◡˘▰)" do
    test "crud add without strong parameter (user info)" do
      {:ok, :add, _data} = assert crud_add(@right_info)
    end

    test "crud add with strong parameter (user info)" do
      allowed_fields = Map.keys(@right_info)
      {:ok, :add, _data} = assert crud_add(@right_info, allowed_fields)
    end

    test "crud edit without strong parameter (user info)" do
      allowed_fields = Map.keys(@right_info)
      {:ok, :add, data} = assert crud_add(@right_info, allowed_fields)
      {:ok, :edit, _edit_data} = assert crud_edit(Map.merge(@right_info, %{"id" => data.id}))
    end

    test "crud edit with strong parameter (user info)" do
      allowed_fields = Map.keys(@right_info) ++ ["id"]
      {:ok, :add, data} = assert crud_add(@right_info)

      {:ok, :edit, _edit_data} =
        assert crud_edit(Map.merge(@right_info, %{"id" => data.id}), allowed_fields)
    end

    test "crud delete (user info)" do
      {:ok, :add, data} = assert crud_add(@right_info)
      {:ok, :delete, _struct} = assert crud_delete(data.id)
    end

    test "get record by id (user info)" do
      {:ok, :add, data} = assert crud_add(@right_info)
      data_received = crud_get_record(data.id)
      assert is_struct(data_received)
    end

    test "get record by field (user info)" do
      {:ok, :add, data} = assert crud_add(@right_info)

      data_received = crud_get_by_field("test_field_one", data.test_field_one)
      assert is_struct(data_received)
    end
  end

  describe "UnHappy | CRUD Macro with users DB ಠ╭╮ಠ" do
    test "crud add without strong parameter (user false info)" do
      {:error, :add, _changeset} =
        assert crud_add(Map.merge(@right_info, %{"test_field_one" => "f"}))
    end

    test "crud add with strong parameter (user false info)" do
      allowed_fields = ["test_field_one"]
      {:error, :add, _changeset} = assert crud_add(@right_info, allowed_fields)
    end

    test "crud edit without strong parameter (user info)" do
      allowed_fields = Map.keys(@right_info)
      {:ok, :add, data} = assert crud_add(@right_info, allowed_fields)

      {:error, :edit, _changeset} =
        assert crud_edit(Map.merge(@right_info, %{"id" => data.id, "test_field_one" => "f"}))
    end

    test "crud edit with strong parameter (user info)" do
      allowed_fields = Map.keys(@right_info) ++ ["id"]
      {:ok, :add, data} = assert crud_add(@right_info)

      {:error, :edit, _changeset} =
        assert crud_edit(
                 Map.merge(@right_info, %{"id" => data.id, "test_field_one" => "f"}),
                 allowed_fields
               )
    end

    test "crud delete (user false info)" do
      {:error, :delete, {:error, :not_found, _msg}} = assert crud_delete(Ecto.UUID.generate())
    end

    test "get record by id (user false info)" do
      {:error, :not_found, "There is no data for this request."} =
        assert crud_get_record(Ecto.UUID.generate())
    end

    test "get record by field (user false info)" do
      {:error, :not_found, "There is no data for this request."} =
        assert crud_get_by_field("test_field_one", "test@test.com")
    end
  end
end
