struct PrimaryKeyConstraint <: ModelConstraint
    fields::Vector{Symbol}
end

struct ForeignKeyConstraint <: ModelConstraint
    fields::Vector{Symbol}
    foreign_table::Symbol
    foreign_fields::Vector{Symbol}
end

struct UniqueConstraint <: ModelConstraint
    fields::Vector{Symbol}
end