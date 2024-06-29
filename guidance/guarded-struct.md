# GuardedStruct

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

[![Run in Livebook](https://livebook.dev/badge/v1/pink.svg)](https://livebook.dev/run?url=https%3A%2F%2Fgithub.com%2Fmishka-group%2Fmishka_developer_tools%2Fblob%2Fmaster%2Fguidance%2Fguarded-struct.livemd)

## Copyright

The code in this module is based on the `typed_struct` library (https://github.com/ejpcmac/typed_struct),
which is licensed under the MIT License.

Modifications and additions have been made to enhance its capabilities as part of the current project.

**MIT License**

Adding new Copyright (c) [2023] [Shahryar Tavakkoli at [Mishka Group](https://github.com/mishka-group)]

**Note:** If the license changes during the support of this project, this file will always remain on MIT

---

## Table of Contents

* [Defines a guarded struct](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#defines-a-guarded-struct)
* [Defining a struct layer without additional options](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#defining-a-struct-layer-without-additional-options)
* [Define a struct with settings related to essential keys or `opaque` type](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#define-a-struct-with-settings-related-to-essential-keys-or-opaque-type)
* [Defining the struct by calling the validation module or calling from the module that contains the struct](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#defining-the-struct-by-calling-the-validation-module-or-calling-from-the-module-that-contains-the-struct)
* [Define the struct by calling the `main_validator` for full access on the output](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#define-the-struct-by-calling-the-main_validator-for-full-access-on-the-output)
* [Define struct with `derive`](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#define-struct-with-derive)
* [Extending `derive` section](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#extending-derive-section)
* [Struct definition with `validator` and `derive` simultaneously](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#struct-definition-with-validator-and-derive-simultaneously)
* [Define a nested and complex struct](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#define-a-nested-and-complex-struct)
* [Error and data output sample](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#error-and-data-output-sample)
* [Set config to show error inside `defexception`](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#error-and-data-output-sample)
* [Error `defexception` modules](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#error-defexception-modules)
* [`authorized_fields` option to limit user input](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#authorized_fields-option-to-limit-user-input)
* [List of structs](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#list-of-structs)
* [Struct information function](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#struct-information-function)
* [Transmitting whole output of builder function to its children](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#transmitting-whole-output-of-builder-function-to-its-children)
* [Auto core key](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#auto-core-key)
* [On core key](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#on-core-key)
* [From core key](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#from-core-key)
* [Domain core key](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#domain-core-key)
* [Domain core key with `equal` and `either` support](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#domain-core-key-with-equal-and-either-support)
* [Domain core key with Custom function support](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#domain-core-key-with-custom-function-support)
* [Conditional fields](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#conditional-fields)
* [List Conditional fields](https://github.com/mishka-group/mishka_developer_tools/blob/master/guidance/guarded-struct.md#list-conditional-fields)


---

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
| `"sanitize(string_float)"` | `:html_sanitize_ex` or NO | Sanitize your string base on `html_sanitize_ex` and `Float.parse/1` |

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
| `"validate(custom=[Enum, all?])"` | NO | Validate if the you custom function returns trueو **Please read section 20**|
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
      else: {:error, field, :testv1, "The #{field} field must not be empty"}
  end
end

defmodule TestValidate2 do
  def validate(:testv2, input, field) do
    if is_binary(input),
      do: input,
      else: {:error, field, :testv1, "The #{field} field must not be empty"}
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

10. #### Set config to show error inside `defexception`

You may want to display the received errors in Elixir's `defexception`. you just need to enable the `error: true` for `guardedstruct` macro or `sub_field`.

**Note**: When you enable the `error` option. This macro will generate for you a module that is part of the parent module subset, and within that module, it will generate a `defexception` struct.

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

If this option is not used, the program will automatically drop fields that are not defined; however, if this option is set, it will return an error to the user if they transmit a field that is not in the list of specified fields. If this option is not used, the program will automatically drop fields that are not defined.

**Please take note** that the `required_fields` and this section are not the same thing, and that the validation of the mandatory fields will take place after this section.

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

12. #### Call external struct/structs module

This option can be helpful for you if you wish to construct your own modules in various files and then make those modules reusable in the future. Simply implement the macro in another module, and then call that module from the `field` macro. The `struct` and `structs` options are the ones in which the module can be placed. The first one will provide you with an indication that you will be given a map, and the second one will provide you with a list of maps.


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
    field(:auth_path1, struct(), structs: TestAuthStruct)
  end
end
```

13. #### List of structs

As was discussed in the earlier available choices. In the `field` macro that is used to call **another module**, as well as in the `sub_field` macro, you have the ability to retrieve a list of structs rather than a single struct.

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

You will need to include a function known as `__information__()` in each and every module that you develop for your very own `structs`. This function will store a variety of information, such as keys, callers, and so on.

**Note:** There is a possibility that further information will be added to this function; please check its output after each update.

**Note:** If you call another Struct module within the `field` macro, you should not use the `caller` key within this function. This is due to the fact that the constructor information is only available during **compile** time, and not run time.

```elixir
TestStruct.__information__()
```

15. #### Transmitting whole output of builder function to its children

Because new keys have been added, such as `auto`, `on`, and `from` which will be explained in more detail below. The `builder` function is available in the following two different styles.

> If you don't provide the `:root` key, you can just specify the child key, but if you do, you have to send the entire map as an `attar`. This is something to keep in mind.


```elixir
def builder(attrs, error)

def builder({key, attrs} = input, error)
    when is_tuple(input) and is_map(attrs) and is_list(key) do
      ...
end
```

16. #### Auto core key

Even if the user transmits the information and it is already in the input, such as with the ID field, the sequence of fields still has to be formed automatically. You can accomplish what you want to with the help of the `auto` option.

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
    MishkaDeveloperTools.Helper.UUID.generate() <> "-#{default}"
  end
end
```

> **Note**: When changing a record in the database, for example, you might need to make sure that a particular piece of data does not get overwritten by an automatic piece of data if one already exists. To find a solution to this issue, you will need to invoke the `builder` function in the following manner.

```elixir
TestModule.builder({:root, %{username: "mishka", user_id: "test_not_to_be_replaced"}, :edit})
```

The desired key can be derived from the information that was supplied by the user, and it is stored in the first entry of the `Tuple`. If it is `:root` or `[:root]`, it indicates that the entire data set is being referred to, and if it is a special key that must be valued as a list, it indicates that the `builder` will begin its operation from that particular key. It is important to notice that the key has to be `sub_field` if the path is chosen to be displayed.


17. #### On core key

With the aid of this option, you can make the presence of a field dependent on the presence of another field and, if there is no error, produce an error message.

If you pay attention to the routing method, the routing will start from the sent map itself if `:root` is specified, but if it is not used, the routing will start from the received map in the child if it is not used.

> When the core keys are called, the entire primary map is sent to each child.

##### Note:

> By default, `on` core key is called when the value of the calling field is sent; To force the field to be non-empty, you must use enforce.


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

You can select this alternative if you require any data that was delivered in another key to be incorporated into the key that you are looking for. If the key is present, the data associated with it will be copied; however, if the key is not there, the data in and of itself will be retained.

If you pay attention to the routing method, the routing will start from the sent map itself if `:root` is specified, but if it is not used, the routing will start from the received map in the child if it is not used.

---

> When the core keys are called, the entire primary map is sent to each child.

> Note: It is possible that you will need to check that the field you wish to duplicate exists, and in order to do so, you can use either the `on` key or the `enforce` option.

> Note: You can use this feature from inside the `conditional_field` list to outside the data, but you cannot point to the inside of the list from outside the list.

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
    MishkaDeveloperTools.Helper.UUID.generate() <> "-#{default}"
  end
end
```

19. #### Domain core key

When dealing with a structure that is heavily nested, it is occasionally necessary to establish the permitted range of values for a set of parameters based on the input provided by a parent.
Note that similar to earlier parts, we do not transfer the entirety of either the `Struct` or the `Map` to this feature in this particular section. Always keep in mind the top-down structure, often known as the parent-to-child relationship.

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

**Note**: Within this section of the core keys, we are making use of the `:enum` Derive. You are free to make advantage of any and all of the amenities that this Derive provides.


---

**Note:**:

It is important to think about the fact that the `domain` core key does not consider any update of  the `auto` core key and instead examines the data that was initially entered in the `builder`.
The information that was entered is not altered in any way by this function; it is merely validating it.

---

19. #### Domain core key with `equal` and `either` support

This component supplies all of the facilities that are necessary to be able to utilize the two keys labeled `equal` and `either`, but because of a little interference, its style is different from the original style of each of these keys, and you are required to adhere to these guidelines. Play can be found in this section.

##### Example for `equal`

```elixir
"?auth.equal=Equal[Atom>>name]"
```

##### Example for `either`

```elixir
domain: "?auth.either=Either[string, enum>>Integer[1>>2>>3]]"
```

**Note**: As you can see, the `>>` indicator has been utilized in this area, despite the fact that it was not included in the first version of these validations.

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
      domain: "!auth.action=Custom[#{@module_path}, is_stuff?]",
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
    field(:status, String.t(), derive: "validate(custom=[#{__MODULE__}, is_stuff?])")
  end

  def is_stuff?(data) when data == "ok", do: true
  def is_stuff?(_data), do: false
end
```

**Note**: You can see when you use it inside a derive, the GuardedStruct calculates the you module `alias`.

21. #### Conditional fields

One of the unique capabilities of this macro is the ability to define conditions and differentiate between the various kinds of `fields`. Assume that you want the `social` field to be able to take both a value `string` and a `map` where `address` and `provider` are included in the `map`.
It is important to notice that the `conditional_field` contained within this macro have the capability of supporting `sub_field`. You can look at some illustrations down below.

Note: Please read this if you want to document any conditional fields for your API. For instance, your front team ought to be aware of which area of the output is for. You have the option of adding the `hint` keyword in accordance with the aforementioned code. And the clue is in your practice here.

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

The `conditional_fields` is one of the most important aspects of this macro, which is available to the programmer in all of its many variants. Typically, you have the ability to send a map through the `builder`. If the map is compliant with one of the requirements, your output will be returned. Additionally, you have the ability to transmit the value of one of the keys related to the map in the form of a list.
Now, with this option, you are able to transmit the complete entry as a list. In addition, you are able to send one of the items on this list as another list, and nesting functionality has been made available to you.

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
