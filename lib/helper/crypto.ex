defmodule MishkaDeveloperTools.Helper.Crypto do
  @moduledoc """

  """
  @type based32_url :: <<_::64, _::_*8>>

  @simple_hash_algs %{
    "RS256" => %{"type" => :asymmetric, "hash_algorithm" => :sha256, "binary_size" => 16},
    "RS384" => %{"type" => :asymmetric, "hash_algorithm" => :sha384, "binary_size" => 24},
    "RS512" => %{"type" => :asymmetric, "hash_algorithm" => :sha512, "binary_size" => 32},
    "HS256" => %{"type" => :symmetric, "hash_algorithm" => :sha256, "binary_size" => 16},
    "HS384" => %{"type" => :symmetric, "hash_algorithm" => :sha384, "binary_size" => 24},
    "HS512" => %{"type" => :symmetric, "hash_algorithm" => :sha512, "binary_size" => 32}
  }

  @doc """
  Generate a binary composed of random bytes.

  The number of bytes is defined by the `size` argument. Default is `20` per the
  [HOTP RFC](https://tools.ietf.org/html/rfc4226#section-4).

  **based on: https://github.com/dashbitco/nimble_totp/blob/master/lib/nimble_totp.ex**

  ## Examples
  ```elixir
  alias MishkaDeveloperTools.Helper.Crypto

  Crypto.secret()
  #=> <<178, 117, 46, 7, 172, 202, 108, 127, 186, 180, ...>>
  ```
  """
  @spec secret(integer()) :: any()
  def secret(size \\ 20) do
    :crypto.strong_rand_bytes(size)
  end

  if Code.ensure_loaded?(NimbleTOTP) do
    @doc """
      Generates an OTP authentication URL with a given secret, issuer, and label.

    #### Parameters:

    - **secret (binary)**: The secret key used to generate the OTP,
    it should be `:crypto.strong_rand_bytes/1`.
    - **issuer (String)**: The name of the issuer.
    This helps to identify which service the OTP is associated with.
    - **label (String)**: A label used to identify the specific account or user.

    #### Returns:

    It returns a map containing:

    - `:secret` (string) - It should be `:crypto.strong_rand_bytes/1` output which is
    converted to `base32`.
    - `:url` (String) - The complete OTP authentication URL.

    #### Example:
    ```elixir
    secret = :crypto.strong_rand_bytes(20)
    create_otp_link(secret, "Mishka", "user_test")
    ```

    > #### Use cases information {: .info}
    >
    > You are able to generate a QR code from the URL that you have made and then provide
    > it to the user. The majority of devices are able to scan it and utilize it as a
    > two-factor authentication one-time password with ease.

    - **More info: https://dashbit.co/blog/introducing-nimble-totp**
    """
    @spec create_otp_link(binary(), String.t(), String.t()) :: %{
            secret: String.t(),
            url: based32_url()
          }
    def create_otp_link(secret, issuer, label) do
      user_url = NimbleTOTP.otpauth_uri("#{issuer}:#{label}", secret, issuer: issuer)
      base32_secret = URI.decode_query(URI.parse(user_url).query)["secret"]
      %{secret: base32_secret, url: user_url}
    end

    @doc """
    Generates an OTP authentication URL with a given issuer, and label.

    #### Parameters:

    - **issuer (String)**: The name of the issuer.
    This helps to identify which service the OTP is associated with.
    - **label (String)**: A label used to identify the specific account or user.

    #### Returns:

    It returns a map containing:

    - `:secret` (string) - It should be `:crypto.strong_rand_bytes/1` output which is
    converted to `base32`.
    - `:url` (String) - The complete OTP authentication URL.

    #### Example:
    ```elixir
    create_otp_link_and_secret("Mishka", "user_test")
    ```

    > #### Use cases information {: .info}
    >
    > You are able to generate a QR code from the URL that you have made and then provide
    > it to the user. The majority of devices are able to scan it and utilize it as a
    > two-factor authentication one-time password with ease.

    - **More info: https://dashbit.co/blog/introducing-nimble-totp**
    """
    @spec create_otp_link_and_secret(String.t(), String.t()) :: %{
            secret: String.t(),
            url: based32_url()
          }
    def create_otp_link_and_secret(issuer, label) do
      secret = NimbleTOTP.secret()
      user_url = NimbleTOTP.otpauth_uri("#{issuer}:#{label}", secret, issuer: issuer)
      base32_secret = URI.decode_query(URI.parse(user_url).query)["secret"]
      %{secret: base32_secret, url: user_url}
    end

    @doc """
    For information See `create_otp_link/3`
    """
    @spec create_otp(binary(), String.t(), String.t()) :: %{
            secret: String.t(),
            url: based32_url()
          }
    def create_otp(secret, issuer, label), do: create_otp_link(secret, issuer, label)

    @doc """
    For information See `create_otp_link_and_secret/2`
    """
    @spec create_otp(binary(), String.t()) :: %{secret: String.t(), url: <<_::64, _::_*8>>}
    def create_otp(issuer, label), do: create_otp_link_and_secret(issuer, label)

    @doc """
    Checks if a provided OTP is valid for the given secret.

    #### Parameters:

    - **secret (binary)**: The secret key used to generate the OTP,
    it should be `:crypto.strong_rand_bytes/1`.
    - `otp` (String): The OTP to verify, for example `"581234"`.

    #### Example:
    ```elixir
    valid_otp?(secret, "581234")

    # Or, you might put the time when the token was used for the last time to
    # prohibit the user from using it again.

    last_used = System.os_time(:second)
    valid_otp?(secret, "581234", last_used)
    ```

    > #### Use cases information {: .tip}
    >
    > One thing to keep in mind is that you ought to have already kept the
    > secret of each user in a location such as a database.
    """
    @spec valid_otp?(binary(), String.t()) :: boolean()
    def valid_otp?(secret, otp) do
      NimbleTOTP.valid?(secret, otp)
    end

    @doc """
    Checks if a provided OTP is valid for the given secret which is based32.

    #### Parameters:

    - **secret (binary)**: The secret key used to generate the OTP,
    it should be `:crypto.strong_rand_bytes/1`.
    - `otp` (String): The OTP to verify, for example `"581234"`.

    #### Example:
    ```elixir
    valid_otp?(secret, "581234", :base32)

    # Or, you might put the time when the token was used for the last time to
    # prohibit the user from using it again.

    last_used = System.os_time(:second)
    valid_otp?(secret, "581234", last_used, :base32)
    ```

    > #### Use cases information {: .tip}
    >
    > One thing to keep in mind is that you ought to have already kept the
    > secret of each user in a location such as a database.
    """
    @spec valid_otp?(binary(), String.t(), :base32 | NimbleTOTP.time()) :: boolean()
    def valid_otp?(secret, otp, :base32), do: base32_valid_otp?(secret, otp)

    def valid_otp?(secret, otp, last_used) do
      NimbleTOTP.valid?(secret, otp, since: last_used)
    end

    @doc """
    For information See `valid_otp?/3` and `valid_otp?/2`
    """
    @spec valid_otp?(binary(), String.t(), NimbleTOTP.time(), :base32) :: boolean()
    def valid_otp?(secret, otp, last_used, :base32), do: base32_valid_otp?(secret, otp, last_used)

    @doc """
    For information See `valid_otp?/3` and `valid_otp?/2`
    """
    @spec base32_valid_otp?(binary(), String.t()) :: boolean()
    def base32_valid_otp?(secret, otp) do
      Base.decode32!(secret)
      |> NimbleTOTP.valid?(otp)
    end

    @doc """
    For information See `valid_otp?/3` and `valid_otp?/2`
    """
    @spec base32_valid_otp?(binary(), String.t(), NimbleTOTP.time()) :: boolean()
    def base32_valid_otp?(secret, otp, last_used) do
      Base.decode32!(secret)
      |> NimbleTOTP.valid?(otp, since: last_used)
    end
  end

  @doc """
  ### Bcrypt

  - `bcrypt_elixir`: https://hex.pm/packages/bcrypt_elixir
  - `LICENSE`: https://github.com/riverrun/comeonin/blob/master/LICENSE

  > #### Use cases information {: .warning}
  >
  > Make sure you have a `C compiler` installed. See the Comeonin wiki for details.
  > Wiki link: https://github.com/riverrun/comeonin/wiki/Requirements

  Bcrypt is a key derivation function for passwords designed by Niels
  Provos and David Mazières. Bcrypt is an adaptive function, which means
  that it can be configured to remain slow and resistant to brute-force
  attacks even as computational power increases.

  Bcrypt has no known vulnerabilities and has been widely tested for over 15 years.
  However, as it has a low memory use, it is susceptible to GPU cracking attacks.

  ---

  You are required to make use of this function in order to generate an irreversible (hashed)
  duplicate of the user's password when you are storing your password.

  Additionally, you should save it in the database together with other unique features
  of your unique program.

  ### Exmple:

  ```elixir
  create_hash_password("USER_HARD_PASSWORD", :bcrypt)
  ```

  ---

  ### Pbkdf2

  - `pbkdf2` - pbkdf2_elixir https://hex.pm/packages/pbkdf2_elixir
  - `LICENSE`: https://github.com/riverrun/pbkdf2_elixir/blob/master/LICENSE.md

  Pbkdf2 is a password-based key derivation function that uses a password, a variable-length
  salt and an iteration count and applies a pseudorandom function to these to produce a key.

  Pbkdf2 has no known vulnerabilities and has been widely tested for over 15 years.
  However, like Bcrypt, as it has a low memory use, it is susceptible to GPU cracking attacks.

  The original implementation of Pbkdf2 used SHA-1 as the pseudorandom function,
  but this version uses HMAC-SHA-512, the default, or HMAC-SHA-256.

  ### Exmple:

  ```elixir
  create_hash_password("USER_HARD_PASSWORD", :pbkdf2)
  ```

  ---

  ### Argon2

  Argon2 is the winner of the Password Hashing Competition (PHC).

  - https://password-hashing.net/
  - `argon2`: argon2_elixir https://hex.pm/packages/argon2_elixir (recommended)
  - https://github.com/riverrun/argon2_elixir/blob/master/LICENSE.md

  Argon2 is a memory-hard password hashing function which can be used to hash passwords for credential
  storage, key derivation, or other applications.

  Being memory-hard means that it is not only computationally expensive, but it also uses a
  lot of memory (which can be configured). This means that it is much more difficult
  to attack Argon2 hashes using GPUs or dedicated hardware.

  > #### Use cases information {: .warning}
  >
  > Make sure you have a `C compiler` installed. See the Comeonin wiki for details.
  > Wiki link: https://github.com/riverrun/comeonin/wiki/Requirements

  #### Configuration
  The following four parameters can be set in the config file (these can all be overridden using keyword options):

  - t_cost - time cost
  > the amount of computation, given in number of iterations
  >
  > 3 is the default

  - m_cost - memory usage

  > 16 is the default - this will produce a memory usage of 64 MiB (2 ^ 16 KiB)
  >
  > parallelism - number of parallel threads
  >
  > 4 is the default

  - argon2_type - argon2 variant to use

  > 0 (Argon2d), 1 (Argon2i) or 2 (Argon2id)
  >
  > 2 is the default (Argon2id)

  ---

  For verifing you can use like this:

  ```elixir
  verify_password(hash, "USER_HARD_PASSWORD", :bcrypt)

  verify_password(hash, "USER_HARD_PASSWORD", :pbkdf2)

  verify_password(hash, "USER_HARD_PASSWORD", :argon2)
  ```
  """
  if Code.ensure_loaded?(Bcrypt) do
    def create_hash_password(password, :bcrypt) do
      Bcrypt.hash_pwd_salt(password)
    end
  end

  if Code.ensure_loaded?(Pbkdf2) do
    def create_hash_password(password, :pbkdf2) do
      Pbkdf2.hash_pwd_salt(password, digest: :sha512)
    end
  end

  if Code.ensure_loaded?(Argon2) do
    def create_hash_password(password, :argon2) do
      Argon2.hash_pwd_salt(password, digest: :sha512)
    end
  end

  @doc """
  For information See `create_hash_password/2`.
  """
  if Code.ensure_loaded?(Bcrypt) do
    def verify_password(hash, password, :bcrypt) do
      Bcrypt.verify_pass(password, hash)
    end

    def verify_password(hash, password, :bcrypt_2b) do
      String.replace_prefix(hash, "$2y$", "$2b$")
      |> then(&Bcrypt.verify_pass(password, &1))
    end
  end

  if Code.ensure_loaded?(Pbkdf2) do
    def verify_password(hash, password, :pbkdf2) do
      Pbkdf2.verify_pass(password, hash)
    end
  end

  if Code.ensure_loaded?(Argon2) do
    def verify_password(hash, password, :argon2) do
      Argon2.verify_pass(password, hash)
    end
  end

  if Code.ensure_loaded?(Bcrypt) do
    def no_user_verify_password(password, :bcrypt) do
      Bcrypt.no_user_verify(password: password)
    end
  end

  if Code.ensure_loaded?(Pbkdf2) do
    def no_user_verify_password(password, :pbkdf2) do
      Pbkdf2.no_user_verify(password: password)
    end
  end

  if Code.ensure_loaded?(Argon2) do
    def no_user_verify_password(password, :argon2) do
      Argon2.no_user_verify(password: password)
    end
  end

  @doc """
  This is a straightforward data hashing function that does not differentiate between
  **`symmetric`** and **`asymmetric`** functions according to their characteristics. Take, for instance,
  the use of **`checksums`** or codes associated with `nonce`, `c_hash`, `at_hash`, and other similar concepts.

  > #### Security issue {: .warning}
  >
  > It is not recommended to use this function for hashing passwords or JWTs.

  ##### I inspired the initial code from this path:

  - https://github.com/malach-it/boruta_auth/blob/master/lib/boruta/oauth/schemas/client.ex#L173
  """
  def simple_hash(text, alg, truncated \\ nil) do
    :crypto.hash(@simple_hash_algs[alg]["hash_algorithm"], text)
    |> binary_part(0, truncated || @simple_hash_algs[alg]["binary_size"])
    |> Base.url_encode64(padding: false)
  end
end
