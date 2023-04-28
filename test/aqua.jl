@testset "Aqua" begin
    using Aqua

    Aqua.test_all(Wasabi, ambiguities = false, stale_deps = false)
end