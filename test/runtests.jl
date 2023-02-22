cd(@__DIR__)

using Pkg

using Test, TestSetExtensions, SafeTestsets
using Wasabi

@testset ExtendedTestSet "Wasabi tests" begin
  @includetests ARGS
end