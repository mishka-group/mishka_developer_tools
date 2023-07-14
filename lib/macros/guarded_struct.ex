defmodule GuardedStruct do
  @moduledoc """

  This module creates a struct for you with `t()` type in the first step and after that you will
  have some auxiliary functions such as `builder`, which is actually a tuple creation function with
  error management. It should be noted that this helper function checks the necessary fields and validation
  for each field and finally gives the output to the parent validation as `main_validator` function,
  which returns a successful output if there is none.

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

  @temporary_revaluation [
    :gs_fields,
    :gs_types,
    :gs_enforce_keys,
    :gs_validator,
    :gs_main_validator
  ]

  defmacro __using__(_) do
    quote do
      import GuardedStruct, only: [guardedstruct: 1, guardedstruct: 2]
    end
  end

  @doc """
  Defines a typed struct.

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
    use TypedStruct

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
    use TypedStruct

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
    # {:ok, %{id: "123", type: "example", name: "Shahryar", content: "Lorem ipsum"}}
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

    custom_validator = !is_nil(opts[:validator]) && !is_nil(custom_validator(opts[:validator]))

    if custom_validator do
      Module.put_attribute(mod, :gs_validator, %{
        field: name,
        validator: custom_validator(opts[:validator])
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

    quote do
      def builder(attrs) do
        GuardedStruct.builder(
          attrs,
          unquote(module),
          unquote(gs_main_validator),
          unquote(gs_validator),
          unquote(gs_fields),
          unquote(gs_enforce_keys)
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
  def builder(attrs, module, gs_main_validator, gs_validator, gs_fields, enforce_keys) do
    main_validator = Enum.find(gs_main_validator, &is_tuple(&1))

    GuardedStruct.required_fields(enforce_keys, attrs)
    |> GuardedStruct.field_validating(attrs, gs_validator, gs_fields, module)
    |> GuardedStruct.main_validating(main_validator, gs_main_validator, module)
  end

  @doc false
  def field_validating({false, keys}, _attrs, _gs_validator, _gs_fields, _module) do
    {:error, :required_fields, keys}
  end

  def field_validating({true, _keys}, attrs, gs_validator, gs_fields, module) do
    allowed_data = Map.take(attrs, gs_fields)

    validated =
      allowed_data
      |> Enum.map(fn {key, value} ->
        GuardedStruct.find_validator(key, value, gs_validator, module)
      end)

    validated_errors =
      Enum.filter(validated, fn {status, _field, _error_or_data} -> status == :error end)
      |> Enum.map(fn {_status, field, error_or_data} ->
        %{action: field, message: error_or_data}
      end)

    validated_allowed_data =
      if length(validated_errors) == 0 do
        convert_list_tuple_to_map(validated)
      else
        allowed_data
      end

    {validated_errors, validated_allowed_data}
  end

  @doc false
  def main_validating({:error, _, _} = error, _, _, _) do
    error
  end

  def main_validating(
        {validated_errors, validated_allowed_data},
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

    if status == :ok and length(validated_errors) == 0 do
      {:ok, struct(module, main_error_or_data)}
    else
      {:error, :bad_parameters,
       validated_errors ++ if(status == :error, do: [main_error_or_data], else: [])}
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

  defp custom_validator({module, func}) do
    check? = Module.safe_concat([module]) |> function_exported?(func, 2)
    if check?, do: {module, func}, else: nil
  end

  defp custom_validator(nil), do: nil

  defp convert_list_tuple_to_map(list) do
    Enum.reduce(list, %{}, fn {_, key, value}, acc ->
      Map.put(acc, key, value)
    end)
  end

  @doc false
  def required_fields(keys, attrs) do
    missing_keys = Enum.reject(keys, &Map.has_key?(attrs, &1))
    {Enum.empty?(missing_keys), missing_keys}
  end
end
