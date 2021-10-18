defmodule KeyValueStore do
  use Ecto.Schema
  import Ecto.Changeset
  alias Kvs.Repo
  import Ecto.Query, only: [from: 2]

  schema "params" do
    field(:key, :string)
    field(:value, :string)
    field(:type, :string)
  end

  def changeset(obj, params \\ %{}) do
    obj
    |> cast(params, [:key, :type, :value])
    |> validate_required([:key, :type, :value])
    |> unsafe_validate_unique([:key], Repo)
  end

  def add(key, value) do
    new_key =
      cond do
        is_atom(key) -> Atom.to_string(key)
        is_bitstring(key) -> key
      end

    new_value =
      cond do
        is_integer(value) ->
          Map.put(%{key: new_key, type: "integer"}, :value, Integer.to_string(value))

        is_bitstring(value) ->
          Map.put(%{key: new_key, type: "string"}, :value, value)

        is_map(value) ->
          Map.put(%{key: new_key, type: "map"}, :value, map_to_string(value))
      end

    changeset(%__MODULE__{}, new_value)
    |> Repo.insert()
  end

  def map_to_string(map) do
    Enum.reduce(map, "", fn {k, v}, acc -> acc <> to_string(k) <> ":" <> to_string(v) <> "," end)
    |> String.replace_trailing(",", "")
  end

  def get_by_key(key) do
    query =
      from(
        p in KeyValueStore,
        where: p.key == ^key,
        select: p
      )

    repo = Repo.one(query)
    new_key = String.to_atom(repo.key)

    case repo.type do
      "integer" ->
        Map.put(%{}, new_key, String.to_integer(repo.value))

      "string" ->
        Map.put(%{}, new_key, repo.value)

      "map" ->
        repo.value
        |> String.split(",")
        |> Enum.map(fn item -> String.split(item, ":") end)
        |> Enum.map(fn [key, value] -> %{String.to_atom(key) => value} end)
        |> Enum.reduce(%{}, fn x, acc ->
          Map.put(acc, hd(Map.keys(x)), hd(Map.values(x)))
        end)
    end
  end

  def get_all do
    from(
      p in KeyValueStore,
      select: p
    )
    |> Repo.all()
  end
end
