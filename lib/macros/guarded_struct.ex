defmodule GuardedStruct do
  alias MishkaDeveloperTools.Helper.{Derive, Derive.Parser, Derive.ValidationDerive}
  defexception [:term]

  @temporary_revaluation [
    :gs_fields,
    :gs_types,
    :gs_enforce_keys,
    :gs_validator,
    :gs_main_validator,
    :gs_derive,
    :gs_authorized_fields,
    :gs_external,
    :gs_core_keys,
    :gs_conditional_fields,
    :gs_caller
  ]

  @impl true
  def message(exception) do
    "There is at least one validation problem with your data: #{inspect(exception.term)}"
  end

  defmacro __using__(_) do
    quote do
      import GuardedStruct, only: [guardedstruct: 1, guardedstruct: 2]
    end
  end

  defmacro guardedstruct(opts \\ [], do: block) do
    ast = register_struct(block, opts, :root, __CALLER__.module)
    is_error = !is_nil(Keyword.get(opts, :error))
    # It helps you create module inside module to define types
    case opts[:module] do
      nil ->
        quote do
          # Create a lexical scope.
          (fn -> unquote(ast) end).()

          if unquote(is_error), do: GuardedStruct.create_error_module()
        end

      module ->
        quote do
          defmodule unquote(module) do
            unquote(ast)

            if unquote(is_error), do: GuardedStruct.create_error_module()
          end
        end
    end
  end

  ####################################################################
  ###################### (▰˘◡˘▰) Macros (▰˘◡˘▰) ######################
  ####################################################################

  @spec create_error_module() :: Macro.t()
  @doc false
  defmacro create_error_module() do
    quote do
      defmodule Error do
        defexception [:term, :errors]

        @impl true
        def message(exception) do
          """
          There is at least one validation problem with your data:
           Term: #{inspect(exception.term)}
           Errors: #{inspect(exception.errors)}
          """
        end
      end
    end
  end

  @spec __type__(any(), keyword()) :: Macro.t()
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

  @spec field(atom(), any(), keyword()) :: Macro.t()
  @doc false
  defmacro field(name, type, opts \\ []) do
    quote bind_quoted: [name: name, type: Macro.escape(type), opts: opts] do
      GuardedStruct.__field__(name, type, opts, __ENV__, false)
    end
  end

  @spec sub_field(atom(), any(), keyword(), [{:do, any()}]) :: Macro.t()
  @doc false
  defmacro sub_field(name, type, opts \\ [], do: block) do
    ast = register_struct(block, opts, name, __CALLER__.module)
    type = Macro.escape(type)
    is_error = !is_nil(Keyword.get(opts, :error))

    quote do
      %{name: module_name, cond?: _cond?} =
        Module.get_attribute(__ENV__.module, :gs_conditional_fields)
        |> GuardedStruct.sub_conditional_field_module(unquote(name), __ENV__)

      GuardedStruct.__field__(unquote(name), unquote(type), unquote(opts), __ENV__, true)

      defmodule module_name do
        unquote(ast)

        if unquote(is_error), do: GuardedStruct.create_error_module()
      end
    end
  end

  @spec create_builder(Macro.Env.t()) :: Macro.t()
  @doc false
  defmacro create_builder(%Macro.Env{module: module}) do
    exists_validator?(module, :main_validator, :gs_main_validator)
    exists_validator?(module, :validator, :gs_validator, 2)

    escaped_list =
      List.delete(@temporary_revaluation, :gs_types)
      |> Enum.map(&Macro.escape(Module.get_attribute(module, &1)))

    quote do
      def builder(attrs, error \\ false)

      def builder({key, attrs} = input, error)
          when is_tuple(input) and is_map(attrs) and (is_list(key) or is_atom(key)) do
        GuardedStruct.builder(
          %{attrs: attrs, module: unquote(module), revaluation: unquote(escaped_list)},
          key,
          :add,
          error
        )
      end

      def builder({key, attrs, type} = input, error)
          when is_tuple(input) and is_map(attrs) and (is_list(key) or is_atom(key)) do
        GuardedStruct.builder(
          %{attrs: attrs, module: unquote(module), revaluation: unquote(escaped_list)},
          key,
          type,
          error
        )
      end

      def builder(attrs, error) when is_map(attrs) do
        GuardedStruct.builder(
          %{attrs: attrs, module: unquote(module), revaluation: unquote(escaped_list)},
          :root,
          :add,
          error
        )
      end

      def builder(_attrs, _error) do
        {:error, :bad_parameters, "Your input must be a map or list of maps"}
      end

      def enforce_keys() do
        unquote(Enum.at(escaped_list, 1))
      end

      def enforce_keys(:all) do
        GuardedStruct.show_nested_keys(unquote(module), :enforce_keys)
      end

      def enforce_keys(key) do
        Enum.member?(unquote(Enum.at(escaped_list, 1)), key)
      end

      def keys() do
        unquote(List.first(escaped_list) |> Enum.map(&elem(&1, 0)))
      end

      def keys(:all) do
        GuardedStruct.show_nested_keys(unquote(module))
      end

      def keys(key) do
        Enum.member?(unquote(List.first(escaped_list) |> Enum.map(&elem(&1, 0))), key)
      end

      def __information__() do
        info = unquote(List.last(escaped_list) |> List.first())

        path =
          if(Map.get(info, :key) == :root,
            do: [],
            else:
              info.module
              |> Module.split()
              |> GuardedStruct.reverse_module_keys(info.key)
          )

        Map.merge(info, %{path: path})
      end
    end
  end

  @spec delete_temporary_revaluation(Macro.Env.t()) :: :ok
  @doc false
  defmacro delete_temporary_revaluation(%Macro.Env{module: module}) do
    Enum.each(unquote(@temporary_revaluation), &Module.delete_attribute(module, &1))
  end

  @spec conditional_field(atom(), any(), keyword(), [{:do, any()}]) :: Macro.t()
  @doc false
  defmacro conditional_field(name, type, opts \\ [], do: block) do
    type = Macro.escape(type)
    block = Parser.parser(block, :conditional)

    opts =
      if Keyword.has_key?(opts, :__node_type__),
        do: opts,
        else:
          opts ++
            [
              __node_parent_tree__: "root",
              __node_id__: "root::" <> Helper.Extra.randstring(8),
              __node_type__: "conds"
            ]

    quote do
      GuardedStruct.__field__(unquote(name), unquote(type), unquote(opts), __ENV__, false, true)
      unquote(block)
    end
  end

  @spec register_struct(any(), nil | maybe_improper_list() | map(), atom(), module()) :: Macro.t()
  @doc false
  def register_struct(block, opts, key, caller) do
    quote do
      [:validate_derive, :sanitize_derive]
      |> Enum.each(fn item ->
        if is_nil(Application.compile_env(:guarded_struct, item)) do
          Application.put_env(:guarded_struct, item, Keyword.get(unquote(opts), item))
        end
      end)

      Enum.each(unquote(@temporary_revaluation), fn attr ->
        Module.register_attribute(__MODULE__, attr, accumulate: true)
      end)

      Module.put_attribute(__MODULE__, :gs_enforce?, unquote(!!opts[:enforce]))

      Module.put_attribute(
        __MODULE__,
        :gs_caller,
        %{key: unquote(key), module: __MODULE__, caller: unquote(caller)}
      )

      Module.put_attribute(__MODULE__, :gs_authorized_fields, unquote(!!opts[:authorized_fields]))

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

  @spec __field__(atom(), any(), keyword(), Macro.Env.t(), boolean(), boolean()) :: nil | :ok
  @doc false
  def __field__(name, type, opts, env_data, subfield, cond? \\ false)

  def __field__(name, type, opts, %Macro.Env{module: mod} = _env, sub_field, cond?)
      when is_atom(name) do
    gs_fields = Module.get_attribute(mod, :gs_fields)
    gs_conditional = Module.get_attribute(mod, :gs_conditional_fields)
    conditional = Keyword.get(gs_conditional, name)

    # We check if this field is already set and it is not conditional type, so should send error to user

    if Keyword.has_key?(gs_fields, name) and !Keyword.has_key?(gs_conditional, name) do
      raise ArgumentError, "the field #{inspect(name)} is already set"
    end

    # If for this name, there is no record which be submitted
    if !Keyword.has_key?(gs_conditional, name) do
      config(:core_keys, opts, mod, name)
      config(:derive, opts, mod, name)
      config(:struct, opts, sub_field, mod, name)
      config(:fields_types, opts, mod, name, type)
    end

    # In this line, we should update conditional moduale attributes
    if cond? or Keyword.has_key?(gs_conditional, name),
      do: config(:conditional, opts, mod, name, conditional, sub_field)
  end

  def __field__(name, _type, _opts, _env, _sub_field, _cond?) do
    raise ArgumentError, "a field name must be an atom, got #{inspect(name)}"
  end

  @spec builder(
          %{
            :attrs => map(),
            :module => module(),
            :revaluation => list(),
            optional(any()) => any()
          },
          :root | list(atom()),
          :add | :edit,
          boolean()
        ) :: {:ok, map() | list(map())} | {:error, any(), any()}
  @doc false
  def builder(actions, key, type, error \\ false) do
    %{attrs: attrs, module: module, revaluation: [h | t]} = actions
    [enforces, validator, main_validator, derives, authorized, external, core_keys, _, _] = t
    found_main_validator = Enum.find(main_validator, &is_tuple(&1))
    fields = h |> Enum.map(&elem(&1, 0))
    conditionals = Enum.at(t, 7)

    attrs
    |> before_revaluation(key)
    |> authorized_fields(fields, authorized)
    |> required_fields(enforces)
    |> Parser.convert_to_atom_map()
    |> auto_core_key(core_keys, type)
    |> domain_core_key(attrs)
    |> on_core_key(attrs)
    |> from_core_key()
    |> conditional_fields_validating(conditionals, type, key)
    |> sub_fields_validating(fields, module, external, key, type)
    |> fields_validating(validator, module)
    |> main_validating(found_main_validator, main_validator, module)
    |> replace_condition_fields_derives(derives)
    |> Derive.derive()
    |> exceptions_handler(module, error)
  end

  defp before_revaluation(attrs, :root), do: attrs

  defp before_revaluation(attrs, [:root]), do: attrs

  defp before_revaluation(attrs, key) when is_list(key) do
    data = get_in(attrs, Parser.map_keys(attrs, key))
    if is_map(data), do: data, else: Map.new([{:bad_parameters, data}])
  end

  defp before_revaluation(attrs, key) do
    data = Map.get(attrs, Parser.map_keys(attrs, key))
    if is_map(data), do: data, else: Map.new([{:bad_parameters, data}])
  end

  @spec authorized_fields(map() | list(), list(atom()), list()) ::
          {:ok, any()} | {:error, :authorized_fields, list(), :halt}
  @doc false
  def authorized_fields(attrs, fields, authorized) do
    case check_authorized_fields(attrs, fields, authorized) do
      {_, true, _} -> {:ok, attrs}
      {_, false, filtered} -> {:error, :authorized_fields, filtered, :halt}
    end
  end

  @spec required_fields({:ok, map()} | {:error, any(), any(), :halt}, any()) ::
          {:ok, map()} | {:error, any(), any(), :halt}
  @doc false
  def required_fields({:ok, attrs}, enforces) do
    with missing_keys <- Enum.reject(Parser.map_keys(attrs, enforces), &Map.has_key?(attrs, &1)),
         {:missing_keys, true, _missing_keys} <-
           {:missing_keys, Enum.empty?(missing_keys), missing_keys} do
      {:ok, attrs}
    else
      {:missing_keys, false, missing_keys} ->
        {:error, :required_fields, missing_keys, :halt}
    end
  end

  def required_fields({:error, _, _, :halt} = error, _), do: error

  defp auto_core_key({:error, _, _, :halt} = error, _, _), do: error

  defp auto_core_key(attrs, core_keys, type) do
    reduce_attrs =
      Enum.filter(core_keys, fn {_key, %{type: type, values: _}} -> type == :auto end)
      |> Enum.reduce(attrs, fn item, acc ->
        case {type, !is_nil(Map.get(acc, elem(item, 0))), item} do
          {:edit, true, {key, %{type: :auto, values: _value}}} ->
            Map.put(acc, key, Map.get(acc, key))

          {_, _, {key, %{type: :auto, values: {module, function, default}}}}
          when is_list(default) ->
            Map.put(acc, key, apply(module, function, default))

          {_, _, {key, %{type: :auto, values: {module, function, default}}}} ->
            Map.put(acc, key, apply(module, function, [default]))

          {_, _, {key, %{type: :auto, values: {module, function}}}} ->
            Map.put(acc, key, apply(module, function, []))

          _ ->
            acc
        end
      end)

    {reduce_attrs, core_keys}
  end

  defp domain_core_key({:error, _, _, :halt} = error, _), do: error

  defp domain_core_key({attrs, core_keys}, full_attars) do
    # It is important to think about the fact that the `domain` core key does not
    # consider any update of  the `auto` core key and instead examines the data that was initially entered in the `builder`.
    # The information that was entered is not altered in any way by this function; it is merely validating it.
    domain_parameters_errors =
      Enum.map(core_keys, fn
        {key, %{type: :domain, values: pattern}} ->
          parsed =
            parse_domain_patterns(pattern, key, full_attars, attrs)
            |> List.flatten()

          if length(parsed) == 0, do: nil, else: parsed

        _ ->
          nil
      end)
      |> Enum.reject(&is_nil(&1))
      |> List.flatten()

    if length(domain_parameters_errors) == 0,
      do: {:ok, attrs, core_keys},
      else: {:error, :domain_parameters, domain_parameters_errors, :halt}
  end

  defp on_core_key({:error, _, _, :halt} = error, _), do: error

  defp on_core_key({:ok, attrs, core_keys}, full_attrs) do
    full_attrs = Parser.convert_to_atom_map(full_attrs)
    dependent_keys_errors = check_dependent_keys(attrs, core_keys, full_attrs)

    if length(dependent_keys_errors) == 0,
      do: {:ok, attrs, core_keys, full_attrs},
      else: {:error, :dependent_keys, dependent_keys_errors, :halt}
  end

  defp from_core_key({:error, _, _, :halt} = error), do: error

  defp from_core_key({:ok, attrs, core_keys, full_attrs}) do
    reduce_attrs =
      Enum.filter(core_keys, fn {_key, %{type: type, values: _}} -> type == :from end)
      |> Enum.reduce(attrs, fn {key, %{type: :from, values: pattern}}, acc ->
        splited_pattern = Parser.parse_core_keys_pattern(pattern)
        [h | t] = splited_pattern

        if(h == :root, do: get_in(full_attrs, t), else: get_in(attrs, splited_pattern))
        |> case do
          data when is_nil(data) -> acc
          data -> Map.put(acc, key, data)
        end
      end)

    {:ok, reduce_attrs, full_attrs}
  end

  defp conditional_fields_validating({:error, _, _, :halt} = error, _, _, _), do: error

  defp conditional_fields_validating({:ok, attrs, full_attrs}, conditionals, type, key) do
    {cond_fields, uncond_fields} = conditionals_fields_parameters_divider(attrs, conditionals)

    cond_builders =
      Enum.map(cond_fields, fn {field, value} ->
        cond_data = Keyword.get(conditionals, field)
        list_conditional = Keyword.get(cond_data.opts, :structs)

        {cond_data, field, value, full_attrs, key, type, list_conditional}
        |> conditional_fields_validating_pattern()
      end)

    cond_data = conditionals_fields_data_divider(cond_builders)
    {:ok, uncond_fields, cond_data, full_attrs}
  end

  @spec sub_fields_validating(
          {:error, any(), any(), :halt} | {:ok, map(), list(), map() | list()},
          list(atom()),
          module(),
          keyword(),
          atom(),
          :add | :edit
        ) :: {:error, any(), any(), :halt} | {map(), list(), list(), list(), any()}
  @doc false
  def sub_fields_validating({:error, _, _, :halt} = error, _, _, _, _, _), do: error

  def sub_fields_validating({:ok, attrs, conds, full_attrs}, fields, module, external, key, type) do
    allowed_fields = Map.take(attrs, fields) |> Map.keys()
    sub_modules = get_fields_sub_module(module, allowed_fields, external)

    sub_modules_builders =
      sub_modules
      |> Enum.map(fn
        %{field: field, module: module, type: :list} ->
          {field, list_builder(full_attrs, module, field, key, type)}

        %{field: field, module: module, type: :struct} ->
          keys =
            reverse_module_keys(Module.split(module), field)
            |> combine_parent_field(if(is_list(key), do: key, else: [key]))
            |> List.delete(:root)

          {field, module.builder({keys, full_attrs, type})}
      end)

    {
      attrs,
      sub_modules_builders_data(sub_modules_builders),
      sub_modules_builders_errors(sub_modules_builders),
      reject_sub_module_fields(allowed_fields, sub_modules),
      conds
    }
  end

  @spec fields_validating(
          {:error, any(), any(), :halt} | {map(), map() | list(map()), list(), list(), keyword()},
          any(),
          any()
        ) :: {:error, any(), any(), :halt} | {list(), any(), any(), any(), any()}
  @doc false
  def fields_validating({:error, _, _, :halt} = error, _, _), do: error

  def fields_validating({attrs, sub_data, sub_errors, unsub, conds}, validator, module) do
    # Just keep the normal fields of attrs
    allowed_data = Map.take(attrs, unsub)

    validated =
      allowed_data
      |> Enum.map(fn {key, value} ->
        GuardedStruct.find_validator(key, value, validator, module)
      end)

    validated_errors =
      Enum.filter(validated, fn {status, _field, _error_or_data} -> status == :error end)
      |> Enum.map(fn {_status, field, error_or_data} ->
        %{field: field, message: error_or_data}
      end)

    validated_allowed_data =
      if length(validated_errors) == 0,
        do: convert_list_tuple_to_map(validated),
        else: allowed_data

    {validated_errors, validated_allowed_data, sub_data, sub_errors, conds}
  end

  @spec main_validating(
          {:error, any(), any()}
          | {:error, any(), any(), :halt}
          | {list(), any(), any(), list(),
             %{:data => any(), :errors => any(), optional(any()) => any()}},
          nil | tuple(),
          list(boolean()),
          module()
        ) ::
          {:error, any(), any()}
          | {:ok, map(), any()}
          | {:error, any(), any(), :halt}
          | {:error, :bad_parameters, :nested, list(), struct(), any()}
  @doc false
  def main_validating({:error, _, _, :halt} = error, _, _, _), do: error

  def main_validating({:error, _, _} = error, _, _, _), do: error

  def main_validating(validating_input, main_validator, gs_main_validator, module) do
    {validated_errors, validated_allowed_data, sub_data, sub_errors, conds} =
      validating_input

    {status, main_outputs} =
      cond do
        !is_nil(main_validator) ->
          {module, func} = main_validator
          apply(module, func, [validated_allowed_data])

        gs_main_validator == [true] ->
          apply(module, :main_validator, [validated_allowed_data])

        true ->
          {:ok, validated_allowed_data}
      end

    # We summarized the main logic in the following function
    # This helps us to better analyze the output of the conditional fields section
    {status, validated_errors, sub_errors, conds, module, main_outputs, sub_data}
    |> validation_errors_aggregator()
  end

  @spec replace_condition_fields_derives(tuple(), list(map())) :: any()
  @doc false
  def replace_condition_fields_derives({:ok, data, conds}, derives) do
    new_derives =
      Enum.reject(derives, &(&1.field in Enum.uniq(Keyword.keys(conds)))) ++
        Derive.get_derives_from_success_conditional_data(conds)

    {:ok, data, new_derives}
  end

  def replace_condition_fields_derives(
        {:error, :bad_parameters, :nested, _, _, conds} = error,
        derives
      ) do
    new_derives =
      Enum.reject(derives, &(&1.field in Enum.uniq(Keyword.keys(conds)))) ++
        Derive.get_derives_from_success_conditional_data(conds)

    error
    |> Tuple.delete_at(5)
    |> Tuple.insert_at(5, new_derives)
  end

  def replace_condition_fields_derives(error, _derives), do: error

  @spec exceptions_handler({:ok, any()} | {:error, any(), any()}, module(), boolean()) ::
          {:ok, any()} | {:error, any(), any()}
  @doc false
  def exceptions_handler(ouput, module, exception \\ false)

  def exceptions_handler({:ok, _} = successful_output, _, _), do: successful_output

  def exceptions_handler({:error, _, _} = error_output, _module, false), do: error_output

  def exceptions_handler({:error, term, error_list}, module, true) do
    concated = Module.safe_concat([module, Error])
    raise(concated, term: term, errors: error_list)
  end

  ####################################################################
  ################### (▰˘◡˘▰) Helpers (▰˘◡˘▰) ##################
  ####################################################################

  @spec reverse_module_keys(list(String.t()), atom()) :: list()
  @doc false
  def reverse_module_keys(splited_module, key) do
    path =
      for {_module, idx} <- Enum.with_index(splited_module) do
        Enum.join(Enum.take(splited_module, idx + 1), ".")
      end
      |> Enum.reverse()
      |> tl
      |> Enum.reduce_while([], fn item, acc ->
        concated = Module.concat(String.split(item, ".", trim: true))

        {Code.ensure_loaded(concated), function_exported?(concated, :__information__, 0)}
        |> case do
          {{:module, module}, true} ->
            module_info = apply(module, :__information__, [])

            if(module_info.key == :root,
              do: {:halt, acc},
              else: {:cont, acc ++ [module_info.key]}
            )

          _ ->
            {:halt, acc}
        end
      end)

    path ++ [key]
  end

  @spec find_validator(atom(), any(), keyword(), module()) :: any()
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

  @spec get_fields_sub_module(module(), list(atom()), keyword(), boolean()) :: list()
  @doc false
  def get_fields_sub_module(module, fields, external, list \\ false) do
    Enum.map(fields, fn field ->
      extra_field = Keyword.get(external, field)

      find_module =
        if(!is_nil(extra_field),
          do: [Keyword.get(external, field).module],
          else: [module, atom_to_module(field)]
        )

      {!is_nil(extra_field), Code.ensure_loaded(Module.concat(find_module))}
      |> case do
        {true, {:module, module}} ->
          if !list, do: %{field: field, module: module, type: extra_field.type}, else: field

        {false, {:module, module}} ->
          if !list, do: %{field: field, module: module, type: :struct}, else: field

        _ ->
          nil
      end
    end)
    |> Enum.reject(&is_nil(&1))
  end

  @spec show_nested_keys(atom() | tuple(), atom()) :: list()
  @doc false
  def show_nested_keys(module, type \\ :keys) do
    apply(module, type, [])
    |> Enum.map(fn item ->
      sub_module = create_module_name(item, module, :direct)

      if Code.ensure_loaded?(sub_module) do
        Map.new([{item, show_nested_keys(sub_module)}])
      else
        item
      end
    end)
  end

  @spec create_module_name(atom(), Macro.t(), atom()) :: atom()
  @doc false
  def create_module_name(name, module_name, type \\ :macro) do
    name
    |> atom_to_module()
    |> then(&Module.concat(if(type == :macro, do: module_name.module, else: module_name), &1))
  end

  @spec config(
          :conditional,
          keyword(),
          module(),
          atom(),
          nil | %{:fields => list(), optional(any()) => any()}
        ) :: :ok
  @doc false
  def config(:conditional, opts, mod, name, nil, _sub?) do
    field = {name, %{field: name, opts: opts, caller: mod, fields: [], sub_fields_count: 0}}
    Module.put_attribute(mod, :gs_conditional_fields, field)
  end

  def config(:conditional, opts, mod, name, gs_conditional, sub?) do
    %{sub_fields_count: sub_fields_count} = gs_conditional
    count = if sub?, do: sub_fields_count + 1, else: sub_fields_count
    list_field? = Keyword.has_key?(opts, :structs)

    field = [%{sub?: false, opts: opts, name: name, module: nil, list?: list_field?}]

    Module.put_attribute(
      mod,
      :gs_conditional_fields,
      {name,
       Map.merge(gs_conditional, %{
         sub_fields_count: count,
         fields: gs_conditional.fields ++ field
       })}
    )
  end

  @spec config(:fields_types | :struct, keyword(), module(), atom(), any()) :: nil | :ok
  @doc false
  def config(:fields_types, opts, mod, name, type) do
    has_default? = Keyword.has_key?(opts, :default)
    enforce_by_default? = Module.get_attribute(mod, :gs_enforce?)

    enforce? =
      if is_nil(opts[:enforce]),
        do: enforce_by_default? && !has_default?,
        else: !!opts[:enforce]

    nullable? = !has_default? && !enforce?

    Module.put_attribute(mod, :gs_fields, {name, opts[:default]})
    Module.put_attribute(mod, :gs_types, {name, type_for(type, nullable?)})
    if enforce?, do: Module.put_attribute(mod, :gs_enforce_keys, name)
  end

  def config(:struct, opts, sub_field, mod, name) do
    struct? = Keyword.has_key?(opts, :struct)

    if !sub_field and (struct? or Keyword.has_key?(opts, :structs)) do
      Module.put_attribute(
        mod,
        :gs_external,
        {name,
         %{
           module: opts[:struct] || opts[:structs],
           type: if(struct?, do: :struct, else: :list)
         }}
      )
    end

    if sub_field do
      converted_name = create_module_name(name, mod, :direct)

      if Keyword.get(opts, :structs) do
        Module.put_attribute(
          mod,
          :gs_external,
          {name, %{module: converted_name, type: :list}}
        )
      end
    end
  end

  @spec config(:core_keys | :derive, keyword(), module(), atom()) :: nil | :ok
  @doc false
  def config(:derive, opts, mod, name) do
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
  end

  def config(:core_keys, opts, mod, name) do
    Enum.each([:on, :from, :auto, :domain], fn item ->
      if Keyword.has_key?(opts, item) do
        core_key = %{values: opts[item], type: item}
        Module.put_attribute(mod, :gs_core_keys, {name, core_key})
      end
    end)
  end

  @spec sub_conditional_field_module(
          keyword(),
          atom(),
          atom()
          | binary()
          | list()
          | number()
          | {any(), any()}
          | {atom() | {any(), list(), atom() | list()}, keyword(), atom() | list()}
        ) :: %{cond?: boolean(), name: atom()}
  @doc false
  def sub_conditional_field_module(conditionals, name, env) do
    case Keyword.get(conditionals, name) do
      nil ->
        %{name: create_module_name(name, env), cond?: false}

      data ->
        module_number = String.to_atom("#{name}#{Integer.to_string(data.sub_fields_count + 1)}")
        %{name: create_module_name(module_number, env), cond?: true}
    end
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

  defp list_builder(attrs, module, field, key, type, cond_list \\ nil)

  defp list_builder(_attrs, nil, _field, _key, _type, _cond_list) do
    {:error, :bad_parameters,
     "Unfortunately, the appropriate settings have not been applied to the desired field."}
  end

  defp list_builder(_attrs, true, _field, _key, _type, _cond_list) do
    # Developers are advised to use special conditional settings for conditional data that
    # will be checked as a list. If you need a standard field to accommodate a list,
    # there are two options:

    # The first method: there is no need to include it in the `structs: true` subset;
    # instead, you can derive or validate each piece of data.
    # The alternative is to utilize an external module.
    # Invoking a different structure from a different module within the corresponding section

    # The reason why this issue exists:
    # Due to the macro structure, I opted for a list data iteration that was appropriate.
    # For each subfield, I generate a module and struct.
    # If a standard field is called again without the module,
    # the source data is repeated in this field. Additionally,
    # this field cannot be sent alone,
    # as the constructor module functions as a pipeline that verifies every
    # requirement until it reaches its conclusion. You are required to transmit all data.

    # An alternative course of action is to update the library. Remember to send PR to this lib :)
    # **That is why we should construct a builder that verifies this key exclusively from the root path.**
    raise(
      "Oh no!, We do not currently support using a normal field as a list without an extra module."
    )
  end

  defp list_builder(attrs, module, field, key, type, cond_list) do
    field_path =
      reverse_module_keys(Module.split(module), field)
      |> combine_parent_field(if(is_list(key), do: key, else: [key]))
      |> List.delete(:root)

    get_field =
      if is_nil(cond_list),
        do: get_in(attrs, field_path),
        else: update_in(attrs, field_path, fn _ -> cond_list end) |> get_in(field_path)

    if is_list(get_field) do
      builders_output =
        Enum.map(get_field, fn
          item when is_list(item) ->
            Enum.map(item, &module.builder({field_path, Map.put(attrs, field, &1), type}))

          item ->
            module.builder({field_path, Map.put(attrs, field, item), type})
        end)

      errors =
        List.flatten(builders_output)
        |> Enum.find(&(elem(&1, 0) == :error))

      errors ||
        {:ok,
         Enum.map(builders_output, fn
           item when is_list(item) -> Enum.map(item, &elem(&1, 1))
           item -> elem(item, 1)
         end)}
    else
      {:error, :bad_parameters, "Your input must be a list of items"}
    end
  end

  defp combine_parent_field(module_keys, parent_list) do
    combined_list = parent_list ++ module_keys
    Enum.uniq(combined_list)
  end

  defp atom_to_module(field) do
    field
    |> Atom.to_string()
    |> Macro.camelize()
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

  defp check_dependent_keys(attrs, core_keys, full_attrs) do
    Enum.map(core_keys, fn
      {key, %{type: :on, values: pattern}} ->
        splited_pattern = Parser.parse_core_keys_pattern(pattern)
        [h | t] = splited_pattern

        with get_key_value <- Map.get(full_attrs, key) || Map.get(attrs, key),
             {:get_key_value, false} <- {:get_key_value, is_nil(get_key_value)},
             get_value <-
               if(h == :root, do: get_in(full_attrs, t), else: get_in(attrs, splited_pattern)),
             {:get_value, false} <- {:get_value, !is_nil(get_value)} do
          %{
            message: """
            The required dependency for field #{Atom.to_string(key)} has not been submitted.
            You must have field #{List.last(splited_pattern) |> Atom.to_string()} in your input
            """,
            field: key
          }
        else
          {:get_key_value, true} -> nil
          {:get_value, true} -> nil
        end

      _ ->
        nil
    end)
    |> Enum.reject(&is_nil(&1))
  end

  # Makes the type nullable if the key is not enforced.
  defp type_for(type, false), do: type

  defp type_for(type, _), do: quote(do: unquote(type) | nil)

  defp check_authorized_fields(attrs, fields, authorized_fields) do
    case List.first(authorized_fields) do
      false ->
        {:authorized_fields, true, []}

      true ->
        filtered = Enum.filter(Map.keys(attrs), &(&1 not in Parser.map_keys(attrs, fields)))
        {:authorized_fields, length(filtered) == 0, filtered}
    end
  end

  defp domain_field_status(field, attrs, converted_pattern, key, force \\ nil) do
    domain_field = get_domain_field(field, attrs)
    converted_pattern = converted_domain_pattern(converted_pattern)

    if !is_nil(domain_field) do
      ValidationDerive.validate(converted_pattern, domain_field, key)
      |> case do
        data when is_tuple(data) and elem(data, 0) == :error ->
          %{
            message: "Based on field #{key} input you have to send authorized data",
            field_path: field,
            field: key
          }

        _ ->
          nil
      end
    else
      if is_nil(force),
        do: nil,
        else: %{
          message:
            "Based on field #{key} input you have to send authorized data and required key",
          field_path: field,
          field: key
        }
    end
  end

  defp converted_domain_pattern(converted_pattern) do
    converted_pattern
    |> case do
      "Tuple" <> list ->
        {:enum, "Tuple[#{re_structure_domain_for_derive(list, "string")}]"}

      "Map" <> list ->
        {:enum, "Map[#{re_structure_domain_for_derive(list, "string")}]"}

      "Equal" <> data ->
        converted_data =
          data
          |> String.replace(["[", "]"], "")
          |> String.replace(">>", "::")

        {:equal, converted_data}

      "Either" <> list ->
        converted_data =
          list
          |> String.replace("enum>>", "enum=")
          |> String.replace(">>", "::")
          |> then(&Parser.convert_parameters("parsed_string", Code.string_to_quoted!(&1)))

        %{either: converted_data["parsed_string"]}

      "Custom" <> list ->
        {:custom, list}

      data ->
        {:enum, re_structure_domain_for_derive(data)}
    end
  end

  defp parse_domain_patterns(pattern, key, full_attrs, attrs) do
    # "!auth=String[admin, user]::?auth.social=Atom[banned, moderated]"
    # for example `auth.social` should be atom and between `banned` and `moderated`
    # ? and ! means the `auth.social` can exist or not and if yes it should be atom and between the values
    # We change attrs instead of full_attrs inside Map get to support it inside children
    (Map.get(full_attrs, key) || Map.get(attrs, key))
    |> case do
      nil ->
        []

      _ ->
        pattern
        |> String.trim()
        |> String.split("::", trim: true)
        |> Enum.map(&String.split(&1, "=", trim: true))
        |> Enum.map(fn
          ["!" <> field, converted_pattern] ->
            domain_field_status(field, full_attrs, converted_pattern, key, :error)

          ["?" <> field, converted_pattern] ->
            domain_field_status(field, full_attrs, converted_pattern, key)
        end)
        |> Enum.reject(&is_nil(&1))
    end
  end

  defp get_domain_field(field, attrs) do
    field
    |> String.trim()
    |> String.split(".", trim: true)
    |> Enum.map(&String.to_atom/1)
    |> then(&get_in(attrs, &1))
  end

  defp re_structure_domain_for_derive(data) do
    data
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.join("::")
  end

  defp re_structure_domain_for_derive(data, "string") do
    {converted, []} = Code.eval_string(data)

    Enum.reduce(converted, "", fn item, acc ->
      acc <> "#{Macro.to_string(item)}::"
    end)
  end

  defp conditionals_fields_data_divider(builders) do
    Enum.reduce(builders, %{data: [], errors: []}, fn
      {field, conds, priority}, acc ->
        # TODO: it just keeps one derive not list of them
        %{data: data, errors: errors} =
          {field, conds, acc, priority}
          |> separate_conditions_based_priority()

        %{data: acc.data ++ data, errors: acc.errors ++ errors}

      list, acc ->
        grouped =
          Enum.group_by(list, fn
            {key, [{_, _, _} | _], _} -> key
            [{key, _field_errors, _} | _] -> key
            {key, _field_errors, _} -> key
          end)

        field = grouped |> Map.keys() |> List.first()

        field_data = Map.get(grouped, field)

        priority =
          if is_list(field_data) and is_tuple(List.first(field_data)) do
            List.first(field_data) |> elem(2)
          else
            false
          end

        %{data: data, errors: errors} =
          {field, Map.get(grouped, field), acc, priority}
          |> separate_conditions_based_priority("list")

        %{data: acc.data ++ data, errors: acc.errors ++ errors}
    end)
  end

  defp separate_conditions_based_priority(params, type \\ "normal")

  defp separate_conditions_based_priority({field, conds, acc, priority}, "normal") do
    [success_data, error_data] = reduce_success_data_and_error_data(conds)

    derives = Enum.map(success_data, fn {_data, derive} -> derive end)

    data =
      if(length(success_data) > 0,
        do: [{field, {List.first(success_data) |> elem(0), derives}}],
        else: []
      )

    Map.merge(acc, %{
      errors:
        if(length(error_data) > 0 and length(success_data) == 0,
          do: [{field, if(priority, do: [List.first(error_data)], else: error_data)}],
          else: []
        ),
      data: data
    })
  end

  defp separate_conditions_based_priority({field, conds, acc, priority}, "list") do
    [success_data, error_data] =
      Enum.map(conds, fn
        item when is_tuple(item) ->
          elem(item, 1)

        item when is_list(item) ->
          [{_key, field_errors, _} | _] = item
          field_errors
      end)
      |> Enum.reduce([[], []], fn values, [data, error] ->
        ok_data = Enum.find(values, &Parser.field_status?(&1, :ok))
        error_data = Enum.filter(values, &Parser.field_status?(&1, :error))

        if(!is_nil(ok_data)) do
          {value, opts} = Parser.field_value(ok_data)
          [data ++ [{{:ok, Map.new([{field, value}])}, opts}], error]
        else
          [data, error ++ Parser.field_value(error_data)]
        end
      end)

    Map.merge(acc, %{
      errors:
        if(length(error_data) > 0,
          do: [
            {field,
             if(priority, do: [List.first(Enum.uniq(error_data))], else: Enum.uniq(error_data))}
          ],
          else: []
        ),
      data: if(length(success_data) > 0, do: [{field, success_data}], else: [])
    })
  end

  @spec reduce_success_data_and_error_data(list(any())) :: list(any())
  @doc false
  def reduce_success_data_and_error_data(conds) do
    Enum.reduce(conds, [[], []], fn
      {{:ok, key, value}, opts}, [data, error] ->
        [data ++ [{{:ok, Map.new([{key, value}])}, opts}], error]

      {{:ok, success}, key, opts}, [data, error] ->
        [data ++ [{{:ok, Map.new([{key, success}])}, opts}], error]

      {{:error, _key, _value}, _opts} = output, [data, error] ->
        [data, error ++ [output]]

      {{:error, _type, _error}, _key, _opts} = output, [data, error] ->
        [data, error ++ [output]]

      {{:error, _erros}, _key, _opts} = output, [data, error] ->
        [data, error ++ [output]]
    end)
  end

  # The priority in this section is the comprehensibility of the codes.
  # This part is hard enough and how to call errors is complicated
  defp validation_errors_aggregator(
         {status, validated_errors, sub_builders_errors, conds, module, main_error_or_data,
          sub_builders}
       ) do
    {status, length(validated_errors), length(sub_builders_errors), Parser.is_data?(conds)}
    |> case do
      {:ok, 0, 0, true} ->
        merged_struct =
          Enum.reduce(sub_builders, struct(module, main_error_or_data), fn item, acc ->
            Map.merge(acc, item)
          end)
          |> Map.merge(cond_data_converter(conds))

        {:ok, merged_struct, conds.data}

      {:ok, 0, sub_errors, true} when sub_errors != [] ->
        {:error, :bad_parameters, :nested, sub_builders_errors,
         struct(module, main_error_or_data), conds.data}

      {:ok, _, _, false} ->
        errors = cond_errors_converter(conds)

        {:error, :bad_parameters, validated_errors ++ sub_builders_errors ++ errors}

      {:error, _, _, false} ->
        errors = cond_errors_converter(conds)

        {:error, :bad_parameters,
         validated_errors ++ sub_builders_errors ++ [main_error_or_data] ++ errors}

      {:ok, _, _, true} ->
        {:error, :bad_parameters, validated_errors ++ sub_builders_errors}

      {:error, _, _, true} ->
        {:error, :bad_parameters, validated_errors ++ sub_builders_errors ++ [main_error_or_data]}
    end
  end

  defp cond_data_converter(conds) do
    Enum.reduce(conds.data, %{}, fn
      {field, {{:ok, data}, _opts}}, acc ->
        Map.put(acc, field, Map.get(data, List.first(Map.keys(data))))

      {field, values}, acc ->
        data = Enum.map(values, &Map.get(Parser.field_value(&1) |> elem(0), field))
        Map.put(acc, field, data)
    end)
  end

  defp cond_errors_converter(conds) do
    Enum.reduce(conds.errors, [], fn {field, entries}, acc ->
      # Suppose that in the front end, the programmer believes that only two types of errors
      # should be returned, whereas in the rear end, four modes are considered. Currently,
      # the individual who will use the API does not comprehend for which mode this error is sent.
      # Similarly, if hint is set, it can indicate which mode this error is sent in.
      # This section only applies to fields with conditions.
      # It should be noted that the hint must be documented as a custom contract in the user's document.
      transformed_errors =
        Enum.map(entries, fn
          {error, opts} ->
            if(elem(error, 0) == :error, do: Tuple.delete_at(error, 0), else: error)
            |> add_hint(Keyword.get(opts, :hint))

          {error, _field, opts} ->
            if(elem(error, 0) == :error, do: Tuple.delete_at(error, 0), else: error)
            |> add_hint(Keyword.get(opts, :hint))
        end)

      acc ++ [%{field: field, action: :conditionals, errors: transformed_errors}]
    end)
  end

  defp add_hint(error, nil) when is_tuple(error), do: error

  defp add_hint(error, hint) when is_tuple(error) do
    Tuple.insert_at(error, tuple_size(error), __hint__: hint)
  end

  defp get_field_validator(opts, caller, field, value) do
    case Keyword.get(opts, :validator) do
      nil ->
        # In this place we checke local validator function of caller
        if Code.ensure_loaded?(caller) and
             function_exported?(caller, :validator, 2),
           do: apply(caller, :validator, [field, value]),
           else: {:ok, field, value}

      {module, func} ->
        apply(module, func, [field, value])

      _ ->
        {:ok, field, value}
    end
  end

  # We could merge these 2 function with `when` but, I think we need it in the future.
  defp execute_field_validator({opts, module, field, value, key, type, full_attrs}, :list_field) do
    structs = if Keyword.get(opts, :structs), do: module, else: Keyword.get(opts, :structs)

    case get_field_validator(opts, module, field, value) do
      {:ok, _field, value} ->
        {list_builder(full_attrs, structs, field, key, type, value), field, opts}

      error ->
        {error, opts}
    end
  end

  defp execute_field_validator(
         {opts, caller, field, value, key, type, full_attrs},
         :list_external
       ) do
    case get_field_validator(opts, caller, field, value) do
      {:ok, _field, value} ->
        {list_builder(full_attrs, Keyword.get(opts, :structs), field, key, type, value), field,
         opts}

      error ->
        {error, opts}
    end
  end

  defp execute_field_validator({opts, caller, field, value, type, module}, :external) do
    case get_field_validator(opts, caller, field, value) do
      {:ok, _field, _value} ->
        {module.builder({:root, value, type}), field, opts}

      error ->
        {error, opts}
    end
  end

  defp execute_field_validator(
         {opts, caller, field, value, module, key, full_attrs, type},
         :sub_field
       ) do
    case get_field_validator(opts, caller, field, value) do
      {:ok, _field, _value} ->
        keys =
          reverse_module_keys(Module.split(module), field)
          |> combine_parent_field(if(is_list(key), do: key, else: [key]))
          |> List.delete(:root)

        full_attrs = update_in(full_attrs, keys, fn _ -> value end)

        {module.builder({keys, full_attrs, type}), field, opts}

      error ->
        {error, opts}
    end
  end

  defp conditionals_fields_parameters_divider(attrs, conditionals) do
    Enum.reduce(attrs, {%{}, %{}}, fn {key, val}, {cond_acc, uncond_acc} ->
      if Keyword.has_key?(conditionals, key),
        do: {Map.put(cond_acc, key, val), uncond_acc},
        else: {cond_acc, Map.put(uncond_acc, key, val)}
    end)
  end

  @spec conditional_fields_validating_pattern(
          {any(), atom(), list(any()), map() | list(), atom(), :add | :edit, boolean()}
        ) ::
          list() | {any(), list(), any()}
  @doc false
  def conditional_fields_validating_pattern(
        {cond_data, field, list_values, full_attrs, key, type, true}
      )
      when is_list(list_values) do
    outputs =
      Enum.map(list_values, fn value ->
        {cond_data, field, value, full_attrs, key, type, false}
        |> conditional_fields_validating_pattern()
      end)

    outputs
  end

  def conditional_fields_validating_pattern(
        {_cond_data, field, _list_values, _full_attrs, _key, _type, true}
      ) do
    [
      [
        {field,
         [
           {{:error, :bad_parameters, "Your input must be a list of maps"}, field, []}
         ], false}
      ]
    ]
  end

  def conditional_fields_validating_pattern({cond_data, field, value, full_attrs, key, type, _}) do
    output =
      Enum.map(cond_data.fields, fn
        # Normail field that has custom validator function, if it does not. should pass ok
        # The priority is with the external module
        %{sub?: false, opts: opts, module: nil, list?: false} ->
          case Keyword.get(opts, :struct) do
            nil ->
              {get_field_validator(opts, cond_data.caller, field, value), opts}

            module ->
              if !Code.ensure_loaded?(module) do
                {get_field_validator(opts, cond_data.caller, field, value), opts}
              else
                {opts, cond_data.caller, field, value, type, module}
                |> execute_field_validator(:external)
              end
          end

        %{sub?: false, opts: opts, module: nil, list?: true} ->
          # It is not a sub field, but it should load external module
          # because we have no normal field which is list
          {opts, cond_data.caller, field, value, key, type, full_attrs}
          |> execute_field_validator(:list_external)

        %{sub?: true, opts: opts, module: module, list?: false} ->
          # It is a sub field and just accepts a map not list of map
          {opts, cond_data.caller, field, value, module, key, full_attrs, type}
          |> execute_field_validator(:sub_field)

        %{sub?: true, opts: opts, module: module, list?: true} ->
          # It is a sub field and accepts a list of maps
          {opts, module, field, value, key, type, full_attrs}
          |> execute_field_validator(:list_field)
      end)

    {field, output, Keyword.get(cond_data.opts, :priority, false)}
  end
end
