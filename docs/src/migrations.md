# Migrations

Migrations are an easy way to keep track of database schema updates.

This will generate a folder containing the first migration which create the migration table and keep track of the current status of the database.

```julia
using Wasbi

path = "migrations/"
Migrations.generate(path)
```

Next you can update (upgrade/downgrade) the database to the required version doing
```julia
using Wasbi
using SQLite

version = "xxx" # using Migrations.get_last_version(path) gives you the latest available migration
Migrations.execute(db, path, version)
```
