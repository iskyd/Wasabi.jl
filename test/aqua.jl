@testset "Aqua" begin
    using Aqua

    Aqua.test_all(Wasabi, ambiguities = false)
end