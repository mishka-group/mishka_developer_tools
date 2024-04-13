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
    def create_otp_link(secret, issuer, label) do
      user_url = NimbleTOTP.otpauth_uri("#{issuer}:#{label}", secret, issuer: issuer)
      base32_secret = URI.decode_query(URI.parse(user_url).query)["secret"]
      %{secret: base32_secret, url: user_url}
    end

    def create_otp_link_and_secret(issuer, label) do
      secret = NimbleTOTP.secret()
      user_url = NimbleTOTP.otpauth_uri("#{issuer}:#{label}", secret, issuer: issuer)
      base32_secret = URI.decode_query(URI.parse(user_url).query)["secret"]
      %{secret: base32_secret, url: user_url}
    end

    def valid_otp?(secret, otp) do
      NimbleTOTP.valid?(secret, otp)
    end

    def valid_otp?(secret, otp, :base32), do: base32_valid_otp?(secret, otp)

    def valid_otp?(secret, otp, last_used) do
      NimbleTOTP.valid?(secret, otp, since: last_used)
    end

    def valid_otp?(secret, otp, last_used, :base32), do: base32_valid_otp?(secret, otp, last_used)

    def base32_valid_otp?(secret, otp) do
      Base.decode32!(secret)
      |> NimbleTOTP.valid?(otp)
    end

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
