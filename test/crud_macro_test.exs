defmodule MishkaDeveloperToolsTest.Macro.DB.CrudMacroTest do
  use ExUnit.Case, async: true
  doctest MishkaDeveloperTools

  @right_info %{test_field_one: "this is a test with test", test_field_two: "this is a test with test"}
  @eror_tag :test_tables

  use MishkaDeveloperTools.DB.CRUD,
      module: TestTablesSchema,
      error_atom: :test_tables,
      repo: MishkaDeveloperTools.Repo

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MishkaDeveloperTools.Repo)
  end

  describe "Happy | CRUD Macro with users DB (▰˘◡˘▰)" do
    test "crud add without strong parameter (user info)" do
      {:ok, :add, @eror_tag, _data} = assert crud_add(@right_info)
    end

    test "crud add with strong parameter (user info)" do
      allowed_fields = Map.keys(@right_info)
      {:ok, :add, @eror_tag, _data} = assert crud_add(@right_info, allowed_fields)
    end

    test "crud edit without strong parameter (user info)" do
      allowed_fields = Map.keys(@right_info)
      {:ok, :add, @eror_tag, data} = assert crud_add(@right_info, allowed_fields)
      {:ok, :edit, @eror_tag, _edit_data} = assert crud_edit(Map.merge(@right_info,%{id: data.id}))
    end

    test "crud edit with strong parameter (user info)" do
      allowed_fields = Map.keys(@right_info) ++ [:id]
      {:ok, :add, @eror_tag, data} = assert crud_add(@right_info)
      {:ok, :edit, @eror_tag, _edit_data} = assert crud_edit(Map.merge(@right_info, %{id: data.id}), allowed_fields)
    end

    test "crud delete (user info)" do
      {:ok, :add, @eror_tag, data} = assert crud_add(@right_info)
      {:ok, :delete, @eror_tag, _struct} = assert crud_delete(data.id)
    end

    test "get record by id (user info)" do
      {:ok, :add, @eror_tag, data} = assert crud_add(@right_info)
      {:ok, :get_record_by_id, @eror_tag, _record_info} = assert crud_get_record(data.id)
    end

    test "get record by field (user info)" do
      {:ok, :add, @eror_tag, data} = assert crud_add(@right_info)
      {:ok, :get_record_by_field, @eror_tag, _record_info} = assert crud_get_by_field("test_field_one", data.test_field_one)
    end
  end






  describe "UnHappy | CRUD Macro with users DB ಠ╭╮ಠ" do
    test "crud add without strong parameter (user false info)" do
      {:error, :add, @eror_tag, _changeset} = assert crud_add(Map.merge(@right_info,%{test_field_one: "f"}))
    end

    test "crud add with strong parameter (user false info)" do
      allowed_fields = [:test_field_one]
      {:error, :add, @eror_tag, _changeset} = assert crud_add(@right_info, allowed_fields)
    end

    test "crud edit without strong parameter (user info)" do
      allowed_fields = Map.keys(@right_info)
      {:ok, :add, @eror_tag, data} = assert crud_add(@right_info, allowed_fields)
      {:error, :edit, @eror_tag, _changeset} = assert crud_edit(Map.merge(@right_info,%{id: data.id, test_field_one: "f"}))
    end

    test "crud edit with strong parameter (user info)" do
      allowed_fields = Map.keys(@right_info) ++ [:id]
      {:ok, :add, @eror_tag, data} = assert crud_add(@right_info)
      {:error, :edit, @eror_tag, _changeset} = assert crud_edit(Map.merge(@right_info, %{id: data.id, test_field_one: "f"}), allowed_fields)
    end

    test "crud delete (user false info)" do
      {:error, :delete, :get_record_by_id, @eror_tag} = assert crud_delete(Ecto.UUID.generate)
    end

    test "get record by id (user false info)" do
      {:error, :get_record_by_id, @eror_tag} = assert crud_get_record(Ecto.UUID.generate)
    end

    test "get record by field (user false info)" do
      {:error, :get_record_by_field, @eror_tag} = assert crud_get_by_field("test_field_one", "test@test.com")
    end
  end
end
