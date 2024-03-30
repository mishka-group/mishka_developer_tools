defmodule MishkaDeveloperTools.Helper.Crypto do
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
