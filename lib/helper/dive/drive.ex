defmodule MishkaDeveloperTools.Helper.Drive do
  alias MishkaDeveloperTools.Helper.Drive.{Parser, SanitizerDriver, ValidationDriver}

  def drive({:error, _, _} = error, _drive_input), do: error

  def drive({:ok, data} = okey, drive_input) do
    case Parser.parser(drive_input) do
      nil ->
        okey

      parsed_drive ->
        data
        |> SanitizerDriver.call(Map.get(parsed_drive, :sanitize))
        |> ValidationDriver.call(Map.get(parsed_drive, :validate))
    end
  end
end
