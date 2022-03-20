defmodule DioneConfig.Resolver do
  @moduledoc """
  Resolves the config
  """
  def config do
    loc = location()
    ret = %{:location => loc}
    ret
  end

  defp from_env(atom) do
    string = Atom.to_string(atom)
    System.fetch_env(string)
  end

  defp env_with_backup(atom, backup) do
    from_env(atom)
    |> match_backup(backup)
  end

  defp match_backup({:ok, result}, _) when is_bitstring(result) do
    result
  end

  defp match_backup(_, backup) do
    backup
  end

  defp longitude(backup) do
    string = env_with_backup(:longitude, backup)
    String.to_float(string)
  end

  defp latitude(backup) do
    string = env_with_backup(:latitude, backup)
    String.to_float(string)
  end

  @spec location(bitstring, bitstring) :: {float, float}
  defp location(longitude \\ "-76.770833", latitude \\ "39.107778") do
    {longitude(longitude), latitude(latitude)}
  end
end
