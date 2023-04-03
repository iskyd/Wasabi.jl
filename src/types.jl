using Wasabi
using Dates

struct AutoIncrement
    value::Int
end

function Wasabi.to_sql_value(value::Any)
    return value
end

function Wasabi.to_sql_value(value::DateTime)
    return Dates.format(value, "yyyy-mm-ddTHH:MM:SS.s")
end

function Wasabi.to_sql_value(value::Date)
    return Dates.format(value, "yyyy-mm-dd")
end

function Wasabi.from_sql_value(t::Type{T}, value::Any) where {T}
    return value
end

function Wasabi.from_sql_value(t::Type{DateTime}, value::Any)
    return DateTime(value)
end

function Wasabi.from_sql_value(t::Type{Date}, value::Any)
    return Date(value)
end

function Wasabi.to_sql_value(value::AutoIncrement)
    return value.value
end

function Wasabi.from_sql_value(t::Type{AutoIncrement}, value)
    return AutoIncrement(value)
end