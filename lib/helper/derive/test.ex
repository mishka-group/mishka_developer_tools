defmodule ProgrammerA do
  def validate(:testv1, input, field) when is_binary(input) do
    {:error, field, :trim, "The #{field} field must not be empty"}
  end

  def validate(:testv2, input, field) when is_binary(input) do
    {:error, field, :space, "The #{field} field must not be empty"}
  end
end
