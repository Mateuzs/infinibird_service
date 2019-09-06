config :remix,
  escript: true,
  silent: true

# DB config
config :infinibird, Infinibird.Repo,
username: "infinibird",
password: "infinibird",
database: "infinibird_db",
hostname: "localhost",
pool_size: 10