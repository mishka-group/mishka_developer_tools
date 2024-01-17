defmodule GuardedStruct do
  @moduledoc """
  The creation of this macro will allow you to build `Structs` that provide you with a number of
  important options, including the following:

  1. Validation
  2. Sanitizing
  3. Constructor
  4. It provides the capacity to operate in a nested style simultaneously.

  Suppose you are going to collect a number of pieces of information from the user,
  and before doing anything else, you are going to sanitize them.
  After that, you are going to validate each piece of data, and if there are no issues,
  you will either display it in a proper output or save it somewhere else.
  All of the characteristics that are associated with this macro revolve around cleaning and validating the data.

  The features that we list below are individually based on a particular strategy
  and requirement, but thankfully, they may be combined and mixed in any way that you see fit.

  It bestows to you a significant amount of authority in this sphere.
  After the initial version of this macro was obtained from the source of the `typed_struct` library,
  many sections of it were rewritten, or new concepts were taken from libraries in Rust and Scala
  and added to this library in the form of Elixir base.

  The initial version of this macro can be found in the `typed_struct` library. Its base is a
  syntax that is very easy to comprehend, especially for non-technical product managers, and highly straightforward.

  Before explaining the copyright, I must point out that the primary library, which is `typed_struct`,
  is no longer supported for a long time, so please pay attention to the following copyright.

  ## Copyright

  The code in this module is based on the `typed_struct` library (https://github.com/ejpcmac/typed_struct),
  which is licensed under the MIT License.

  Modifications and additions have been made to enhance its capabilities as part of the current project.

  **MIT License**

  Adding new Copyright (c) [2023] [Shahryar Tavakkoli at [Mishka Group](https://github.com/mishka-group)]

  **Note:** If the license changes during the support of this project, this file will always remain on MIT

  """

  ####################################################################
  ################ (▰˘◡˘▰) initializing (▰˘◡˘▰) ################
  ####################################################################

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

  @doc """
  ### Defines a guarded struct

  The beginning of the block consists of the introduction of a `Struct` with the `guardedstruct` macro,
  which is solely responsible for recording a series of information in order to create a struct, as well
  as all of the fields with the `field` macro, and if you need to create another struct within this struct
  (in actuality, a module child within another module), you must use the `sub_field` macro.

  **Note:** there is no restriction on the number of times you can call the `sub_field` macro or the
  field macro within the context of the `sub_field` macro.

  **Note:** Because `Stract` does not prioritize the display of keys depending on your requirements,
  you do not need to follow the priority of the fields and call them in order to utilize the app.
  Implement the program's logic, regardless of what it might be.

  **Note:** Because of different limitations, if you want to write a test, you must first
  place the module in which you built the struct outside of the test macro. Once the struct
  has been built, you may then test it by calling it within the test macro itself.
  The examples it provides can also be found in the testing done by this library itself.

  **Note:** this library is only supported on versions of `Elixir 1.15` and higher, as well as `OTP 26`, 
  and that the manufacturer does not offer bug patches for problems that occur in older software versions.

  **Note:** All of this library's dependencies are optional; nonetheless,
  if you require their use in your program, you will need to include them. We provide further
  explanation on the topic in the area you're looking for.

  > Before continuing with the discussion about the library section and also offering practical
  examples in this field, it is important to understand that when you construct a struct in a module,
  after compilation in the runtime of the program, each module includes the following functional functions:

  1. The `builder()` function is actually an action function, and it requires you to provide it with
  information in the form of a `map`.

  2. The `enforce_keys()` function: this method returns the necessary keys of the first layer of the
  struct. However, if you want to display all of the keys of the nested struct,
  you will need to enter the `:all` input, which is not yet implemented in this version.

  3. The `keys()` function has the same requirements as the `enforce_keys()`
  function, with the exception that it returns all of the keys, including the ones that aren't necessary.

  ---

  **And also, any data that enters the `builder` function must go through the following path:**

  1. If the `map` currently uses the `string` data type, it will be converted to the `atom` data type.

  2. Eliminates the keys from the `struct` that are not present in the list

  3. Determines whether or not all of the essential keys have been transmitted.

  4. If you write your own custom validation, each field's validations will be checked.

  > It is important to notice that regardless of the circumstances, this macro also inspects the module itself.
  If there is a `validator` function but none of the functions are set,
  it calls the validator function directly from the module itself into the field itself.

  5. The output of the complete `struct` is entered into the mother validation,
  and the programmer is given the opportunity to write for the final output in this validation.
  This validation also provides the possibility of writing for the output of the struct.

  > This macro will call the struct's `main_validator` directly from the module
  it has been placed in if, in this section, the `main_validator`  is not set in the
  struct but is found in the module that contains the struct.

  6. If there were no problems in the previous phases (it is important to note that options 4 and 5 are not required),
  it will proceed to the next level of the program, which is the validation and custom Sanitizer stage.

  7. To begin, the Sanitizer will alter the data so that it corresponds to what you have called in each field,
  and it will not return any errors.
  Even if the Sanitizer programmer is not utilized in the required type as a result of an accidental oversight,
  the data will still be passed to the following stage.

  8. At this point, it will return an error or data for each field, depending on the validations that you called.

  9. At the end of the process, you will receive a tuple that will either have problems in it or
  the final data with an ok status.

  > It is important to keep in mind that if your `struct` is nested, all of the internal errors
  of these structs are also included in the list of problems. Additionally,
  the data will be sent to you when the status is positive, but only if you have called the parent of this struct.

  > Note that each nested struct can be used on its own and possesses all of the
  capabilities that have been discussed thus far. For instance, if you have module `A` and
  you utilized the `sub_field` that is named `auth` in it, you may now use it separately from the `A.Auth` Use. Use.

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
  | `"sanitize(string_float)"` | `:html_sanitize_ex` or `none` | Sanitize your string base on `html_sanitize_ex` and `Float.parse/1` |

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
  | `"validate(equal=some_thing)"` | NO | Validate if the data is equal with validation value, which is any type|
  | `"validate(either=[string, enum=Integer[1::2::3]])"` | NO | Validate if the data is valid with each derive validation|
  | `"validate(custom=[Enum, all?])"` | NO | Validate if the you custom function returns true, **Please read section 20**|
  | `"validate(some_string_float)"` | NO | Validate if the string data is float (Somewhat by removing the string)|
  | `"validate(string_float)"` | NO | Validate if the string data is float (Strict mode)|
  | `"validate(string_integer)"` | NO | Validate if the string data is integer (Strict mode)|
  | `"validate(some_string_integer)"` | NO | Validate if the string data is integer (Somewhat by removing the string)|
  | `"validate(not_flatten_empty)"` | NO | Validate the list if it is empty by summing and flattening the entire list|
  | `"validate(not_flatten_empty_item)"` | NO | Validate the list if it is empty by summing and flattening the entire list and first level children|

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
      field(:name, String.t(),
        enforce: true,
        derive: "sanitize(trim, capitalize) validate(not_empty)",
        validator: {AnotherModule, :validator}
      )
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

  10. #### Set config to show error inside `defexception`

  You may want to display the received errors in Elixir's `defexception`. you just need to enable the
  `error: true` for `guardedstruct` macro or `sub_field`.

  **Note**: When you enable the `error` option. This macro will generate for you a module that
  is part of the parent module subset, and within that module, it will generate a `defexception` struct.

  ##### Error `defexception` modules

  ```elixir
  TestCallNestedStructWithError.Error
  TestCallNestedStructWithError.Auth.Error
  TestCallNestedStructWithError.Auth.Path.Error
  ```

  ##### Sample code

  ```elixir
  defmodule TestCallNestedStructWithError do
    use GuardedStruct

    guardedstruct error: true do
      field(:name, String.t(), derive: "validate(string)")

      sub_field(:auth, struct(), error: true) do
        field(:action, String.t(), derive: "validate(not_empty)")

        sub_field(:path, struct(), error: true) do
          field(:name, String.t())
        end
      end
    end
  end

  # And you should call it like this, the second entry should be `true` or `false` to show error `defexception`
  TestCallNestedStructWithError.builder(%{name: 1}, true)
  ```

  11. #### `authorized_fields` option to limit user input

  If this option is not used, the program will automatically drop fields that are not defined;
  however, if this option is set, it will return an error to the user if they transmit a field
  that is not in the list of specified fields. If this option is not used, the program will automatically
  drop fields that are not defined.

  **Please take note** that the `required_fields` and this section are not the same thing,
  and that the validation of the mandatory fields will take place after this section.

  ```elixir
  defmodule TestAuthorizeKeys do
    use GuardedStruct

    guardedstruct authorized_fields: true do
      field(:name, String.t(), derive: "validate(string)")

      sub_field(:auth, struct(), authorized_fields: true) do
        field(:action, String.t(), derive: "validate(not_empty)")

        sub_field(:path, struct()) do
          field(:name, String.t())
        end
      end
    end
  end

  TestAuthorizeKeys.builder(%{name: "Shahryar", test: "test"})
  # Ouput: `{:error, :authorized_fields, [:test]}`

  TestAuthorizeKeys.builder(%{name: "Shahryar", auth: %{action: "admin", test: "test"}})
  # Ouput: `{:error, :bad_parameters, [%{field: :auth, errors: {:authorized_fields, [:test]}}]}`
  ```

  12. #### `authorized_fields` option to limit user input

  This option can be helpful for you if you wish to construct your own modules in various files
  and then make those modules reusable in the future. Simply implement the macro in another module,
  and then call that module from the `field` macro. The `struct` and `structs` options are the
  ones in which the module can be placed. The first one will provide you with an indication that you
  will be given a map, and the second one will provide you with a list of maps.


  ```elixir
  defmodule TestAuthStruct do
    use GuardedStruct

    guardedstruct do
      field(:action, String.t(), derive: "validate(not_empty)")
    end
  end

  defmodule TestOnValueStruct do
    use GuardedStruct

    guardedstruct do
      field(:name, String.t(), derive: "validate(string)")
      field(:auth_path, struct(), struct: TestAuthStruct)
      # field(:auth_path, struct(), structs: TestAuthStruct)
    end
  end
  ```

  13. #### List of structs

  As was discussed in the earlier available choices. In the `field` macro that is used to
  call **another module**, as well as in the `sub_field` macro, you have the ability to retrieve
  a list of structs rather than a single struct.

  ```elixir
  defmodule TestUserAuthStruct do
    use GuardedStruct

    guardedstruct do
      field(:name, String.t(), derive: "validate(not_empty)")
      field(:auth_path, struct(), structs: TestAuthStruct)

      sub_field(:profile, list(struct()), structs: true) do
        field(:github, String.t(), enforce: true, derive: "validate(url)")
        field(:nickname, String.t(), derive: "validate(not_empty)")
      end
    end
  end

  TestUserAuthStruct.builder(%{
           name: "mishka",
           auth_path: [
             %{action: "*:admin", path: %{role: "1"}},
             %{action: "*:user", path: %{role: "3"}}
           ]
         })

  # OR
  TestUserAuthStruct.builder(%{
           name: "mishka",
           auth_path: [
             %{action: "*:admin", path: %{role: "1"}},
             %{action: "*:user", path: %{role: "3", rel: %{social: "github"}}}
           ],
           profile: [%{github: "https://github.com/mishka-group"}]
         })
  ```

  14. #### Struct information function

  You will need to include a function known as `__information__()` in each and every module
  that you develop for your very own `structs`. This function will store a variety of information, such as keys,
  callers, and so on.

  **Note:** There is a possibility that further information will be added to this function; please check its
  output after each update.

  **Note:** If you call another Struct module within the `field` macro, you should not use
  the `caller` key within this function. This is due to the fact that the constructor information
  is only available during **compile** time, and not run time.

  ```elixir
  TestStruct.__information__()
  ```

  15. #### Transmitting whole output of builder function to its children

  Because new keys have been added, such as `auto`, `on`, and `from` which will be explained
  in more detail below. The `builder` function is available in the following two different styles.

  > If you don't provide the `:root` key, you can just specify the child key,
  but if you do, you have to send the entire map as an `attar`. This is something to keep in mind.


  ```elixir
  def builder(attrs, error)

  def builder({key, attrs} = input, error)
      when is_tuple(input) and is_map(attrs) and is_list(key) do
        ...
  end
  ```

  16. #### Auto core key

  Even if the user transmits the information and it is already in the input, such as with the ID field,
  the sequence of fields still has to be formed automatically. You can accomplish what you want to with
  the help of the `auto` option.

  > As you can see in the code below, we have several types of `auto` option calls

  ---

  > When the core keys are called, the entire primary map is sent to each child.

  ```elixir
  defmodule TestAutoValueStruct do
    use GuardedStruct

    guardedstruct do
      field(:username, String.t(), derive: "validate(not_empty)")
      field(:user_id, String.t(), auto: {Ecto.UUID, :generate})
      field(:parent_id, String.t(), auto: {Ecto.UUID, :generate})

      sub_field(:profile, struct()) do
        field(:id, String.t(), auto: {Ecto.UUID, :generate})
        field(:nickname, String.t(), derive: "validate(not_empty)")

        sub_field(:social, struct()) do
          field(:id, String.t(), auto: {TestAutoValueStruct, :create_uuid, "test-path"})
          field(:skype, String.t(), derive: "validate(string)")
          field(:username, String.t(), from: "root::username")
        end
      end

      sub_field(:items, struct(), structs: true) do
        field(:id, String.t(), auto: {Ecto.UUID, :generate})
        field(:something, String.t(), derive: "validate(string)", from: "root::username")
      end
    end

    def create_uuid(default) do
      Ecto.UUID.generate() <> "-\#{default}\"
    end
  end
  ```

  > **Note**: When changing a record in the database, for example, you might need to make sure that a particular
  > piece of data does not get overwritten by an automatic piece of data if one already exists.
  > To find a solution to this issue, you will need to invoke the `builder` function in the following manner.

  ```elixir
  TestModule.builder({:root, %{username: "mishka", user_id: "test_not_to_be_replaced"}, :edit})
  ```

  The desired key can be derived from the information that was supplied by the user,
  and it is stored in the first entry of the `Tuple`. If it is `:root` or `[:root]`, it indicates that the entire
  data set is being referred to, and if it is a special key that must be valued as a list,
  it indicates that the `builder` will begin its operation from that particular key.
  It is important to notice that the key has to be `sub_field` if the path is chosen to be displayed.

  17. #### On core key

  With the aid of this option, you can make the presence of a field dependent on the presence of another field and,
  if there is no error, produce an error message.

  If you pay attention to the routing method, the routing will start from the sent map itself
  if `:root` is specified, but if it is not used, the routing will start from the received
  map in the child if it is not used.

  > When the core keys are called, the entire primary map is sent to each child.

  ##### Note:

  > By default, `on` core key is called when the value of the calling field is sent;
  > To force the field to be non-empty, you must use enforce.

  ```elixir
  defmodule TestOnValueStruct do
    use GuardedStruct

    guardedstruct do
      field(:name, String.t(), derive: "validate(string)")

      sub_field(:profile, struct()) do
        field(:id, String.t(), auto: {Ecto.UUID, :generate})
        field(:nickname, String.t(), on: "root::name", derive: "validate(string)")
        field(:github, String.t(), derive: "validate(string)")

        sub_field(:identity, struct()) do
          field(:provider, String.t(), on: "root::profile::github", derive: "validate(string)")
          field(:id, String.t(), auto: {Ecto.UUID, :generate})
          field(:rel, String.t(), on: "sub_identity::auth_path::action")

          sub_field(:sub_identity, struct()) do
            field(:id, String.t(), auto: {Ecto.UUID, :generate})
            field(:auth_path, struct(), struct: TestAuthStruct)
          end
        end
      end

      sub_field(:last_activity, list(struct()), structs: true) do
        field(:action, String.t(), enforce: true, derive: "validate(string)", on: "root::name")
      end
    end
  end
  ```
  18. #### From core key

  You can select this alternative if you require any data that was delivered in another key
  to be incorporated into the key that you are looking for. If the key is present, the data
  associated with it will be copied; however, if the key is not there, the data in and of itself will be retained.

  If you pay attention to the routing method, the routing will start from the sent map itself
  if `:root` is specified, but if it is not used, the routing will start from the received map
  in the child if it is not used.

  ---

  > When the core keys are called, the entire primary map is sent to each child.

  > Note: It is possible that you will need to check that the field you wish to duplicate exists,
  and in order to do so, you can use either the `on` key or the `enforce` option.

  ```elixir
  defmodule TestAutoValueStruct do
    use GuardedStruct

    guardedstruct do
      field(:username, String.t(), derive: "validate(not_empty)")
      field(:user_id, String.t(), auto: {Ecto.UUID, :generate})
      field(:parent_id, String.t(), auto: {Ecto.UUID, :generate})

      sub_field(:profile, struct()) do
        field(:id, String.t(), auto: {Ecto.UUID, :generate})
        field(:nickname, String.t(), derive: "validate(not_empty)")

        sub_field(:social, struct()) do
          field(:id, String.t(), auto: {TestAutoValueStruct, :create_uuid, "test-path"})
          field(:skype, String.t(), derive: "validate(string)")
          field(:username, String.t(), from: "root::username")
        end
      end

      sub_field(:items, struct(), structs: true) do
        field(:id, String.t(), auto: {Ecto.UUID, :generate})
        field(:something, String.t(), derive: "validate(string)", from: "root::username")
      end
    end

    def create_uuid(default) do
      Ecto.UUID.generate() <> "-\#{default}\"
    end
  end
  ```

  19. #### Domain core key

  When dealing with a structure that is heavily nested, it is occasionally necessary
  to establish the permitted range of values for a set of parameters based on the
  input provided by a parent.
  Note that similar to earlier parts, we do not transfer the entirety of either
  the `Struct` or the `Map` to this feature in this particular section.
  Always keep in mind the top-down structure, often known as the parent-to-child relationship.

  ```elixir
  defmodule AllowedParentDomain do
    use GuardedStruct

    guardedstruct authorized_fields: true do
      field(:username, String.t(),
        domain: "!auth.action=String[admin, user]::?auth.social=Atom[banned]",
        derive: "validate(string)"
      )

      field(:type_social, String.t(),
        domain: "?auth.type=Map[%{name: \"mishka\"}, %{name: \"mishka2\"}]",
        derive: "validate(string)"
      )

      sub_field(:auth, struct(), authorized_fields: true) do
        field(:action, String.t(), derive: "validate(not_empty)")
        field(:social, atom(), derive: "validate(atom)")
        field(:type, map(), derive: "validate(map)")
      end
    end
  end
  ```

  **Please see the `domain` core key, for example:**

  ```elixir
  domain: "!auth.action=String[admin, user]::?auth.social=Atom[banned]"
  ```

  **In this part:**
  - If `username` key is sent you must have `auth.action` path which is string `admin` or string `user`
  - If `username` key is sent you you can have `auth.social` path which is just atom `:banned`
  - So the `auth.social` can be nil and inside user input impossible nil

  **Note**: Within this section of the core keys, we are making use of the `:enum` Derive.
  You are free to make advantage of any and all of the amenities that this Derive provides.

  ---

  **Note:**:

  It is important to think about the fact that the `domain` core key does not
  consider any update of  the `auto` core key and instead examines the data that was initially entered in the `builder`.
  The information that was entered is not altered in any way by this function; it is merely validating it.

  ---

  19. #### Domain core key with `equal` and `either` support

  This component supplies all of the facilities that are necessary to be able to utilize the
  two keys labeled `equal` and `either`, but because of a little interference, its style is
  different from the original style of each of these keys, and you are required to adhere to
  these guidelines. Play can be found in this section.

  ##### Example for `equal`

  ```elixir
  "?auth.equal=Equal[Atom>>name]"
  ```

  ##### Example for `either`

  ```elixir
  domain: "?auth.either=Either[string, enum>>Integer[1>>2>>3]]"
  ```

  **Note**: As you can see, the `>>` indicator has been utilized in this area,
  despite the fact that it was not included in the first version of these validations.

  20. #### Domain core key with Custom function support

  Imagine that you have a function that determines for you whether or not the data that has been sent is valid.

  **Note**: the function is required to have an input.
  **Note**: the function must return either true or false.
  **Note**: When writing code for the module, do not utilize aliases; instead, write the module's complete path.

  ```elixir
  defmodule AllowedParentCustomDomain do
    use GuardedStruct
    @module_path "MishkaDeveloperToolsTest.GuardedStructTest.AllowedParentCustomDomain"

    guardedstruct authorized_fields: true do
      field(:username, String.t(),
        domain: "!auth.action=Custom[\#{@module_path\}, is_stuff?]",
        derive: "validate(string)"
      )

      sub_field(:auth, struct(), authorized_fields: true) do
        field(:action, String.t(), derive: "validate(not_empty)")
      end
    end

    def is_stuff?(data) when data == "ok", do: true
    def is_stuff?(_data), do: false
  end
  ```

  **Note**: if you want to use `custom` inside `derive` validation, you should do like this:

  ```elixir
  defmodule TestCustomValidationDerive do
    use GuardedStruct

    guardedstruct authorized_fields: true do
      field(:status, String.t(), derive: "validate(custom=[\#{__MODULE__}, is_stuff?])")
    end

    def is_stuff?(data) when data == "ok", do: true
    def is_stuff?(_data), do: false
  end
  ```

  **Note**: You can see when you use it inside a derive, the GuardedStruct calculates the you module `alias`.

  21. #### Conditional fields

  One of the unique capabilities of this macro is the ability to define conditions
  and differentiate between the various kinds of `fields`. Assume that you want the `social`
  field to be able to take both a value `string` and a `map` where `address` and `provider`
  are included in the `map`.
  It is important to notice that the `conditional_field` contained within this macro have
  the capability of supporting `sub_field`. You can look at some illustrations down below.

  Note: Please read this if you want to document any conditional fields for your API.
  For instance, your front team ought to be aware of which area of the output is for.
  You have the option of adding the `hint` keyword in accordance with the aforementioned code.
  And the clue is in your practice here.

  **Output of hint**: `__hint__`

  ```elixir
  defmodule ConditionalFieldComplexTest do
    use GuardedStruct
    alias ConditionalFieldValidatorTestValidators, as: VAL

    guardedstruct do
      field(:provider, String.t())

      sub_field(:profile, struct()) do
        field(:name, String.t(), enforce: true)
        field(:family, String.t(), enforce: true)

        conditional_field(:address, any()) do
          field(:address, String.t(), hint: "address1", validator: {VAL, :is_string_data})

          sub_field(:address, struct(), hint: "address2", validator: {VAL, :is_map_data}) do
            field(:location, String.t(), enforce: true)
            field(:text_location, String.t(), enforce: true)
          end

          sub_field(:address, struct(), hint: "address3", validator: {VAL, :is_map_data}) do
            field(:location, String.t(), enforce: true, derive: "validate(string, location)")
            field(:text_location, String.t(), enforce: true)
            field(:email, String.t(), enforce: true)
          end
        end
      end

      conditional_field(:product, any()) do
        field(:product, String.t(), hint: "product1", validator: {VAL, :is_string_data})

        sub_field(:product, struct(), hint: "product2", validator: {VAL, :is_map_data}) do
          field(:name, String.t(), enforce: true)
          field(:price, integer(), enforce: true)

          sub_field(:information, struct()) do
            field(:creator, String.t(), enforce: true)
            field(:company, String.t(), enforce: true)

            conditional_field(:inventory, integer() | struct(), enforce: true) do
              field(:inventory, integer(),
                hint: "inventory1",
                validator: {VAL, :is_int_data},
                derive: "validate(integer, max_len=33)"
              )

              sub_field(:inventory, struct(), hint: "inventory2", validator: {VAL, :is_map_data}) do
                field(:count, integer(), enforce: true)
                field(:expiration, integer(), enforce: true)
              end
            end
          end
        end
      end
    end
  end
  ```

  Call the builder

  ```elixir
  ConditionalFieldComplexTest.builder(%{
    provider: "Mishka",
    profile: %{
      name: "Shahryar",
      family: "Tavakkoli",
      address: %{
        location: "geo:48.198634,-16.371648,3.4;crs=wgs84;u=40.0",
        text_location: "Nowhere",
        email: "shahryar@mishka.group"
      }
    },
    product: %{
      name: "MishkaDeveloperTools",
      price: 0,
      information: %{
        creator: "Shahryar Tavakkoli",
        company: "mishka group",
        inventory: %{
          count: 3_000_000,
          expiration: 33
        }
      }
    }
  })
  ```

  22. #### List Conditional fields

  The `conditional_fields` is one of the most important aspects of this macro, which is available
  to the programmer in all of its many variants. Typically, you have the ability to send a map
  through the `builder`. If the map is compliant with one of the requirements, your output will be returned.
  Additionally, you have the ability to transmit the value of one of the keys related to the map in the form of a list.
  Now, with this option, you are able to transmit the complete entry as a list.
  In addition, you are able to send one of the items on this list as another list,
  and nesting functionality has been made available to you.

  ```elixir
  conditional_field(:activities, any(), structs: true) do
    field(:activities, struct(), struct: ExtrenalConditional, validator: {VAL, :is_map_data}, hint: "activities1")

    field(:activities, struct(), structs: ExtrenalConditional, validator: {VAL, :is_list_data}, hint: "activities2")

    field(:activities, String.t(), hint: "activities3", validator: {VAL, :is_string_data})
  end
  ```
  As you can see in the code above, you only need to give the macro the `structs: true` option

  ##### Note:

  > Using a list `conditional_field` in a nested list can create a logical bug for you if the list is not flattened, **Please test your builder before releasing to production**.
  """
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
  ################### (▰˘◡˘▰) Macros (▰˘◡˘▰) ###################
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
    # type = Macro.escape(quote do: struct())
    type = Macro.escape(type)
    Parser.parser(block, :conditional)

    quote do
      GuardedStruct.__field__(unquote(name), unquote(type), unquote(opts), __ENV__, true, true)
      unquote(block)
    end
  end

  ####################################################################
  ############## (▰˘◡˘▰) Action Functions (▰˘◡˘▰) ##############
  ####################################################################

  #              +-------------------+
  #              |                   |
  #              |   GuardedStruct   |
  #              |                   |
  #              +---------+---------+
  #                        |
  #                +-------v--------+
  #                |                |
  #                |    __type__    |
  #                |                |
  #                +-------+--------+
  #                        |
  #   +--------------+     |      +-----------------+
  #   |              |     |      |                 |
  #   |     field    +-----+------+    sub_field    +----+
  #   |              |     |      |                 |    |
  #   +--------------+     |      +-----------------+    |
  #                        |                             |
  #                        |                             |
  #              +---------v-----------+     +--------+  |  +-------------+
  #              |         |           |     |        |  |  |             |
  #              | convert_to_atom_map <---+ |  field +--+--+  sub_field  |
  #              |         |           |   | |        |  |  |             |
  #              +---------+-----------+   | +--------+  |  +-------------+
  #                        |               |             |
  #              +---------v------------+  |             |
  #            +-+  before_revaluation  |  |             |
  #            | +----------------------+  |             |
  #            |                           +-------------+
  #            |
  # +----------v-----------+ +----------------+                 +-------------+
  # |          |           | |                |                 |             |
  # |  +-------v---------+ | |   +------------v-------------+   |     +-------v-------+
  # |  |  auto_core_key  | | |   |                          |   |     | Derive.derive |
  # |  +-------+---------+ | |   |  +-------------------+   |   |     +-------+-------+
  # |          |           | |   |  | authorized_fields |   |   |             |
  # |  +-------v---------+ | |   |  +---------+---------+   |   |   +---------v-----------+
  # |  | domain_core_key | | |   |            |             |   |   |  exceptions_handler |
  # |  +-------+---------+ | |   |   +--------v--------+    |   |   +---------------------+
  # |          |           | |   |   | required_fields |    |   |
  # |  +-------v--------+  | |   |   +--------+--------+    |   |
  # |  |  on_core_key   |  | |   |            |             |   |
  # |  +-------+--------+  | |   | +----------v-----------+ |   |
  # |          |           | |   | | sub_fields_validating| |   |
  # |  +-------v--------+  | |   | +----------+-----------+ |   |
  # |  | from_core_key  |  | |   |            |             |   |
  # |  +----------------+  | |   |   +--------v---------+   |   |
  # |                      | |   |   |fields_validating |   |   |
  # |                      | |   |   +--------+---------+   |   |
  # +---------+------------+ |   |            |             |   |
  #           |              |   |   +--------v---------+   |   |
  #           |              |   |   | main_validating  |   |   |
  #           +--------------+   |   +------------------+   |   |
  #                              |                          |   |
  #                              +-----------+--------------+   |
  #                                          |                  |
  #                                          +------------------+

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
      do: config(:conditional, opts, mod, name, Keyword.get(gs_conditional, name), sub_field)
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
        err = %{
          message: "Please submit required fields.",
          fields: missing_keys,
          action: :required_fields
        }

        {:error, :required_fields, [err], :halt}
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
          nil | %{:fields => list(), optional(any()) => any()},
          boolean()
        ) :: :ok
  @doc false
  def config(:conditional, opts, mod, name, nil, _sub?) do
    Module.put_attribute(
      mod,
      :gs_conditional_fields,
      {name,
       %{
         field: name,
         opts: opts,
         fields_count: 0,
         sub_fields_count: 0,
         caller: mod,
         fields: []
       }}
    )
  end

  def config(:conditional, opts, mod, name, gs_conditional, true) do
    %{sub_fields_count: sub_fields_count} = gs_conditional

    module_number =
      String.to_atom("#{name}#{Integer.to_string(gs_conditional.sub_fields_count + 1)}")
      |> create_module_name(mod, :direct)

    list_field? = Keyword.has_key?(opts, :structs)
    field = [%{sub?: true, opts: opts, name: name, module: module_number, list?: list_field?}]

    Module.put_attribute(
      mod,
      :gs_conditional_fields,
      {name,
       Map.merge(gs_conditional, %{
         sub_fields_count: sub_fields_count + 1,
         fields: gs_conditional.fields ++ field
       })}
    )
  end

  def config(:conditional, opts, mod, name, gs_conditional, false) do
    %{fields_count: fields_count} = gs_conditional
    list_field? = Keyword.has_key?(opts, :structs)
    field = [%{sub?: false, opts: opts, name: name, module: nil, list?: list_field?}]

    Module.put_attribute(
      mod,
      :gs_conditional_fields,
      {name,
       Map.merge(gs_conditional, %{
         fields_count: fields_count + 1,
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
      error = %{message: "Your input must be a list of items", field: field, action: :type}
      {:error, :bad_parameters, [error]}
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
              |> Derive.pre_derives_check(opts, field)

            module ->
              if !Code.ensure_loaded?(module) do
                {get_field_validator(opts, cond_data.caller, field, value), opts}
                |> Derive.pre_derives_check(opts, field)
              else
                {opts, cond_data.caller, field, value, type, module}
                |> execute_field_validator(:external)
                |> Derive.pre_derives_check(opts, field)
              end
          end

        %{sub?: false, opts: opts, module: nil, list?: true} ->
          # It is not a sub field, but it should load external module
          # because we have no normal field which is list
          {opts, cond_data.caller, field, value, key, type, full_attrs}
          |> execute_field_validator(:list_external)
          |> Derive.pre_derives_check(opts, field)

        %{sub?: true, opts: opts, module: module, list?: false} ->
          # It is a sub field and just accepts a map not list of map
          {opts, cond_data.caller, field, value, module, key, full_attrs, type}
          |> execute_field_validator(:sub_field)
          |> Derive.pre_derives_check(opts, field)

        %{sub?: true, opts: opts, module: module, list?: true} ->
          # It is a sub field and accepts a list of maps
          {opts, module, field, value, key, type, full_attrs}
          |> execute_field_validator(:list_field)
          |> Derive.pre_derives_check(opts, field)
      end)

    {field, output, Keyword.get(cond_data.opts, :priority, false)}
  end
end
