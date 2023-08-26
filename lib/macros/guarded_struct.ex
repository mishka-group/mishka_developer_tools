defmodule GuardedStruct do
  @moduledoc """
  The creation of this macro will allow you to build `Structs` that provide you with a number of important options, including the following:

  1. Validation
  2. Sanitizing
  3. Constructor
  4. It provides the capacity to operate in a nested style simultaneously.

  Suppose you are going to collect a number of pieces of information from the user, and before doing anything else, you are going to sanitize them.
  After that, you are going to validate each piece of data, and if there are no issues, you will either display it in a proper output or save it somewhere else.
  All of the characteristics that are associated with this macro revolve around cleaning and validating the data.

  The features that we list below are individually based on a particular strategy and requirement, but thankfully, they may be combined and mixed in any way that you see fit.

  It bestows to you a significant amount of authority in this sphere.
  After the initial version of this macro was obtained from the source of the `typed_struct` library, many sections of it were rewritten, or new concepts were taken from libraries in Rust and Scala and added to this library in the form of Elixir base.

  The initial version of this macro can be found in the `typed_struct` library. Its base is a syntax that is very easy to comprehend, especially for non-technical product managers, and highly straightforward.

  Before explaining the copyright, I must point out that the primary library, which is `typed_struct`, is no longer supported for a long time, so please pay attention to the following copyright.

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
  ### Defines a guarded struct

  The beginning of the block consists of the introduction of a `Struct` with the `guardedstruct` macro, which is solely responsible for recording a series of information in order to create a struct, as well as all of the fields with the `field` macro, and if you need to create another struct within this struct (in actuality, a module child within another module), you must use the `sub_field` macro.

  **Note:** there is no restriction on the number of times you can call the `sub_field` macro or the field macro within the context of the `sub_field` macro.

  **Note:** Because `Stract` does not prioritize the display of keys depending on your requirements, you do not need to follow the priority of the fields and call them in order to utilize the app.
  Implement the program's logic, regardless of what it might be.

  **Note:** Because of different limitations, if you want to write a test, you must first place the module in which you built the struct outside of the test macro. Once the struct has been built, you may then test it by calling it within the test macro itself. The examples it provides can also be found in the testing done by this library itself.

  **Note:** this library is only supported on versions of `Elixir 1.15` and higher, as well as `OTP 26`, and that the manufacturer does not offer bug patches for problems that occur in older software versions.

  **Note:** All of this library's dependencies are optional; nonetheless, if you require their use in your program, you will need to include them. We provide further explanation on the topic in the area you're looking for.

  > Before continuing with the discussion about the library section and also offering practical examples in this field, it is important to understand that when you construct a struct in a module, after compilation in the runtime of the program, each module includes the following functional functions:

  1. The `builder()` function is actually an action function, and it requires you to provide it with information in the form of a `map`.

  2. The `enforce_keys()` function: this method returns the necessary keys of the first layer of the struct. However, if you want to display all of the keys of the nested struct, you will need to enter the `:all` input, which is not yet implemented in this version.

  3. The `keys()` function has the same requirements as the `enforce_keys()` function, with the exception that it returns all of the keys, including the ones that aren't necessary.

  ---

  **And also, any data that enters the `builder` function must go through the following path:**

  1. If the `map` currently uses the `string` data type, it will be converted to the `atom` data type.

  2. Eliminates the keys from the `struct` that are not present in the list

  3. Determines whether or not all of the essential keys have been transmitted.

  4. If you write your own custom validation, each field's validations will be checked.

  > It is important to notice that regardless of the circumstances, this macro also inspects the module itself. If there is a `validator` function but none of the functions are set, it calls the validator function directly from the module itself into the field itself.

  5. The output of the complete `struct` is entered into the mother validation, and the programmer is given the opportunity to write for the final output in this validation. This validation also provides the possibility of writing for the output of the struct.

  > This macro will call the struct's `main_validator` directly from the module it has been placed in if, in this section, the `main_validator`  is not set in the struct but is found in the module that contains the struct.

  6. If there were no problems in the previous phases (it is important to note that options 4 and 5 are not required), it will proceed to the next level of the program, which is the validation and custom Sanitizer stage.

  7. To begin, the Sanitizer will alter the data so that it corresponds to what you have called in each field, and it will not return any errors. Even if the Sanitizer programmer is not utilized in the required type as a result of an accidental oversight, the data will still be passed to the following stage.

  8. At this point, it will return an error or data for each field, depending on the validations that you called.

  9. At the end of the process, you will receive a tuple that will either have problems in it or the final data with an ok status.

  > It is important to keep in mind that if your `struct` is nested, all of the internal errors of these structs are also included in the list of problems. Additionally, the data will be sent to you when the status is positive, but only if you have called the parent of this struct.

  > Note that each nested struct can be used on its own and possesses all of the capabilities that have been discussed thus far. For instance, if you have module `A` and you utilized the `sub_field` that is named `auth` in it, you may now use it separately from the `A.Auth` Use. Use.

  ---

  ### Examples

  1. #### Defining a struct layer without additional options

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

  ---

  2. #### Define a struct with settings related to essential keys or `opaque` type

  ##### Options

  * `enforce` - if set to true, sets `enforce: true` to all fields by default.
  This can be overridden by setting `enforce: false` or a default value on
  individual fields.
  * `opaque` - if set to true, creates an opaque type for the struct.
  * `module` - if set, creates the struct in a submodule named `module`.

  ```elixir
  defmodule MyModule do
    use GuardedStruct

    guardedstruct enforce: true do
      field(:enforced_by_default, term())
      field(:not_enforced, term(), enforce: false)
      field(:with_default, integer(), default: 1)
      field(:with_false_default, boolean(), default: false)
      field(:with_nil_default, term(), default: nil)
    end
  end

  # OR opaque

  defmodule MyModule do
    use GuardedStruct

    guardedstruct opaque: true do
      field(:enforced_by_default, term())
      field(:not_enforced, term(), enforce: false)
      field(:with_default, integer(), default: 1)
      field(:with_false_default, boolean(), default: false)
      field(:with_nil_default, term(), default: nil)
    end
  end

  # OR opaque

  defmodule MyModule do
    use GuardedStruct

    guardedstruct do
      field(:enforced_by_default, term())
      field(:not_enforced, term(), enforce: true)
      field(:with_default, integer(), default: 1)
      field(:with_false_default, boolean(), default: false)
      field(:with_nil_default, term(), default: nil)
    end
  end

  # OR create sub module

  defmodule TestModule do
    use GuardedStruct

    guardedstruct module: Struct do
      field(:field, term())
    end
  end
  ```

  ---

  3. #### Defining the struct by calling the validation module or calling from the module that contains the struct

  ##### Options
  * `validator` - if set as tuple like this {ModuleName, :function_name} for each field,
  in fact you have a `builder` function that check the validation.

  ```elixir
  # First, it looks at whether a validator has been set for each field,
  # otherwise it looks inside the module.
  defmodule MyModule do
    alias MyModule.AnotherModule
    use GuardedStruct

    guardedstruct do
      field(:name, String.t(), validator: {AnotherModule, :validator})
      field(:title, String.t())
    end

    def validator(:title, value) do
      {:ok, :title, value}
    end

    # You can not use it, but it is mentioned here for test clarity
    def validator(name, value) do
      {:ok, name, value}
    end
  end
  ```

  - Output without error: `{:ok, :field_name, value}`
  - Output with error: `{:error, :field_name, ERROR MESSAGE}`

  ---

  4. #### Define the struct by calling the `main_validator` for full access on the output

  ##### Options
  * `main_validator` - if set as tuple like this {ModuleName, :function_name},
  for guardedstruct, in fact you have a global validation.

  ```elixir
  # First, it looks at whether a main_validator has been set for each field,
  # otherwise it looks inside the module.
  defmodule MyModule do
    alias MyModule.AnotherModule
    use GuardedStruct

    guardedstruct main_validator: {AnotherModule, :main_validator} do
    field(:name, String.t())
    field(:title, String.t())
    end

    # if `guardedstruct` has no `main_validator` which is configed
    def main_validator(value) do
      {:ok, value}
    end
  end
  ```

  - Output without error: `{:ok, value}`
  - Output with error: `{:error, :generalـreason, errors_list}`

  ---

  5. #### Define struct with `derive`

  > derive is divided into two parts: `validate` and `sanitize`, which is priority with `sanitize`

  **It should be noted that in the following tables you can see that in order to use some derives, you need to add its dependency on your project.**


  #### Sanitize

  | How to use | Dependencies | Description |
  | ---------- | ------------ | ----------- |
  | `"sanitize(trim)"` | NO | Trim your string |
  | `"sanitize(upcase)"` | NO | Upcase your string |
  | `"sanitize(downcase)"` | NO | Downcase your string |
  | `"sanitize(capitalize)"` | NO | Capitalize your string |
  | `"sanitize(basic_html)"` | `:html_sanitize_ex` | Sanitize your string base on `basic_html` |
  | `"sanitize(html5)"` | `:html_sanitize_ex` | Sanitize your string base on `html5` |
  | `"sanitize(markdown_html)"` | `:html_sanitize_ex` | Sanitize your string base on `markdown_html` |
  | `"sanitize(strip_tags)"` | `:html_sanitize_ex` | Sanitize your string base on `strip_tags` |
  | `"sanitize(tag)"` | `:html_sanitize_ex` | Sanitize your string base on `html_sanitize_ex` selection |

  #### Validate

  | How to use | Dependencies | Description |
  | ---------- | ------------ | ----------- |
  | `"validate(string)"` | NO | Validate if the data is string|
  | `"validate(integer)"` | NO | Validate if the data is integer|
  | `"validate(list)"` | NO | Validate if the data is list|
  | `"validate(atom)"` | NO | Validate if the data is atom|
  | `"validate(bitstring)"` | NO | Validate if the data is bitstring|
  | `"validate(boolean)"` | NO | Validate if the data is boolean|
  | `"validate(exception)"` | NO | Validate if the data is exception|
  | `"validate(float)"` | NO | Validate if the data is float|
  | `"validate(function)"` | NO | Validate if the data is function|
  | `"validate(map)"` | NO | Validate if the data is map|
  | `"validate(nil_value)"` | NO | Validate if the data is nil value|
  | `"validate(not_nil_value)"` | NO | Validate if the data is not nil value|
  | `"validate(number)"` | NO | Validate if the data is number|
  | `"validate(pid)"` | NO | Validate if the data is Elixir pid|
  | `"validate(port)"` | NO | Validate if the data is Elixir port|
  | `"validate(reference)"` | NO | Validate if the data is Elixir reference|
  | `"validate(struct)"` | NO | Validate if the data is struct|
  | `"validate(tuple)"` | NO | Validate if the data is tuple|
  | `"validate(not_empty)"` | NO | Validate if the data is not empty - binary, map, list|
  | `"validate(max_len=10)"` | NO | Validate if the data is more than 10 - Range, integer, binary|
  | `"validate(min_len=10)"` | NO | Validate if the data is less than 10 - Range, integer, binary|
  | `"validate(url)"` | NO | Validate if the data is url|
  | `"validate(geo_url)"` | `ex_url` | Validate if the data is geo url|
  | `"validate(tell)"` | `ex_url` | Validate if the data is tell|
  | `"validate(tell=98)"` | `ex_url` | Validate if the data is tell with country code|
  | `"validate(email)"` | `email_checker` | Validate if the data is email|
  | `"validate(location)"` | `ex_url` | Validate if the data is location|
  | `"validate(string_boolean)"` | NO | Validate if the data is string boolean|
  | `"validate(datetime)"` | NO | Validate if the data is datetime|
  | `"validate(range)"` | NO | Validate if the data is datetime|
  | `"validate(date)"` | NO | Validate if the data is datetime|
  | `"validate(regex='^[a-zA-Z]+@mishka\.group$')"` | NO | Validate if the data is match with regex|
  | `"validate(ipv4)"` | NO | Validate if the data is ipv4|
  | `"validate(not_empty_string)"` | NO | Validate if the data is not empty string|
  | `"validate(uuid)"` | NO | Validate if the data is uuid|
  | `"validate(enum=String[admin::user::banned])"` | NO | Validate if the data is one of the enum value, which is String|
  | `"validate(enum=Atom[admin::user::banned])"` | NO | Validate if the data is one of the enum value, which is Atom|
  | `"validate(enum=Integer[1::2::3])"` | NO | Validate if the data is one of the enum value, which is Integer|
  | `"validate(enum=Float[1.5::2.0::4.5])"` | NO | Validate if the data is one of the enum value, which is Float|
  | `"validate(enum=Map[%{status: 1}::%{status: 2}::%{status: 3}])"` | NO | Validate if the data is one of the enum value, which is Map|
  | `"validate(enum=Tuple[{:admin, 1}::{:user, 2}::{:banned, 3}])"` | NO | Validate if the data is one of the enum value, which is Tuple|

  ```elixir
  defmodule MyModule do
    use GuardedStruct

    guardedstruct do
      field(:id, integer(), derive: "sanitize(trim) validate(integer, max_len=20, min_len=5)")
      field(:title, String.t(), derive: "sanitize(trim, upcase) validate(not_empty_string)")
      field(:name, String.t(), derive: "sanitize(trim, capitalize) validate(string, not_empty, max_len=20)")
    end
  end
  ```

  ---

  6. #### Extending `derive` section

  ##### Options
  * `validate_derive` - It can be just one module or a list of modules
  * `sanitize_derive` - It can be just one module or a list of modules

  ```elixir
  defmodule TestValidate do
    def validate(:testv1, input, field) do
      if is_binary(input),
        do: input,
        else: {:error, field, :testv1, "The name field must not be empty"}
    end
  end

  defmodule TestValidate2 do
    def validate(:testv2, input, field) do
      if is_binary(input),
        do: input,
        else: {:error, field, :testv1, "The name field must not be empty"}
    end
  end

  defmodule TestSanitize do
    def sanitize(:capitalize_v1, input) do
      if is_binary(input), do: String.capitalize(input), else: input
    end
  end

  defmodule TestSanitize2 do
    def sanitize(:capitalize_v2, input) do
      if is_binary(input), do: String.capitalize(input), else: input
    end
  end

  defmodule MyModule do
    use GuardedStruct

    guardedstruct validate_derive: TestValidate, sanitize_derive: TestSanitize do
      field(:id, integer(), derive: "sanitize(trim) validate(not_exist)")
      field(:title, String.t(), derive: "sanitize(trim) validate(string)")
      field(:name, String.t(), derive: "sanitize(capitalize_v2) validate(string)")
    end
  end

  # OR you can extend with list of modules

  defmodule MyModule do
    use GuardedStruct

    guardedstruct validate_derive: [TestValidate, TestValidate2], sanitize_derive: [TestSanitize, TestSanitize2] do
      field(:id, integer(), derive: "validate(ineteger)")
      field(:title, String.t(), derive: "sanitize(trim) validate(string)")
      field(:name, String.t(), derive: "sanitize(capitalize_v2) validate(string)")
    end
  end
  ```
  ---

  7. #### Struct definition with `validator` and `derive` simultaneously

  ```elixir
  # In this code, name field has not custom validator module and function
  # Then it see the caller module for it
  defmodule MyModule do
    use GuardedStruct

    guardedstruct do
      field(:name, String.t(),
        enforce: true,
        derive: "sanitize(trim, upcase) validate(not_empty)"
      )

      field(:title, String.t(), derive: "sanitize(trim, capitalize) validate(not_empty)")
    end

    def validator(:name, value) do
      if is_binary(value), do: {:ok, :name, "Mishka   "}, else: {:error, :name, "No, never"}
    end

    def validator(name, value) do
      {:ok, name, value}
    end
  end

  # OR with custom validator

  defmodule MyModule do
    alias MyModule.AnotherModule
    use GuardedStruct

    guardedstruct do
      field(:name, String.t(), enforce: true, derive: "sanitize(trim, capitalize) validate(not_empty)" validator: {AnotherModule, :validator})
      field(:title, String.t(), derive: "sanitize(trim, capitalize) validate(not_empty)")
    end

    # You can not use it, but it is mentioned here for test clarity
    def validator(name, value) do
      {:ok, name, value}
    end
  end
  ```
  ---

  8. #### Define a nested and complex struct

  ```elixir
  defmodule TestNestedStruct do
    use GuardedStruct

    guardedstruct do
      field(:name, String.t(),
        derive:
          "sanitize(strip_tags, trim, capitalize) validate(string, not_empty, max_len=20, min_len=3)"
      )

      field(:family, String.t(),
        derive:
          "sanitize(basic_html, trim, capitalize) validate(string, not_empty, max_len=20, min_len=3)"
      )

      field(:age, integer(), enforce: true, derive: "validate(integer, max_len=110, min_len=18)")

      sub_field(:auth, struct(), enforce: true) do
        field(:server, String.t(), derive: "validate(regex='^[a-zA-Z]+@mishka\.group$')")

        field(:identity_provider, String.t(),
          derive: "sanitize(strip_tags, trim, lowercase) validate(not_empty)"
        )

        sub_field(:role, struct(), enforce: true) do
          field(:name, String.t(),
            derive:
              "sanitize(strip_tags, trim, lowercase) validate(enum=Atom[admin::user::banned])"
          )

          field(:action, String.t(), derive: "validate(string_boolean)")

          field(:status, String.t(),
            derive: "validate(enum=Map[%{status: 1}::%{status: 2}::%{status: 3}])"
          )
        end

        field(:last_activity, String.t(), derive: "sanitize(strip_tags, trim) validate(datetime)")
      end

      sub_field(:profile, struct()) do
        field(:site, String.t(), derive: "validate(url)")

        field(:nickname, String.t(), validator: {TestNestedStruct, :validator})
      end

      field(:username, String.t(),
        enforce: true,
        derive: "sanitize(tag=strip_tags) validate(not_empty, max_len=20, min_len=3)"
      )
    end

    def validator(:nickname, value) do
      if is_binary(value),
        do: {:ok, :nickname, value},
        else: {:error, :nickname, "Invalid nickname"}
    end

    def validator(field, value) do
      {:ok, field, value}
    end
  end
  ```

  9. #### Error and data output sample

  ```elixir
  # Error
  {:error, :bad_parameters,
    [
      %{
        field: :profile,
        errors: {:bad_parameters, [%{message: "Invalid nickname", field: :nickname}]}
      },
      %{
        field: :auth,
        errors:
          {:bad_parameters,
          [
            %{message: _msg, field: :last_activity, action: :datetime},
            %{
              field: :role,
              errors:
                {:bad_parameters,
                  [
                    %{message: _msg1, field: :action, action: :string_boolean}
                  ]}
            }
          ]}
      }
    ]}

  # Data

  {:ok,
    %MishkaDeveloperToolsTest.GuardedStructTest.TestNestedStruct{
      username: "mishka",
      profile: %MishkaDeveloperToolsTest.GuardedStructTest.TestNestedStruct.Profile{
        nickname: "mishka",
        site: "https://elixir-lang.org"
      },
      auth: %MishkaDeveloperToolsTest.GuardedStructTest.TestNestedStruct.Auth{
        last_activity: "2023-08-20 16:54:07.841434Z",
        role: %MishkaDeveloperToolsTest.GuardedStructTest.TestNestedStruct.Auth.Role{
          action: "true",
          name: :user,
          status: %{status: 2}
        },
        identity_provider: "google",
        server: "users@mishka.group"
      },
      age: 18,
      family: "Group",
      name: "Mishka"
    }}
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

    converted_name = create_module_name(name, __CALLER__)

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

      def enforce_keys(:all) do
        GuardedStruct.show_nested_keys(unquote(module), :enforce_keys)
      end

      def enforce_keys(key) do
        Enum.member?(unquote(gs_enforce_keys), key)
      end

      def keys() do
        unquote(gs_fields)
      end

      def keys(:all) do
        GuardedStruct.show_nested_keys(unquote(module))
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

  def create_module_name(name, module_name, type \\ :macro) do
    name
    |> Atom.to_string()
    |> Macro.camelize()
    |> String.to_atom()
    |> then(&Module.concat(if(type == :macro, do: module_name.module, else: module_name), &1))
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

  @doc false
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
