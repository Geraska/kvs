defmodule KeyValueStore do
  use Ecto.Schema
  import Ecto.Changeset
  alias KeyValueStore.Repo

  schema "params" do
    field(:key, :string)
    field(:value, :string)
    field(:type, :string)

    timestamps()
  end

  def changeset(param, opts \\ %{}) do
    param
    |> cast(opts, [:key, :type, :value])
    |> validate_required([:key, :type, :value])
    |> unsafe_validate_unique("params", [:key])
  end

  def add(key, value) do
    new_key = Atom.to_string(key)

    cond do
      is_integer(value) ->
        Map.put(%{key: new_key, type: "integer"}, :value, Integer.to_string(value))

      is_bitstring(value) ->
        Map.put(%{key: new_key, type: "string"}, :value, value)

      is_map(value) ->
        Map.put(%{key: new_key, type: "map"}, :value, new_value(value))
    end
    |> changeset(%{})
    |> Repo.insert()
  end

  def new_value(map) do
    keys = Map.keys(map)
    values = Map.values(map)
    new_keys = Enum.map(keys, fn x -> Atom.to_string(x) end)

    new_values =
      cond do
        is_integer(hd(values)) -> Enum.map(values, fn x -> Integer.to_string(x) end)
        is_bitstring(hd(values)) -> values
      end
      Enum.reduce()
  end
end
