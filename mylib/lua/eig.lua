require("array")
require("sparse")

eig={}

function eig.sym(vars)
    local eigensolver=vars.eigensolver or "arpack"
    require(eigensolver)
    return eig[eigensolver](vars)
end

function eig.arpack(vars)
    local A=vars.A
    local n=A:n()
    local nev=vars.nev or math.floor(n/10)
    local band_nev=vars.band_nev or math.floor(nev/2)
    local B=vars.B
    local diag_idx
    local diag
    if not B or getmetatable(B)[".type"]=="array_double" then
        diag_idx=array.array_int(n)
        A:diag(diag_idx)
        diag=B
        B=nil
    end
    local solver=vars.solver or "umfpack"
    require(solver)
    local slv=solver
    solver=_G[solver]
    slv=solver[slv](A)
    if vars.solver_options then
        slv:options(vars.solver_options)
    end
    local maxitr=vars.maxitr or 300
    local tol=vars.tol or 2^(-53)
    local probtype
    if B or diag then
        probtype=arpack.generalized_shift_invert
    else
        probtype=arpack.standard_shift_invert
    end
    local u=arpack.symmetric (n,band_nev,probtype,"LA",maxitr,tol)
    local temp=array.array_double(n)
    local vectors={}
    local values={}
    local sigma=vars.sigma or -tol
    local count_fail=1
    while #values<nev do

        if B then
            A:shift_same(sigma,B)
        else
            if diag then
                A:shift(sigma,diag_idx,diag)
            else
                A:shift(sigma,diag_idx)
            end
        end

        slv:factor()

        u:reset()
        while true do
            local status=u:update()
            if status==arpack.done then
                break
            elseif status==arpack.compute_opx then
                local x=u:x()
                local y=u:y()
                local bx=temp
                if B then
                    B:times(x,bx)
                else
                    if diag then
                        diag:times(x,bx)
                    else
                        bx:copy(x)
                    end
                end
                slv:solve(bx,y)
            elseif status==arpack.compute_opx_with_bx then
                local bx=u:bx()
                local y=u:y()
                slv:solve(bx,y)
            elseif status==arpack.compute_bx then
                local x=u:x()
                local y=u:y()
                if B then
                    B:times(x,y)
                else
                    if diag then
                        diag:times(x,y)
                    else
                        y:copy(x)
                    end
                end
            end
        end
        if B then
            A:shift_same(-sigma,B)
        else
            if diag then
                A:shift(-sigma,diag_idx,diag)
            else
                A:shift(-sigma,diag_idx)
            end
        end
        if u:info() > 0 then
            print("Falha de convergencia",count_fail)
            sigma=sigma+count_fail*tol
            count_fail=count_fail*10
        else
            count_fail=1
            u:post_process(sigma)
            for k=0,band_nev-1 do
                if u:eigenvalue(k) > sigma then
                    values[#values+1]=u:eigenvalue(k)
                    --          print(u:eigenvalue(k))
                    local temp=u:eigenvector(k)
                    local vector=array.array_float(n)
                    --[[    local vecmax=-math.huge
                    for i=0,n-1 do
                    vecmax=math.max(math.abs(temp:get(i)),vecmax)
                    end
                    for i=0,n-1 do vector:set(i,temp:get(i)/vecmax) end]]
                    for i=0,n-1 do vector:set(i,temp:get(i)) end
                    vectors[#vectors+1]=vector
                else
                    --print("x")
                end
            end
            local step=math.max((u:eigenvalue(band_nev-1)-u:eigenvalue(band_nev-2))/1000,tol)
            sigma=u:eigenvalue(band_nev-1)+step
        end
    end
    return vectors,values
end

function eig.blzpack(vars)
    local A=vars.A
    local n=A:n()
    local nev=vars.nev or math.floor(n/10)
    local band_nev=vars.band_nev or math.floor(nev/2)
    local B=vars.B
    local diag_idx
    local diag
    if not B or getmetatable(B)[".type"]=="array_double" then
        diag_idx=array.array_int(n)
        A:diag(diag_idx)
        diag=B
        B=nil
    end
    --local slv=taucs.taucs_ldlt(A)
    require("ma57")
    local slv=ma57.ma57(A)
    local probtype=blzpack.generalized
    local tol=vars.tol or 2^-53
    local u=blzpack.symmetric (n,band_nev,probtype,tol)
    local vectors={}
    local values={}
    local sigma=vars.sigma or -tol

    while #values<nev do

        local nneig=0
        u:reset(sigma,math.huge)
        local prev
        while true do
            local status=u:update(nneig)
            if status==blzpack.done then
                break
            elseif status==blzpack.compute_shifts then
                if prev then
                    if B then
                        A:shift_same(-prev,B)
                    else
                        if diag then
                            A:shift(-prev,diag_idx,diag)
                        else
                            A:shift(-prev,diag_idx)
                        end
                    end
                end
                sigma=u:sigma()
                if B then
                    A:shift_same(sigma,B)
                else
                    if diag then
                        A:shift(sigma,diag_idx,diag)
                    else
                        A:shift(sigma,diag_idx)
                    end
                end

                slv:factor()
                prev=sigma
                nneig=slv:inertia()
            elseif status==blzpack.compute_opu then
                local nvopu=u:nvopu()
                for i=0,nvopu-1 do
                    local U=u:U(i)
                    local V=u:V(i)
                    slv:solve(U,V)
                end
            elseif status==blzpack.compute_bu then
                local nvopu=u:nvopu()
                for i=0,nvopu-1 do
                    local U=u:U(i)
                    local V=u:V(i)
                    if B then
                        B:times(U,V)
                    else
                        if diag then
                            diag:times(U,V)
                        else
                            V:copy(U)
                        end
                    end
                end
            end
        end
        if prev then
            if B then
                A:shift_same(-prev,B)
            else
                if diag then
                    A:shift(-prev,diag_idx,diag)
                else
                    A:shift(-prev,diag_idx)
                end
            end
        end

        if u:info() > 0 then
            print("blzpack error: ",u:info())
        else
            for k=0,band_nev-1 do
                values[#values+1]=u:eigenvalue(k)
                --        print(u:eigenvalue(k))
                local temp=u:eigenvector(k)
                local vector=array.array_float(n)
                --      local vecmax=-math.huge
                --      for i=0,n-1 do
                --        vecmax=math.max(math.abs(temp:get(i)),vecmax)
                --      end
                --      for i=0,n-1 do vector:set(i,temp:get(i)/vecmax) end
                for i=0,n-1 do vector:set(i,temp:get(i)) end
                vectors[#vectors+1]=vector
            end
            local step=math.max((u:eigenvalue(band_nev-1)-u:eigenvalue(band_nev-2))/1000,tol)
            sigma=u:eigenvalue(band_nev-1)+step
        end
    end
    return vectors,values
end

return eig
