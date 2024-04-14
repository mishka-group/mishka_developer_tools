defmodule MishkaDeveloperTools.Helper.Crypto do
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
    def create_otp_link_and_secret(issuer, label) do
      secret = NimbleTOTP.secret()
      user_url = NimbleTOTP.otpauth_uri("#{issuer}:#{label}", secret, issuer: issuer)
      base32_secret = URI.decode_query(URI.parse(user_url).query)["secret"]
      %{secret: base32_secret, url: user_url}
    end

    @doc """
    For information See `create_otp_link/3`
    """
    def create_otp(secret, issuer, label), do: create_otp_link(secret, issuer, label)

    @doc """
    For information See `create_otp_link_and_secret/2`
    """
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
    def valid_otp?(secret, otp, :base32), do: base32_valid_otp?(secret, otp)

    def valid_otp?(secret, otp, last_used) do
      NimbleTOTP.valid?(secret, otp, since: last_used)
    end

    @doc """
    For information See `valid_otp?/3` and `valid_otp?/2`
    """
    def valid_otp?(secret, otp, last_used, :base32), do: base32_valid_otp?(secret, otp, last_used)

    @doc """
    For information See `valid_otp?/3` and `valid_otp?/2`
    """
    def base32_valid_otp?(secret, otp) do
      Base.decode32!(secret)
      |> NimbleTOTP.valid?(otp)
    end

    @doc """
    For information See `valid_otp?/3` and `valid_otp?/2`
    """
    def base32_valid_otp?(secret, otp, last_used) do
      Base.decode32!(secret)
      |> NimbleTOTP.valid?(otp, since: last_used)
    end
  end

  # TODO: create qr code and docs for otp

  # It should support diffrent type of hashing from user selected
  # bcrypt - bcrypt_elixir https://hex.pm/packages/bcrypt_elixir
  # pbkdf2 - pbkdf2_elixir https://hex.pm/packages/pbkdf2_elixir
  # argon2 - argon2_elixir https://hex.pm/packages/argon2_elixir (recommended)
  #
  # boruta_auth/lib/boruta/oauth/request/base.ex

  # [
  #   "client_credentials",
  #   "password",
  #   "authorization_code",
  #   "refresh_token",
  #   "implicit",
  #   "revoke",
  #   "introspect"
  # ]

  # RS256: [type: :asymmetric, hash_algorithm: :SHA256, binary_size: 16]
  # RS384: [type: :asymmetric, hash_algorithm: :SHA384, binary_size: 24]
  # RS512: [type: :asymmetric, hash_algorithm: :SHA512, binary_size: 32]
  # HS256: [type: :symmetric, hash_algorithm: :SHA256, binary_size: 16]
  # HS384: [type: :symmetric, hash_algorithm: :SHA384, binary_size: 24]
  # HS512: [type: :symmetric, hash_algorithm: :SHA512, binary_size: 32]

  # def hash(string, client) do
  #   hash_alg(client)
  #   |> Atom.to_string()
  #   |> String.downcase()
  #   |> String.to_atom()
  #   |> :crypto.hash(string)
  #   |> binary_part(0, hash_binary_size(client))
  #   |> Base.url_encode64(padding: false)
  # end
end
