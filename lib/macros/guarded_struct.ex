# TODO: we need helper to find our input map is string or atom, if string it should be converted to atom
defmodule GuardedStruct do
  @moduledoc """

  This module creates a struct for you with `t()` type in the first step and after that you will
  have some auxiliary functions such as `builder`, which is actually a tuple creation function with
  error management. It should be noted that this helper function checks the necessary fields and validation
  for each field and finally gives the output to the parent validation as `main_validator` function,
  which returns a successful output if there is none.
  This was part of the macro's capabilities; Now you can use the predefined validations and
  sanitizers of this library.

  > Outputs can be ` {:error, :bad_parameters, errors_list}` or `{:ok, data}`.

  ---

  ## Copyright

  The code in this module is based on the 'typed_struct' library (https://github.com/ejpcmac/typed_struct),
  which is licensed under the MIT License.

  Modifications and additions have been made to enhance its capabilities as part of the current project.

  **MIT License**

  Adding new Copyright (c) [2023] [Shahryar Tavakkoli at [Mishka Group](https://github.com/mishka-group)]

  **Note:** If the license changes during the support of this project, this file will always remain on MIT

  """
  alias MishkaDeveloperTools.Helper.{Derive, Derive.Parser}

  @temporary_revaluation [
    :gs_fields,
    :gs_types,
    :gs_enforce_keys,
    :gs_validator,
    :gs_main_validator,
    :gs_derive
  ]

  defmacro __using__(_) do
    quote do
      import GuardedStruct, only: [guardedstruct: 1, guardedstruct: 2]
    end
  end

  @doc """
  Defines a guarded struct.

  Inside a `guardedstruct` block, each field is defined through the `field/2`
  macro.

  ## Options

    * `enforce` - if set to true, sets `enforce: true` to all fields by default.
      This can be overridden by setting `enforce: false` or a default value on
      individual fields.
    * `opaque` - if set to true, creates an opaque type for the struct.
    * `module` - if set, creates the struct in a submodule named `module`.
    * `validator` - if set as tuple like this {ModuleName, :function_name} for each field,
    in fact you have a `builder` function that check the validation.
    * `main_validator` - if set as tuple like this {ModuleName, :function_name},
    for guardedstruct, in fact you have a global validation.


  > **Note:** If you did not set `main_validator` or `validator`, it checks the parent module for these!
  > You should consider when you create `validator(:field_name_atom, value)` and do not want to create for
  > all fields, please have `validator(field_name_atom, value)` with `{:ok, field_name_atom, value}` to let us
  > handle this for you. you can see this in the examples

  ## Examples

  ```elixir
  guardedstruct main_validator: {Validator, :main_validator} do
    field(:id, String.t(), validator: {Validator, :validator})
    field(:type, String.t(), enforce: true)
    field(:name, String.t(), default: "Shahryar")
  end
  ```

  OR

  ```elixir
  defmodule MyStruct do
    use GuardedStruct

    guardedstruct do
      field :field_one, String.t()
      field :field_two, integer(), enforce: true
      field :field_three, boolean(), enforce: true
      field :field_four, atom(), default: :hey
    end
  end
  ```

  OR

  ```elixir
  defmodule MyStruct do
    use GuardedStruct

    guardedstruct  do
      field(:id, String.t())
      field(:type, String.t(), enforce: true)
      field(:name, String.t(), default: "Shahryar")
      field(:content, String.t())
    end

    def validator(:content, value) do
      {:error, :content, value}
    end

    def validator(name, value) do
      {:ok, name, value}
    end
  end
  ```

  The following is an equivalent using the *enforce by default* behaviour:

  ```elixir
  defmodule MyStruct do
    use GuardedStruct

    guardedstruct enforce: true do
      field :field_one, String.t(), enforce: false
      field :field_two, integer()
      field :field_three, boolean(), validator: {Validator, :validator}
      field :field_four, atom(), default: :hey
    end
  end
  ```

  You can create the struct in a submodule instead:

  ```elixir
  defmodule MyModule do
    use GuardedStruct

    guardedstruct module: Struct do
      field :field_one, String.t()
      field :field_two, integer(), enforce: true
      field :field_three, boolean(), enforce: true
      field :field_four, atom(), default: :hey
    end
  end
  ```

  > **Note:** The builder function is created in Parent module.

  ---

  ## This macro creates `builder`, `enforce_keys`, `keys` functions for you:

  ```elixir
    %{id: "123", type: "example", name: "Shahryar", content: "Lorem ipsum"}
    |> MyModule.builder()

    # Returns:
    # {:ok, %ModuleStruct{id: "123", type: "example", name: "Shahryar", content: "Lorem ipsum"}}
    # {:error, :error_action, errors_list}

    MyModule.enforce_keys(:id)
    # Returns: false or true

    MyModule.enforce_keys()
    # Returns: List of enforce keys


    MyModule.keys(:id)
    # Returns: false or true

    MyModule.keys()
    # Returns: List of keys
  ```

  ---

  ## Predefined validations and sanitizers as a derive

  Based on the convenience of working with GuardedStruct, you can enter sanitizers
  and validation for each field as a string.

  > **Note:** you can mix `derive` with your field `validator` and struct `main_validator`.
  > It should be noted that the prioritization of functions is as follows:
  > Field validators --> Main validator --> Field sanitizes --> Field validations

  ```elixir
  defmodule MyStruct do
    use GuardedStruct

    guardedstruct enforce: true do
      field :field_one, String.t(), enforce: false
      field :field_two, integer(), derive: "sanitize(trim, lowercase) validate(not_empty, max_len = 20)"
      field :field_three, boolean(), validator: {Validator, :validator}
      field :field_four, atom(), default: :mishka_group,
            validator: {Validator, :validator}, , derive: "sanitize(trim) validate(not_empty)"
    end
  end
  ```

  > **Note:** Like the examples above, this case also follows the rules of internal validator function checker.

  ```elixir
  defmodule MyStruct do
    use GuardedStruct

    guardedstruct enforce: true do
      field :field_one, String.t(), enforce: false
      field :field_two, integer(), derive: "sanitize(trim, lowercase) validate(not_empty)"
    end

    def validator(:field_two, value) do
      {:ok, :name, "Mishka   "}
    end

    def validator(field, value) do
      {:ok, field, value}
    end
  end
  ```
  """
  defmacro guardedstruct(opts \\ [], do: block) do
    ast = register_struct(block, opts)

    # It helps you create module inside module to define types
    case opts[:module] do
      nil ->
        quote do
          # Create a lexical scope.
          (fn -> unquote(ast) end).()
        end

      module ->
        quote do
          defmodule unquote(module) do
            unquote(ast)
          end
        end
    end
  end

  @doc false
  def register_struct(block, opts) do
    [:validate_derive, :sanitize_derive]
    |> Enum.each(fn item ->
      if is_nil(Application.get_env(:guarded_struct, item)) do
        Application.put_env(:guarded_struct, item, Keyword.get(opts, item))
      end
    end)

    quote do
      Enum.each(unquote(@temporary_revaluation), fn attr ->
        Module.register_attribute(__MODULE__, attr, accumulate: true)
      end)

      Module.put_attribute(__MODULE__, :gs_enforce?, unquote(!!opts[:enforce]))

      main_validator = unquote(opts[:main_validator])

      if !is_nil(main_validator) && is_tuple(main_validator) do
        Module.put_attribute(__MODULE__, :gs_main_validator, main_validator)
      end

      if !is_nil(main_validator) && (!is_tuple(main_validator) or tuple_size(main_validator) != 2) do
        raise(
          ArgumentError,
          "Main validator is came as a tuple and includes {module, function_name}, noted the function_name should be atom."
        )
      end

      @before_compile {unquote(__MODULE__), :create_builder}
      @before_compile {unquote(__MODULE__), :delete_temporary_revaluation}

      import GuardedStruct
      # Leave the block with its orginal face
      unquote(block)

      # Point what field should be required
      @enforce_keys @gs_enforce_keys
      defstruct @gs_fields

      # Create type `t()` with `@opaque` option
      GuardedStruct.__type__(@gs_types, unquote(opts))
    end
  end

  @doc false
  defmacro __type__(types, opts) do
    if Keyword.get(opts, :opaque, false) do
      quote bind_quoted: [types: types] do
        @opaque t() :: %__MODULE__{unquote_splicing(types)}
      end
    else
      quote bind_quoted: [types: types] do
        @type t() :: %__MODULE__{unquote_splicing(types)}
      end
    end
  end

  @doc false
  defmacro field(name, type, opts \\ []) do
    quote bind_quoted: [name: name, type: Macro.escape(type), opts: opts] do
      GuardedStruct.__field__(name, type, opts, __ENV__)
    end
  end

  @doc false
  defmacro sub_field(name, _type, opts \\ [], do: block) do
    ast = register_struct(block, opts)
    type = Macro.escape(quote do: struct())

    converted_name =
      name
      |> Atom.to_string()
      |> Macro.camelize()
      |> String.to_atom()
      |> then(&Module.concat(__CALLER__.module, &1))

    quote do
      GuardedStruct.__field__(unquote(name), unquote(type), unquote(opts), __ENV__)

      defmodule unquote(converted_name) do
        unquote(ast)
      end
    end
  end

  @doc false
  def __field__(name, type, opts, %Macro.Env{module: mod} = _env)
      when is_atom(name) do
    if Keyword.has_key?(Module.get_attribute(mod, :gs_fields), name) do
      raise ArgumentError, "the field #{inspect(name)} is already set"
    end

    has_default? = Keyword.has_key?(opts, :default)
    enforce_by_default? = Module.get_attribute(mod, :gs_enforce?)

    enforce? =
      if is_nil(opts[:enforce]),
        do: enforce_by_default? && !has_default?,
        else: !!opts[:enforce]

    nullable? = !has_default? && !enforce?

    if !is_nil(opts[:derive]),
      do:
        Module.put_attribute(mod, :gs_derive, %{
          field: name,
          derive: opts[:derive]
        })

    if !is_nil(opts[:validator]) do
      Module.put_attribute(mod, :gs_validator, %{
        field: name,
        validator: opts[:validator]
      })
    end

    Module.put_attribute(mod, :gs_fields, {name, opts[:default]})
    Module.put_attribute(mod, :gs_types, {name, type_for(type, nullable?)})
    if enforce?, do: Module.put_attribute(mod, :gs_enforce_keys, name)
  end

  def __field__(name, _type, _opts, _env) do
    raise ArgumentError, "a field name must be an atom, got #{inspect(name)}"
  end

  # Makes the type nullable if the key is not enforced.
  defp type_for(type, false), do: type
  defp type_for(type, _), do: quote(do: unquote(type) | nil)

  @doc false
  defmacro create_builder(%Macro.Env{module: module}) do
    exists_validator?(module, :main_validator, :gs_main_validator)
    exists_validator?(module, :validator, :gs_validator, 2)

    gs_main_validator = Macro.escape(Module.get_attribute(module, :gs_main_validator))
    gs_validator = Macro.escape(Module.get_attribute(module, :gs_validator))
    gs_enforce_keys = Module.get_attribute(module, :gs_enforce_keys)
    gs_fields = Macro.escape(Module.get_attribute(module, :gs_fields) |> Enum.map(&elem(&1, 0)))
    gs_derive = Macro.escape(Module.get_attribute(module, :gs_derive))

    quote do
      def builder(attrs) do
        GuardedStruct.builder(
          attrs,
          unquote(module),
          unquote(gs_main_validator),
          unquote(gs_validator),
          unquote(gs_fields),
          unquote(gs_enforce_keys),
          unquote(gs_derive)
        )
      end

      def enforce_keys() do
        unquote(gs_enforce_keys)
      end

      def enforce_keys(key) do
        Enum.member?(unquote(gs_enforce_keys), key)
      end

      def keys() do
        unquote(gs_fields)
      end

      def keys(key) do
        Enum.member?(unquote(gs_fields), key)
      end
    end
  end

  @doc false
  def builder(attrs, module, gs_main_validator, gs_validator, gs_fields, enforce_keys, gs_derive) do
    main_validator = Enum.find(gs_main_validator, &is_tuple(&1))

    Parser.convert_to_atom_map(attrs)
    |> GuardedStruct.required_fields(enforce_keys)
    |> GuardedStruct.field_validating(attrs, gs_validator, gs_fields, module)
    |> GuardedStruct.main_validating(main_validator, gs_main_validator, module)
    |> Derive.derive(gs_derive)
  end

  @doc false
  def required_fields(attrs, keys) do
    missing_keys = Enum.reject(keys, &Map.has_key?(attrs, &1))
    {Enum.empty?(missing_keys), missing_keys, :halt}
  end

  @doc false
  def field_validating({false, keys, :halt}, _attrs, _gs_validator, _gs_fields, _module) do
    {:error, :required_fields, keys, :halt}
  end

  def field_validating({true, _keys, _}, attrs, gs_validator, gs_fields, module) do
    {sub_modules_builders, sub_modules_builders_errors, unsub_fields} =
      required_fields_and_validate_sub_field(attrs, module, gs_fields)

    allowed_data = Map.take(attrs, unsub_fields)

    validated =
      allowed_data
      |> Enum.map(fn {key, value} ->
        GuardedStruct.find_validator(key, value, gs_validator, module)
      end)

    validated_errors =
      Enum.filter(validated, fn {status, _field, _error_or_data} -> status == :error end)
      |> Enum.map(fn {_status, field, error_or_data} ->
        %{field: field, message: error_or_data}
      end)

    validated_allowed_data =
      if length(validated_errors) == 0 do
        convert_list_tuple_to_map(validated)
      else
        allowed_data
      end

    {validated_errors, validated_allowed_data, sub_modules_builders, sub_modules_builders_errors}
  end

  @doc false
  def main_validating({:error, _, _, :halt} = error, _, _, _), do: error

  def main_validating({:error, _, _} = error, _, _, _), do: error

  def main_validating(
        {
          validated_errors,
          validated_allowed_data,
          sub_modules_builders,
          sub_modules_builders_errors
        },
        main_validator,
        gs_main_validator,
        module
      ) do
    {status, main_error_or_data} =
      cond do
        !is_nil(main_validator) ->
          {module, func} = main_validator
          apply(module, func, [validated_allowed_data])

        gs_main_validator == [true] ->
          apply(module, :main_validator, [validated_allowed_data])

        true ->
          {:ok, validated_allowed_data}
      end

    cond do
      status == :ok and length(validated_errors) == 0 and length(sub_modules_builders_errors) == 0 ->
        merged_struct =
          Enum.reduce(sub_modules_builders, struct(module, main_error_or_data), fn item, acc ->
            Map.merge(acc, item)
          end)

        {:ok, merged_struct}

      length(validated_errors) == 0 and status == :ok and length(sub_modules_builders_errors) > 0 ->
        {
          :error,
          :bad_parameters,
          :nested,
          sub_modules_builders_errors,
          struct(module, main_error_or_data)
        }

      true ->
        {:error, :bad_parameters,
         validated_errors ++
           sub_modules_builders_errors ++ if(status == :error, do: [main_error_or_data], else: [])}
    end
  end

  @doc false
  def find_validator(field, data, gs_validator, caller_module) do
    case Enum.find(gs_validator, &(&1 != true && &1.field == field)) do
      %{field: key, validator: {module, func}} ->
        apply(module, func, [key, data])

      _ ->
        if Enum.member?(gs_validator, true),
          do: caller_module.validator(field, data),
          else: {:ok, field, data}
    end
  end

  @doc false
  defmacro delete_temporary_revaluation(%Macro.Env{module: module}) do
    Enum.each(unquote(@temporary_revaluation), &Module.delete_attribute(module, &1))
  end

  defp exists_validator?(mod, modfn, attr_name, arity \\ 1) do
    if Module.defines?(mod, {modfn, arity}) do
      Module.put_attribute(mod, attr_name, true)
    end
  end

  defp convert_list_tuple_to_map(list) do
    Enum.reduce(list, %{}, fn {_, key, value}, acc ->
      Map.put(acc, key, value)
    end)
  end

  defp required_fields_and_validate_sub_field(attrs, module, gs_fields) do
    allowed_fields = Map.take(attrs, gs_fields) |> Map.keys()
    sub_modules = get_fields_sub_module(module, allowed_fields)

    sub_modules_builders =
      sub_modules
      |> Enum.map(fn %{field: field, module: module} ->
        {field, module.builder(Map.get(attrs, field))}
      end)

    {
      sub_modules_builders_data(sub_modules_builders),
      sub_modules_builders_errors(sub_modules_builders),
      reject_sub_module_fields(allowed_fields, sub_modules)
    }
  end

  def get_fields_sub_module(module, fields, list \\ false) do
    Enum.map(fields, fn field ->
      case Code.ensure_loaded(Module.concat([module, atom_to_module(field)])) do
        {:module, module} ->
          if !list, do: %{field: field, module: module}, else: field

        _ ->
          nil
      end
    end)
    |> Enum.reject(&is_nil(&1))
  end

  defp atom_to_module(field) do
    field
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.map(fn item ->
      String.capitalize(String.at(item, 0)) <> String.slice(item, 1..-1)
    end)
    |> Enum.join()
    |> String.to_atom()
  end

  defp reject_sub_module_fields(fields, sub_modules) do
    fields
    |> Enum.reject(fn field ->
      Enum.any?(sub_modules, fn
        %{field: ^field} -> true
        _ -> false
      end)
    end)
  end

  defp sub_modules_builders_data(sub_modules_builders) do
    sub_modules_builders
    |> Enum.filter(fn {_field, output} -> elem(output, 0) == :ok end)
    |> Enum.map(fn {field, {_, data}} -> Map.new([{field, data}]) end)
  end

  defp sub_modules_builders_errors(sub_modules_builders) do
    sub_modules_builders
    |> Enum.filter(fn {_field, output} -> elem(output, 0) == :error end)
    |> Enum.map(fn {field, error} ->
      %{field: field, errors: {elem(error, 1), elem(error, 2)}}
    end)
  end
end
