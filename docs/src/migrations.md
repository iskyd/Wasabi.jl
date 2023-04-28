# Migrations

Migrations are an easy way to keep track of database schema updates.

This will generate a folder containing the first migration which create the migration table and keep track of the current status of the database.

```
using Wasbi
using WasabiMigrations

path = "migrations/"
WasabiMigrations.generate(path)
```

Next you can update (upgrade/downgrade) the database to the required version doing
```
using Wasbi
using WasabiMigrations
using WasabiSQLite

version = "xxx" # using WasabiMigrations.get_last_version(path) gives you the latest available migration
WasabiMigrations.execute(db, path, version)
```