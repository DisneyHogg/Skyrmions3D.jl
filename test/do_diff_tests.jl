# This seems difficult to test. These check that energy decreases
# as you flow, and that they run.

using Skyrmions3D

a_skyrmion = Skyrmion(30, 0.2, mpi = 1.0);

p(z) = z
q(z) = 1

make_rational_map!(a_skyrmion, p, q, baryon = 1)

initial_energy = Energy(a_skyrmion)
gradient_flow!(a_skyrmion, steps = 1)
new_energy = Energy(a_skyrmion)
@test new_energy < initial_energy
arrested_newton_flow!(a_skyrmion, steps = 5, method = "RK4")
newer_energy = Energy(a_skyrmion)
@test newer_energy < new_energy

@test_throws Exception arrested_newton_flow!(a_skyrmion, steps = 5, method = "bad method")

set_periodic!(a_skyrmion)
initial_energy = Energy(a_skyrmion)
gradient_flow!(a_skyrmion, steps = 1)
new_energy = Energy(a_skyrmion)
@test new_energy < initial_energy
arrested_newton_flow!(a_skyrmion, steps = 5, method = "RK4")
newer_energy = Energy(a_skyrmion)
@test newer_energy < new_energy

set_neumann!(a_skyrmion)
initial_energy = Energy(a_skyrmion)
gradient_flow!(a_skyrmion, steps = 1)
new_energy = Energy(a_skyrmion)
@test new_energy < initial_energy
arrested_newton_flow!(a_skyrmion, steps = 5, method = "RK4")
newer_energy = Energy(a_skyrmion)
@test newer_energy < new_energy

make_rational_map!(a_skyrmion, p, q, baryon = 1)

initial_energy = Energy(a_skyrmion)
arrested_newton_flow!(a_skyrmion, steps = 5, method = "leapfrog")
new_energy = Energy(a_skyrmion)
@test new_energy < initial_energy

set_periodic!(a_skyrmion)
initial_energy = Energy(a_skyrmion)
arrested_newton_flow!(a_skyrmion, steps = 5, method = "leapfrog")
new_energy = Energy(a_skyrmion)
@test new_energy < initial_energy

set_neumann!(a_skyrmion)
initial_energy = Energy(a_skyrmion)
arrested_newton_flow!(a_skyrmion, steps = 5, method = "leapfrog")
new_energy = Energy(a_skyrmion)
@test new_energy < initial_energy
