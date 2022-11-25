defmodule MishkaDeveloperTools.DB.CRUD do
  @moduledoc """
  ## Simplified CRUD macro using Ecto

  With this module, you can easily implement CRUD-related items in your file wherever you need to build a query.
  These modules and their sub-macros were created more to create a one-piece structure, and you can implement your own custom items in umbrella projects.
  In the first step, to use the following macros, you must bind the requested information in the relevant module that you have already created as follows.
  ```elixir
  use MishkaDeveloperTools.DB.CRUD,
      module: YOURschemaMODULE,
      error_atom: :your_error_tag,
      repo: Your.Repo
  ```
  It should be noted that the following three parameters must be sent and also make sure you are connected to the database.

  ```elixir
  module
  error_atom
  repo
  ```
  """

  # custom Typespecs
  @type record_input() :: map()
  @type repo_data() :: Ecto.Schema.t()
  @type repo_error() :: Ecto.Changeset.t()

  @callback create(record_input()) ::
              {:error, :add, repo_error()} | {:ok, :add, repo_data()}

  @callback edit(record_input()) ::
              {:error, :edit, repo_error()}
              | {:ok, :edit, repo_data()}
              | {:error, :edit, {:error, :uuid | :not_found, String.t()}}

  @callback delete(Ecto.UUID.t() | non_neg_integer()) ::
              {:error, :delete, repo_error()}
              | {:error, :delete, {:error, :uuid | :not_found | :force_constraint, String.t()}}
              | {:ok, :delete, repo_data()}

  @callback delete(Ecto.UUID.t() | non_neg_integer(), list(atom())) ::
              {:error, :delete, {:error, :uuid | :not_found, String.t()}}
              | {:error, :delete, repo_error()}
              | {:ok, :delete, repo_data()}

  @callback show_by_id(Ecto.UUID.t() | non_neg_integer()) ::
              {:error, :not_found, String.t()} | struct()

  @callback show_by_field(String.t(), any()) ::
              {:error, :not_found, String.t()} | struct()

  @optional_callbacks delete: 2, show_by_id: 1, show_by_field: 2

  defmacro __using__(opts) do
    quote(bind_quoted: [opts: opts]) do
      import MishkaDeveloperTools.DB.CRUD
      @interface_module opts
    end
  end

  @doc """
  ### Creating a record macro

  ## Example
  ```elixir
  crud_add(map_of_info like: %{name: "trangell"})
  ```
  The input of this macro is a map and its output are a map. For example

  ```elixir
  {:ok, :add, error_atom, data}
  {:error, :add, error_atom, changeset}
  ```

  If you want only the selected parameters to be separated from the list of submitted parameters and sent to the database, use the same macro with input 2

  ###  Example
  ```elixir
  crud_add(map_of_info like: %{name: "trangell"}, [:name])
  ```
  """
  defmacro crud_add(attrs) do
    quote do
      initial = get_initial_macro_data(@interface_module)
      create_record(unquote(attrs), initial.module_selected, initial.repo)
    end
  end

  defmacro crud_add(attrs, allowed_fields) do
    quote do
      initial = get_initial_macro_data(@interface_module)

      create_record(
        Map.take(unquote(attrs), unquote(allowed_fields)),
        initial.module_selected,
        initial.repo
      )
    end
  end

  @doc """
  ### Edit a record in a database Macro

  With the help of this macro, you can edit a record in the database with its ID. For this purpose, you must send the requested record ID along with the new Map parameters. Otherwise the macro returns the ID error.

  ## Example
  ```elixir
  crud_edit(map_of_info like: %{id: "6d80d5f4-781b-4fa8-9796-1821804de6ba",name: "trangell"})
  ```
  > Note that the sending ID must be of UUID type.

  The input of this macro is a map and its output are a map. For example

  ```elixir
  # If your request has been saved successfully
  {:ok, :edit, error_atom, info}
  # If your ID is not uuid type
  {:error, :edit, error_atom, :uuid}
  # If there is an error in sending the data
  {:error, :edit, error_atom, changeset}
  # If no record is found for your ID
  {:error, :delete, error_atom, :get_record_by_id}
  ```

  It should be noted that if you want only the selected fields to be separated from the submitted parameters and sent to the database, use the macro with dual input.

  ## Example
  ```elixir
  crud_edit(map_of_info like: %{id: "6d80d5f4-781b-4fa8-9796-1821804de6ba", name: "trangell"}, [:id, :name])
  ```
  """
  defmacro crud_edit(attrs) do
    quote do
      initial = get_initial_macro_data(@interface_module)
      converted_attrs = unquote(attrs)

      edit_record_by_fetch(
        {initial.id_type, converted_attrs["id"]},
        unquote(attrs),
        initial.module_selected,
        initial.repo
      )
    end
  end

  defmacro crud_edit(attrs, allowed_fields) do
    quote do
      initial = get_initial_macro_data(@interface_module)
      converted_attrs = unquote(attrs)

      edit_record_by_fetch(
        {initial.id_type, converted_attrs["id"]},
        Map.take(converted_attrs, unquote(allowed_fields)),
        initial.module_selected,
        initial.repo
      )
    end
  end

  @doc """
  ### delete a record from the database with the help of ID Macro

  With the help of this macro, you can delete your requested record from the database.
  The input of this macro is a UUID and its output is a map


  ## Example
  ```elixir
  crud_delete("6d80d5f4-781b-4fa8-9796-1821804de6ba")
  ```
  Output:
  You should note that this macro prevents the orphan data of the record requested to be deleted. So, use this macro when the other data is not dependent on the data with the ID sent by you.



  Outputs:

  ```elixir
  # This message will be returned when your data has been successfully deleted
  {:ok, :delete, error_atom, struct}
  # This error will be returned if the ID sent by you is not a UUID
  {:error, :delete, error_atom, :uuid}
  # This error is reversed when an error occurs while sending data
  {:error, :delete, error_atom, changeset}
  # This error will be reversed when there is no submitted ID in the database
  {:error, :delete, error_atom, :get_record_by_id}
  # This error is reversed when another record is associated with this record
  {:error, :delete, error_atom, :forced_to_delete}
  ```
  """
  defmacro crud_delete(id) do
    quote do
      initial = get_initial_macro_data(@interface_module)

      delete_record_by_force_constraint(
        {initial.id_type, unquote(id)},
        initial.module_selected,
        initial.repo
      )
    end
  end

  defmacro crud_delete(id, assoc) do
    quote do
      initial = get_initial_macro_data(@interface_module)

      delete_record_by_no_assoc_constraint(
        {initial.id_type, unquote(id)},
        initial.module_selected,
        unquote(assoc),
        initial.repo
      )
    end
  end

  @doc """
  ### Macro Finding a record in a database with the help of ID

  With the help of this macro, you can send an ID that is of UUID type and call it if there is a record in the database.
  The output of this macro is map.


  # Example
  ```elixir
  crud_get_record("6d80d5f4-781b-4fa8-9796-1821804de6ba")
  ```

  Outputs:

  ```
  {:error, error_atom, :get_record_by_id}
  {:ok, error_atom, :get_record_by_id, record_info}
  ```

  """
  defmacro crud_get_record(id) do
    quote do
      initial = get_initial_macro_data(@interface_module)
      fetch_record_by_id(unquote(id), initial.module_selected, initial.repo)
    end
  end

  @doc """
  ### Macro Find a record in the database with the help of the requested field

  With the help of this macro, you can find a field with the value you want, if it exists in the database. It should be noted that the field name must be entered as a String.


  # Example
  ```elixir
  crud_get_by_field("email", "info@trangell.com")
  ```

  Outputs:

  ```
  {:error, error_atom, :get_record_by_field}
  {:ok, error_atom, :get_record_by_field, record_info}
  ```

  """
  defmacro crud_get_by_field(field, value) do
    quote do
      initial = get_initial_macro_data(@interface_module)
      fetch_record_by_field(unquote(field), unquote(value), initial.module_selected, initial.repo)
    end
  end

  ###  Functions to create macro

  @spec create_record(record_input(), module(), module()) ::
          {:error, :add, repo_error()} | {:ok, :add, repo_data()}
  @doc false
  def create_record(attrs, module, repo) do
    module.changeset(module.__struct__, attrs)
    |> repo.insert()
    |> case do
      {:ok, data} -> {:ok, :add, data}
      {:error, error_data} -> {:error, :add, error_data}
    end
  end

  @spec edit_record_by_fetch(
          {:uuid | any(), String.t() | non_neg_integer()},
          record_input(),
          module(),
          module()
        ) ::
          {:error, :edit, repo_error()}
          | {:ok, :edit, repo_data()}
          | {:error, :edit, {:error, :uuid | :not_found, String.t()}}
  @doc false
  def edit_record_by_fetch({_type, _id} = id_info, attrs, module, repo) do
    with {:ok, valid_id} <- record_id_check(id_info),
         data_received when is_struct(data_received) <-
           fetch_record_by_id(valid_id, module, repo),
         created_changeset <- module.changeset(data_received, attrs),
         {:edit, {:ok, data}} <- {:edit, repo.update(created_changeset)} do
      {:ok, :edit, data}
    else
      {:edit, {:error, error_data}} -> {:error, :edit, error_data}
      {:error, _action, _extra} = error_data -> {:error, :edit, error_data}
    end
  end

  @spec delete_record_by_force_constraint(
          {:uuid | any, String.t() | non_neg_integer()},
          module(),
          module()
        ) ::
          {:error, :delete, repo_error()}
          | {:error, :delete, {:error, :uuid | :not_found | :force_constraint, String.t()}}
          | {:ok, :delete, repo_data()}
  @doc false
  def delete_record_by_force_constraint({_type, _id} = id_info, module, repo) do
    with {:ok, valid_id} <- record_id_check(id_info),
         data_received when is_struct(data_received) <-
           fetch_record_by_id(valid_id, module, repo),
         {:delete, {:ok, data}} <- {:delete, repo.delete(data_received)} do
      {:ok, :delete, data}
    else
      {:delete, {:error, error_data}} -> {:error, :delete, error_data}
      {:error, _action, _extra} = error_data -> {:error, :delete, error_data}
    end
  rescue
    _e ->
      {:error, :delete,
       {:error, :force_constraint, "There are one or more dependencies to delete this record."}}
  end

  @spec delete_record_by_no_assoc_constraint(
          {:uuid | any, String.t() | non_neg_integer()},
          module(),
          list(atom()),
          module()
        ) ::
          {:error, :delete, {:error, :uuid | :not_found, String.t()}}
          | {:error, :delete, repo_error()}
          | {:ok, :delete, repo_data()}
  @doc false
  def delete_record_by_no_assoc_constraint({_type, _id} = id_info, module, assoc, repo) do
    with {:ok, valid_id} <- record_id_check(id_info),
         data_received when is_struct(data_received) <-
           fetch_record_by_id(valid_id, module, repo),
         created_change <- Ecto.Changeset.change(struct(module, %{id: data_received.id})),
         created_assoc <-
           Enum.reduce(assoc, created_change, fn item, acc ->
             Ecto.Changeset.no_assoc_constraint(acc, item)
           end),
         {:delete, {:ok, data}} <- {:delete, repo.delete(created_assoc)} do
      {:ok, :delete, data}
    else
      {:delete, {:error, error_data}} -> {:error, :delete, error_data}
      {:error, _action, _extra} = error_data -> {:error, :delete, error_data}
    end
  end

  @doc false
  defp record_id_check({:uuid, id}) do
    with :error <- Ecto.UUID.cast(id) do
      {:error, :uuid, "The submitted ID is not valid."}
    end
  end

  defp record_id_check({_, id}), do: {:ok, id}

  @spec fetch_record_by_id(String.t() | integer(), module(), module()) ::
          {:error, :not_found, String.t()} | struct()
  @doc false
  def fetch_record_by_id(id, module, repo) do
    with nil <- repo.get(module, id) do
      {:error, :not_found, "There is no data for this request."}
    end
  end

  @spec fetch_record_by_field(String.t() | atom(), any, module(), module()) ::
          {:error, :not_found, String.t()} | struct()
  @doc false
  def fetch_record_by_field(field, value, module, repo) do
    with nil <- repo.get_by(module, "#{field}": value) do
      {:error, :not_found, "There is no data for this request."}
    end
  end

  @spec get_initial_macro_data(keyword) :: %{
          id_type: atom(),
          module_selected: module(),
          repo: module()
        }
  @doc false
  def get_initial_macro_data(interface_module) do
    %{
      module_selected: Keyword.get(interface_module, :module),
      repo: Keyword.get(interface_module, :repo),
      id_type: Keyword.get(interface_module, :id)
    }
  end
end
