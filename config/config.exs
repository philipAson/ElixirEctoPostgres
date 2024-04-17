import Config

config :users, Users.Repo,
  database: "users_repo",
  username: "postgres",
  password: "iceman",
  hostname: "localhost"

config :users, ecto_repos: [Users.Repo]
