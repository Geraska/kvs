import Config

config :kvs, Kvs.Repo,
  database: "arslan_test",
  username: "arslan",
  password: "1234567890",
  hostname: "192.168.0.2"

config :kvs, ecto_repos: [Kvs.Repo]
