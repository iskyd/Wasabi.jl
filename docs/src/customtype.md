# Create a Custom Type

You can implement a new custom type just implementing some functions.

```Wasabi.to_sql_value(value::CustomType)``` is used to convert the custom type to the database type

```Wasabi.from_sql_value(t::Type{CustomType}, value::Any)``` is used to convert the value from the database to your custom type

```Wasabi.mapping(db::Type{SQLite.DB}, t::Type{CustomType})``` is used to define the database type

Suppose you want to create a JSON type called CustomType that is converted as TEXT on the database.

```
using SQLite

struct CustomType
    value::Dict
end

Wasabi.mapping(db::Type{SQLite.DB}, t::Type{CustomType}) = "TEXT"
Wasabi.to_sql_value(value::CustomType) = JSON.json(value.value)
Wasabi.from_sql_value(t::Type{CustomType}, value::Any) = CustomType(JSON.parse(value))

struct TestModel <: Wasabi.Model
    id::Int
    custom::CustomType
end

model = TestModel(1, CustomType(Dict("key" => "value")))
Wasabi.insert!(conn, model)

model = Wasabi.first(conn, TestModel, 1) # model.custom.value["key"] == "value"
```