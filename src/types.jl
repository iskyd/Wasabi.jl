using Wasabi
using Dates

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