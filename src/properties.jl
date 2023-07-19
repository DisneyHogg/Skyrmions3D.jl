"""
    Energy(skyrmion; density=false)

Compute energy of `skyrmion`.

Set 'density = true' to output the energy density and moment to `n` to calculate the nth moment of the energy density.

"""
function Energy(sk; density=false, moment=0)

    ED = zeros(sk.lp[1], sk.lp[2], sk.lp[3])

    get_energy_density!(ED,sk,moment=moment)

    if density == false
        engtot = sum(ED)*sk.ls[1]*sk.ls[2]*sk.ls[3]
        if sk.physical == false
            return engtot/(12.0*pi^2)
        else
            if moment == 0
                return (engtot*sk.Fpi/(4.0*sk.ee), "MeV" )
            else
                return (engtot*sk.Fpi*(197.327*2.0/(sk.ee*sk.Fpi))/(4.0*sk.ee), "MeV fm^"*string(moment))
            end
        end
    else
        return ED
    end

end 

function get_energy_density!(density, sk ;moment=0)

    Threads.@threads for i in sk.sum_grid[1]
        @inbounds for j in sk.sum_grid[2], k in sk.sum_grid[3]
        
            if sk.periodic == false
                dp = getDX(sk ,i, j, k )
            else
                dp = getDXp(sk ,i, j, k )
            end

            if moment == 0
                density[i,j,k] = engpt(dp,sk.pion_field[i,j,k,4],sk.mpi)
            else
                r = sqrt( sk.x[1][i]^2 + sk.x[2][j]^2 + sk.x[3][k]^2 )
                density[i,j,k] = engpt(dp,sk.pion_field[i,j,k,4],sk.mpi) * r^moment
            end
        
        end
    end

end


function engpt(dp,p4,mpi)

    return 2*mpi^2*(1 - p4) + (dp[1,1]^2 + dp[1,2]^2 + dp[1,3]^2 + dp[1,4]^2 + dp[2,1]^2 + dp[2,2]^2 + dp[2,3]^2 + dp[2,4]^2 + dp[3,1]^2 + dp[3,2]^2 + dp[3,3]^2 + dp[3,4]^2) + (dp[1,4]^2*dp[2,1]^2 + dp[1,4]^2*dp[2,2]^2 + dp[1,4]^2*dp[2,3]^2 + dp[1,1]^2*(dp[2,2]^2 + dp[2,3]^2) - 2*dp[1,1]*dp[1,4]*dp[2,1]*dp[2,4] + dp[1,1]^2*dp[2,4]^2 + dp[1,4]^2*dp[3,1]^2 + dp[2,2]^2*dp[3,1]^2 + dp[2,3]^2*dp[3,1]^2 + dp[2,4]^2*dp[3,1]^2 - 2*dp[2,1]*dp[2,2]*dp[3,1]*dp[3,2] + dp[1,1]^2*dp[3,2]^2 + dp[1,4]^2*dp[3,2]^2 + dp[2,1]^2*dp[3,2]^2 + dp[2,3]^2*dp[3,2]^2 + dp[2,4]^2*dp[3,2]^2 - 2*dp[2,1]*dp[2,3]*dp[3,1]*dp[3,3] - 2*dp[2,2]*dp[2,3]*dp[3,2]*dp[3,3] + dp[1,1]^2*dp[3,3]^2 + dp[1,4]^2*dp[3,3]^2 + dp[2,1]^2*dp[3,3]^2 + dp[2,2]^2*dp[3,3]^2 + dp[2,4]^2*dp[3,3]^2 - 2*(dp[1,1]*dp[1,4]*dp[3,1] + dp[2,4]*(dp[2,1]*dp[3,1] + dp[2,2]*dp[3,2] + dp[2,3]*dp[3,3]))*dp[3,4] + (dp[1,1]^2 + dp[2,1]^2 + dp[2,2]^2 + dp[2,3]^2)*dp[3,4]^2 + dp[1,3]^2*(dp[2,1]^2 + dp[2,2]^2 + dp[2,4]^2 + dp[3,1]^2 + dp[3,2]^2 + dp[3,4]^2) + dp[1,2]^2*(dp[2,1]^2 + dp[2,3]^2 + dp[2,4]^2 + dp[3,1]^2 + dp[3,3]^2 + dp[3,4]^2) - 2*dp[1,2]*(dp[1,1]*(dp[2,1]*dp[2,2] + dp[3,1]*dp[3,2]) + dp[1,3]*(dp[2,2]*dp[2,3] + dp[3,2]*dp[3,3]) + dp[1,4]*(dp[2,2]*dp[2,4] + dp[3,2]*dp[3,4])) - 2*dp[1,3]*(dp[1,1]*(dp[2,1]*dp[2,3] + dp[3,1]*dp[3,3]) + dp[1,4]*(dp[2,3]*dp[2,4] + dp[3,3]*dp[3,4])))

end



"""
    Baryon(skyrmion; density=false)

Compute baryon number of `skyrmion`.

Set 'density = true' to output the baryon density and moment to `n` to calculate the nth moment of the baryon density.

"""
function Baryon(sk; density=false, moment = 0)

    BD = zeros(sk.lp[1],sk.lp[2],sk.lp[3])
    
    get_baryon_density!(BD,sk,moment=moment)

    if density == false
        bartot = sum(BD)*sk.ls[1]*sk.ls[2]*sk.ls[3]/(2.0*pi^2)
        return bartot
    else
        return BD
    end
    
end 

function get_baryon_density!(baryon_density, sk ;moment=0)

    Threads.@threads for i in sk.sum_grid[1]
        @inbounds for j in sk.sum_grid[2], k in sk.sum_grid[3]
        
            pp = getX(sk,i,j,k)
            if sk.periodic == false
                dp = getDX(sk ,i, j, k )
            else
                dp = getDXp(sk ,i, j, k )
            end

            if moment == 0
                baryon_density[i,j,k] = barypt(dp,pp)
            else
                r = sqrt( sk.x[1][i]^2 + sk.x[2][j]^2 + sk.x[3][k]^2 )
                baryon_density[i,j,k] = barypt(dp,pp) * r^moment
            end
        
        end
    end

end

function barypt(dp,pp)
    return pp[4]*dp[1,3]*dp[2,2]*dp[3,1] - pp[3]*dp[1,4]*dp[2,2]*dp[3,1] - pp[4]*dp[1,2]*dp[2,3]*dp[3,1] + pp[2]*dp[1,4]*dp[2,3]*dp[3,1] + pp[3]*dp[1,2]*dp[2,4]*dp[3,1] - pp[2]*dp[1,3]*dp[2,4]*dp[3,1] - pp[4]*dp[1,3]*dp[2,1]*dp[3,2] + pp[3]*dp[1,4]*dp[2,1]*dp[3,2] + pp[4]*dp[1,1]*dp[2,3]*dp[3,2] - pp[1]*dp[1,4]*dp[2,3]*dp[3,2] - pp[3]*dp[1,1]*dp[2,4]*dp[3,2] + pp[1]*dp[1,3]*dp[2,4]*dp[3,2] + pp[4]*dp[1,2]*dp[2,1]*dp[3,3] - pp[2]*dp[1,4]*dp[2,1]*dp[3,3] - pp[4]*dp[1,1]*dp[2,2]*dp[3,3] + pp[1]*dp[1,4]*dp[2,2]*dp[3,3] + pp[2]*dp[1,1]*dp[2,4]*dp[3,3] - pp[1]*dp[1,2]*dp[2,4]*dp[3,3] - pp[3]*dp[1,2]*dp[2,1]*dp[3,4] + pp[2]*dp[1,3]*dp[2,1]*dp[3,4] + pp[3]*dp[1,1]*dp[2,2]*dp[3,4] - pp[1]*dp[1,3]*dp[2,2]*dp[3,4] - pp[2]*dp[1,1]*dp[2,3]*dp[3,4] + pp[1]*dp[1,2]*dp[2,3]*dp[3,4]
end



"""
    compute_current(skyrmion; label="uMOI", indices=[0,0], density = false, moment=0)

Compute a variety of currents in the Skyrme model, based on a `skyrmion`. 

You can calculate specific indices using e.g. `indices = [1,2]`. If `indices = [0,0]`, the function will calculate all indices. If `density = false`, the function will return the integrated densities, while `density = true` it will return the densities. 

The possible currents are (currently):
- `uMOI`: the isospin moment of inertia.
- `wMOI`: the mixed moment of inertia.
- `vMOI`: the spin moment of inertia.
- `uAxial`: the u-axial moment of inertia.
- `wAxial`: the w-axial moment of inertia.
- `NoetherIso`: the Noether vector current.
- `NoetherAxial`: the Noether axial current.

"""
function compute_current(sk; label="uMOI", indices=[0,0], density=false, moment=0  )

    if label != "uMOI" && label != "wMOI" && label != "vMOI" && label != "uAxial" && label != "wAxial" && label != "wAxial" && label != "NoetherIso" && label != "NoetherAxial" && label != "stress"
        println("ERROR: Current label '", label, "' unknown. Type '?compute_current' for help.")
        return
    end

    aindices = 1:3
    bindices = 1:3

    KD = diagm([1.0,1.0,1.0])

    x = sk.x

    if indices == [0,0]
        current_density = zeros(3,3,sk.lp[1],sk.lp[2],sk.lp[3])
        aindices = 1:3
        bindices = 1:3
    else
        current_density = zeros(3,3,sk.lp[1],sk.lp[2],sk.lp[3])
        aindices = indices[1]
        bindices = indices[2]
    end

    Threads.@threads for i in sk.sum_grid[1]
        @inbounds for j in sk.sum_grid[2], k in sk.sum_grid[3]

            xxx = SVector{3,Float64}(x[1][i], x[2][j], x[3][k] )
            r = sqrt( xxx[1]^2 + xxx[2]^2 + xxx[3]^2 )
            p = getX(sk,i,j,k)

            if sk.periodic == false
                dp = getDX(sk ,i, j, k )
            else
                dp = getDXp(sk ,i, j, k )
            end

            if label == "uMOI"

                Tiam, Lia = getTiam(p), getLka(p,dp)

                for a in aindices, b in bindices
                    current_density[a,b,i,j,k] = -trace_su2_ij(Tiam,Tiam,a,b)*r^moment
                    for c in 1:3
                        current_density[a,b,i,j,k] -= 0.25*trace_su2_ijkl(Tiam,Lia,Tiam,Lia,a,c,b,c)*r^moment
                    end
                end

            elseif label == "wMOI"

                Tiam, Lia = getTiam(p), getLka(p,dp)
                Gia = -1.0.*getGia(Lia,xxx)

                for a in aindices, b in bindices
                    current_density[a,b,i,j,k] = -trace_su2_ij(Gia,Tiam,a,b)*r^moment
                    for c in 1:3
                        current_density[a,b,i,j,k] -= 0.25*trace_su2_ijkl(Gia,Lia,Tiam,Lia,a,c,b,c)*r^moment
                    end
                end

            elseif label == "vMOI"

                Lia = getLka(p,dp)
                Gia = -1.0.*getGia(Lia,xxx)

                for a in aindices, b in bindices
                    current_density[a,b,i,j,k] = -trace_su2_ij(Gia,Gia,a,b)*r^moment
                    for c in 1:3
                        current_density[a,b,i,j,k] -= 0.25*trace_su2_ijkl(Gia,Lia,Gia,Lia,a,c,b,c)*r^moment
                    end
                end

            elseif label == "uAxial"

                Tiam, Tiap, Lia = getTiam(p), getTiap(p), getRka(p,dp)

                for a in aindices, b in bindices
                    current_density[a,b,i,j,k] = -trace_su2_ij(Tiam,Tiap,a,b)*r^moment
                    for c in 1:3
                        current_density[a,b,i,j,k] -= 0.25*trace_su2_ijkl(Tiam,Lia,Tiap,Lia,a,c,b,c)*r^moment
                    end
                end

            elseif label == "wAxial"

                Tiap, Lia = getTiap(p), getLka(p,dp)
                Gia = -1.0.*getGia(Lia,xxx)

                for a in aindices, b in bindices
                    current_density[a,b,i,j,k] = trace_su2_ij(Tiap,Gia,a,b) *r^moment
                    for c in 1:3
                        current_density[a,b,i,j,k] += 0.25*trace_su2_ijkl(Tiap,Lia,Gia,Lia,a,c,b,c)*r^moment
                    end
                end

            elseif label == "stress"

                Lia = getLka(p,dp)

                for a in aindices, b in bindices
                    
                    current_density[a,b,i,j,k] -= (sk.mpi^2/2.0)*(1.0 - p[4])*KD[a,b]*r^moment
                    current_density[a,b,i,j,k] -= trace_su2_ij(Lia,Lia,a,b)*r^moment
                    
                    for c in 1:3

                        current_density[a,b,i,j,k] -= 0.5*trace_su2_ij(Lia,Lia,c,c)*KD[a,b]*r^moment
                        current_density[a,b,i,j,k] -= 0.25*trace_su2_ijkl(Lia,Lia,Lia,Lia,a,c,b,c)*r^moment

                        for d in 1:3
                            current_density[a,b,i,j,k] += 0.0625*trace_su2_ijkl(Lia,Lia,Lia,Lia,c,d,c,d)*KD[a,b]*r^moment
                        end
                    end
                    
                end

            elseif label == "NoetherIso"

                Lia, Tiam = getLka(p,dp), getTiam(p)

                for a in aindices, b in bindices

                    current_density[a,b,i,j,k] -= trace_su2_ij(Lia,Tiam,b,a)*r^moment

                    for c in 1:3
                        current_density[a,b,i,j,k] -= 0.25*trace_su2_ijkl(Lia,Lia,Lia,Tiam,c,b,a,c)*r^moment
                    end

                end
            elseif label == "NoetherAxial"

                # DOWN

                Lia, Tiap = getLka(p,dp), getTiap(p)

                for a in aindices, b in bindices

                    current_density[a,b,i,j,k] += trace_su2_ij(Lia,Tiap,b,a)*r^moment

                    for c in 1:3
                        current_density[a,b,i,j,k] += 0.25*trace_su2_ijkl(Lia,Lia,Lia,Tiap,c,b,a,c)*r^moment
                    end

                end
            
            end

        
        end

    end

    if density == false
        tot_den = zeros(3,3)
        for a in aindices, b in bindices
            tot_den[a,b] = sum(current_density[a,b,:,:,:])*sk.ls[1]*sk.ls[2]*sk.ls[3]
        end
        if indices == [0,0]
            return tot_den
        else
            return tot_den[aindices,bindices]
        end
    else
        if indices == [0,0]
            return current_density
        else
            return current_density[aindices,bindices,:,:,:]
        end
    end
    

end


function getGia(Lia,x)

    return SMatrix{3,3,Float64, 9}(
        Lia[3,1]*x[2] - Lia[2,1]*x[3],
        -Lia[3,1]*x[1] + Lia[1,1]*x[3],
        Lia[2,1]*x[1] - Lia[1,1]*x[2],
        Lia[3,2]*x[2] - Lia[2,2]*x[3],
        -Lia[3,2]*x[1] + Lia[1,2]*x[3],
        Lia[2,2]*x[1] - Lia[1,2]*x[2],
        Lia[3,3]*x[2] - Lia[2,3]*x[3],
        -Lia[3,3]*x[1] + Lia[1,3]*x[3],
        Lia[2,3]*x[1] - Lia[1,3]*x[2]
    )

end

function getTiam(p)

    return SMatrix{3,3,Float64, 9}(
        -p[2]^2 - p[3]^2,
        p[1]*p[2] - p[3]*p[4],
        p[1]*p[3] + p[2]*p[4],
        p[1]*p[2] + p[3]*p[4],
        -p[1]^2 - p[3]^2,
        p[2]*p[3] - p[1]*p[4],
        p[1]*p[3] - p[2]*p[4],
        p[2]*p[3] + p[1]*p[4],
        -p[1]^2 - p[2]^2
    ) 
    
end

function getTiap(p)
    
    return SMatrix{3,3,Float64, 9}(
        p[1]^2 + p[4]^2,
        p[1]*p[2] - p[3]*p[4],
        p[1]*p[3] + p[2]*p[4],
        p[1]*p[2] + p[3]*p[4],
        p[2]^2 + p[4]^2,
        p[2]*p[3] - p[1]*p[4],
        p[1]*p[3] - p[2]*p[4],
        p[2]*p[3] + p[1]*p[4],
        p[3]^2 + p[4]^2
    ) 
    
end

function getRka(p,dp)
    
    return SMatrix{3,3,Float64, 9}(

        -(dp[1,4]*p[1]) - dp[1,3]*p[2] + dp[1,2]*p[3] + dp[1,1]*p[4],
        -(dp[2,4]*p[1]) - dp[2,3]*p[2] + dp[2,2]*p[3] + dp[2,1]*p[4],
        -(dp[3,4]*p[1]) - dp[3,3]*p[2] + dp[3,2]*p[3] + dp[3,1]*p[4],
        dp[1,3]*p[1] - dp[1,4]*p[2] - dp[1,1]*p[3] + dp[1,2]*p[4],
        dp[2,3]*p[1] - dp[2,4]*p[2] - dp[2,1]*p[3] + dp[2,2]*p[4],
        dp[3,3]*p[1] - dp[3,4]*p[2] - dp[3,1]*p[3] + dp[3,2]*p[4],
        -(dp[1,2]*p[1]) + dp[1,1]*p[2] - dp[1,4]*p[3] + dp[1,3]*p[4],
        -(dp[2,2]*p[1]) + dp[2,1]*p[2] - dp[2,4]*p[3] + dp[2,3]*p[4],
        -(dp[3,2]*p[1]) + dp[3,1]*p[2] - dp[3,4]*p[3] + dp[3,3]*p[4],
    ) 
    
end

function getLka(p,dp)

    return SMatrix{3,3,Float64, 9}(

    -(dp[1,4]*p[1]) + dp[1,3]*p[2] - dp[1,2]*p[3] + dp[1,1]*p[4],
    -(dp[2,4]*p[1]) + dp[2,3]*p[2] - dp[2,2]*p[3] + dp[2,1]*p[4],
    -(dp[3,4]*p[1]) + dp[3,3]*p[2] - dp[3,2]*p[3] + dp[3,1]*p[4],
    -(dp[1,3]*p[1]) - dp[1,4]*p[2] + dp[1,1]*p[3] + dp[1,2]*p[4],
    -(dp[2,3]*p[1]) - dp[2,4]*p[2] + dp[2,1]*p[3] + dp[2,2]*p[4],
    -(dp[3,3]*p[1]) - dp[3,4]*p[2] + dp[3,1]*p[3] + dp[3,2]*p[4],
    dp[1,2]*p[1] - dp[1,1]*p[2] - dp[1,4]*p[3] + dp[1,3]*p[4],
    dp[2,2]*p[1] - dp[2,1]*p[2] - dp[2,4]*p[3] + dp[2,3]*p[4],
    dp[3,2]*p[1] - dp[3,1]*p[2] - dp[3,4]*p[3] + dp[3,3]*p[4]

    )

end


"""
    getMOI(skyrmion; density=false, moment=0)

Compute the moments of inertia of `skyrmion`.

Set 'density = true' to output the MOI densities and moment to `n` to calculate the nth moment of the MOI.

"""
function getMOI(sk; density = false, moment=0)
	
    x = sk.x

    MOI_D = zeros(6,6,sk.lp[1],sk.lp[2],sk.lp[3])

    epsilon = make_levi_civita()

	VV = zeros(6,6)
    GG = zeros(6,3)
    RR = zeros(3,3)
	

	@inbounds for i = 3:sk.lp[1]-2, j = 3:sk.lp[2]-2, k = 3:sk.lp[3]-2

	    xxx = [x[1][i], x[2][j], x[3][k]]
        mm = getDX(sk ,i, j, k)
		po = getX(sk, i, j, k)

	    for a in 1:3, b in 1:3

	        RR[a,b] = po[4]*mm[a,b] - mm[a,4]*po[b]
	        GG[a+3,b] = -po[a]*po[b]
	        GG[a+3,a] += po[b]*po[b]

	        for c in 1:3
	            GG[a+3,b] -= po[4]*po[c]*epsilon[a,c,b]
	            for d in 1:3
	                RR[a,b] += epsilon[b,c,d]*mm[a,c]*po[d]
	            end
	        end
	    end

	    for a in 1:3, d in 1:3
            GG[a,d] = 0.0
            for b in 1:3, c in 1:3
	    	    GG[a,d] += epsilon[a,b,c]*xxx[b]*RR[c,d]
            end
	    end

        if i==18 && j==22 && k == 17
            println(GG[4:6,:])
        end

        for a in 1:6, b in 1:6, c in 1:3

            if moment == 0
                MOI_D[a,b,i,j,k] += GG[a,c]*GG[b,c]
            else
                r = sqrt( sk.x[1][i]^2 + sk.x[2][j]^2 + sk.x[3][k]^2 )
                MOI_D[a,b,i,j,k] += GG[a,c]*GG[b,c] * r^moment
            end

            for d = 1:3, e = 1:3

                if moment == 0
                    #MOI_D[a,b,i,j,k] -= 2.0*(GG[a,c]*GG[b,d]*RR[e,c]*RR[e,d] - GG[a,c]*GG[b,c]*RR[d,e]*RR[d,e])
                else
                    r = sqrt( sk.x[1][i]^2 + sk.x[2][j]^2 + sk.x[3][k]^2 )
                    MOI_D[a,b,i,j,k] -= 2.0*(GG[a,c]*GG[b,d]*RR[e,c]*RR[e,d] - GG[a,c]*GG[b,c]*RR[d,e]*RR[d,e])* r^moment
                end

            end
		end
		
	end

    if density == false
        for a in 1:6, b in 1:6
            for i = 3:sk.lp[1]-2,  j = 3:sk.lp[2]-2, k = 3:sk.lp[3]-2
                VV[a,b] += MOI_D[a,b,i,j,k]*sk.ls[1]*sk.ls[2]*sk.ls[3]
            end
        end
        if sk.physical == false
            return VV
        else
            return (VV*sk.Fpi/(4.0*sk.ee)*(197.327*2.0/(sk.ee*sk.Fpi))^2*(197.327*2.0/(sk.ee*sk.Fpi))^moment, "MeV fm^"*string(2+moment))
        end
    else
        return MOI_D
    end
	
	return VV
	
end

function make_levi_civita()

    epsilon = zeros(3,3,3)
	
	epsilon[1,2,3] = 1.0
	epsilon[1,3,2] = -1.0
	epsilon[2,3,1] = 1.0
	epsilon[2,1,3] = -1.0
	epsilon[3,1,2] = 1.0
	epsilon[3,2,1] = -1.0

    return epsilon

end

"""
    center_of_mass(skyrmion; density=false, moment=0)

Compute the center of mass of `skyrmion`, based on the energy density.

"""
function center_of_mass(sk)

    com = zeros(3)

    the_engpt = 0.0
    toteng = 0.0

    @inbounds for i in 3:sk.lp[1]-2, j in 3:sk.lp[2]-2, k in 3:sk.lp[3]-2
    
        dp = getDX(sk ,i, j, k )

        the_engpt = engpt(dp,sk.pion_field[i,j,k,4],sk.mpi)

        com[1] += the_engpt*sk.x[1][i]
        com[2] += the_engpt*sk.x[2][j]
        com[3] += the_engpt*sk.x[3][k]

        toteng += the_engpt
   
    end
        
    return com/toteng

end 


"""
    rms_baryon(skyrmion)

Compute root mean square charge radius of a skyrmion, using the baryon density.
"""
function rms_baryon(sk)

    if sk.physical == false
        return sqrt(Baryon(sk; moment = 2)/Baryon(sk; moment = 0))
    else
        return ( sqrt(Baryon(sk; moment = 2)/Baryon(sk; moment = 0))*197.327*(2.0/(sk.ee*sk.Fpi)), "fm" )
    end

end




function trace_su2_ij(Lia,Lib,i,j)
    return -2.0*(Lia[1,i]*Lib[1,j] + Lia[2,i]*Lib[2,j] + Lia[3,i]*Lib[3,j])
end

function trace_su2_ijkl(L1,L2,L3,L4,i,j,k,l)
    return -8.0*(L1[i,1]*(L2[j,2]*(-(L3[k,2]*L4[l,1]) + L3[k,1]*L4[l,2]) + L2[j,3]*(-(L3[k,3]*L4[l,1]) + L3[k,1]*L4[l,3])) + L1[i,3]*(L2[j,1]*(L3[k,3]*L4[l,1] - L3[k,1]*L4[l,3]) + L2[j,2]*(L3[k,3]*L4[l,2] - L3[k,2]*L4[l,3])) + L1[i,2]*(L2[j,1]*(L3[k,2]*L4[l,1] - L3[k,1]*L4[l,2]) + L2[j,3]*(-(L3[k,3]*L4[l,2]) + L3[k,2]*L4[l,3])))
end



