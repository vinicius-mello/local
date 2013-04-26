dofile("modules.lua")
require("array")
require("blas")
require("lapack")
require("lbfgsb")
require("cubic")
require("gsl")

math.acosh = function (x) return math.log(x + math.sqrt(x * x - 1)); end

function normE2(x)
    return blas.dot(x,x)
end

function distE2(x,y,work)
    blas.copy(x,work)
    blas.axpy(-1,y,work)
    return blas.dot(work,work)
end

function distE(x,y,work)
    return math.sqrt(distE2(x,y,work))
end

function deltaH(x,y,work)
    return math.abs(2*distE2(x,y,work)/((1-normE2(x))*(1-normE2(y))))
    -- o valor absoluto eh necessario para erros numericos
end

function distH(x,y,work) -- Poincare model
    return math.acosh(1+deltaH(x,y,work))
end

function distBK(x,y,work) -- Beltrami-Klein model
    local nx=math.sqrt(math.abs(1-normE2(x)))
    local ny=math.sqrt(math.abs(1-normE2(y)))
    local xy=blas.dot(x,y)
    return math.acosh(math.abs((1-xy)/(nx*ny)))
end

function gradx_distE(x,y,grad,work)
    blas.copy(x,grad)
    blas.axpy(-1,y,grad)
    blas.scal(1/distE(x,y,work),grad)
end

function gradx_distH(x,y,grad,work)
    local del=deltaH(x,y,work)
    local f=2*del/math.sqrt(2*del+del*del)
    blas.copy(x,grad)
    blas.axpy(-1,y,grad)
    blas.scal(f/normE2(grad),grad)
    blas.axpy(f/(1-normE2(x)),x,grad)
end

function gradx_distBK(x,y,grad,work)
    local nx=1-normE2(x)
    local ny=1-normE2(y)
    local xy=1-blas.dot(x,y)
    local f=1/math.sqrt(math.abs(xy*xy-nx*ny))
    blas.copy(x,grad)
    blas.scal(xy/nx,grad)
    blas.axpy(-1,y,grad)
    blas.scal(f,grad)
end

function distance_matrix(pts,dist,dist_func,work)
    local N=pts:rows()
    local i,j
    for i=0,N-1 do
        dist:sym_set(i,i,0)
        for j=i+1,N-1 do
            dist:sym_set(i,j,dist_func(pts:row(i),pts:row(j),work))
        end
    end
end

function kernel_matrix_radial(N,dist,mu,kernel_func,K)
    local i,j
    for i=0,N-1 do
        for j=i,N-1 do
            K:sym_set(i,j,kernel_func(dist:sym_get(i,j)))
        end
        K:sym_set(i,i,K:sym_get(i,i)+mu)
    end
end

function kernel_matrix(pts,mu,kernel_func,K,work)
    local N=pts:rows()
    local i,j
    for i=0,N-1 do
        for j=i,N-1 do
            K:sym_set(i,j,kernel_func(pts:row(i),pts:row(j),work))
        end
        K:sym_set(i,i,K:sym_get(i,i)+mu)
    end
end

function kernel_grad_matrix_radial(pts,dist,kernel_dfunc,
    gradx_dist_func,gradKx,gradKy,work)
    local N=pts:rows()
    local i,j
    for i=0,N-1 do
        for j=0,N-1 do
            local dk=kernel_dfunc(dist:sym_get(i,j))
            local x=pts:row(i)
            local y=pts:row(j)
            local gx=gradKx:row(i,j)
            local gy=gradKy:row(i,j)
            gradx_dist_func(x,y,gx,work)
            gradx_dist_func(y,x,gy,work)
            blas.scal(dk,gx)
            blas.scal(dk,gy)
        end
    end
end

function kernel_grad_matrix(pts,K,
    grad_kernel_func,gradKx,gradKy,work)
    local N=pts:rows()
    local i,j
    for i=0,N-1 do
        for j=0,N-1 do
            local vk=K:sym_get(i,j)
            local x=pts:row(i)
            local y=pts:row(j)
            local gx=gradKx:row(i,j)
            local gy=gradKy:row(i,j)
            grad_kernel_func(vk,x,y,gx,work)
            grad_kernel_func(vk,y,x,gy,work)
        end
    end
end

function S(data,env,ws)
    -- q=array.double((m+1),n,N)
    local radial=env.radial
    local q=data.q
    local m=q:depth()-1
    local n=q:height()
    local N=q:width()
    local h=1/m
    local midT=ws.midT
    local mid=ws.mid
    local dist=ws.dist
    local K=ws.K
    local workn=ws.workn
    local workN=ws.workN
    local workN2=ws.workN2

    local f=0
    for k=1,m do
        local Pk={}
        local Pk1={}
        midT:zero()
        for d=1,n do
            Pk[d]=q:row(k,d-1)
            Pk1[d]=q:row(k-1,d-1)
            local t=midT:row(d-1)
            blas.axpy(0.5,Pk[d],t)
            blas.axpy(0.5,Pk1[d],t)
        end
        midT:rearrange("021",mid)
        if radial then
            distance_matrix(mid,dist,env.dist_func,workn)
            kernel_matrix_radial(N,dist,env.mu,env.kernel_func,K)
        else
            kernel_matrix(mid,env.mu,env.kernel_func,K,workn)
            for ii=0,N-1 do for jj=0,N-1 do print(K:sym_get(ii,jj)) end end
            print("----")
        end
        lapack.pptrf(N,K)
        for d=1,n do
            blas.copy(Pk[d],workN)
            blas.axpy(-1.0,Pk1[d],workN)
            blas.copy(workN,workN2)
            lapack.pptrs(N,K,workN2)
            f=f+blas.dot(workN,workN2)
        end
    end
    return f/(2*h)
end

function gradS(data,env,ws)
    -- q=array.double((m+1),n,N)
    local radial=env.radial
    local q=data.q
    local grad=data.grad
    local m=q:depth()-1
    local n=q:height()
    local N=q:width()
    local h=1/m
    local midT=ws.midT
    local mid=ws.mid
    local dist=ws.dist
    local K=ws.K
    local gradKx=ws.gradKx
    local gradKy=ws.gradKy
    local workn=ws.workn
    local workN=ws.workN
    local A=ws.workN2
    local i,j,k,d,l
    local f=0
    grad:zero()

    for k=1,m do
        local Pk={}
        local Pk1={}
        midT:zero()
        for d=1,n do
            Pk[d]=q:row(k,d-1)
            Pk1[d]=q:row(k-1,d-1)
            local t=midT:row(d-1)
            blas.axpy(0.5,Pk[d],t)
            blas.axpy(0.5,Pk1[d],t)
        end
        midT:rearrange("021",mid)
        if radial then
            distance_matrix(mid,dist,env.dist_func,workn)
            kernel_matrix_radial(N,dist,env.mu,env.kernel_func,K)
            kernel_grad_matrix_radial(mid,dist,env.kernel_dfunc,
                env.gradx_dist_func,
                gradKx,gradKy,workn)
        else
            kernel_matrix(mid,env.mu,env.kernel_func,K,workn)
            kernel_grad_matrix(mid,K,
                env.grad_kernel_func,
                gradKx,gradKy,workn)
        end
        lapack.pptrf(N,K)
        for d=1,n do
            blas.copy(Pk[d],workN)
            blas.axpy(-1.0,Pk1[d],workN)
            blas.copy(workN,A)
            lapack.pptrs(N,K,A)
            f=f+blas.dot(workN,A)
            for i=1,N do
                local v=A:get(i-1)/h
                grad:add_to(k,d-1,i-1,v)
                grad:add_to(k-1,d-1,i-1,-v)
            end
            for i=1,N do
                local Ai=A:get(i-1)
                for j=1,N do
                    local AiAj=Ai*A:get(j-1)
                    for l=1,n do
                        local gx=gradKx:get(i-1,j-1,l-1)
                        local gy=gradKy:get(i-1,j-1,l-1)
                        grad:add_to(k,l-1,i-1,-AiAj*gx/(4*h))
                        grad:add_to(k-1,l-1,i-1,-AiAj*gx/(4*h))
                        grad:add_to(k,l-1,j-1,-AiAj*gy/(4*h))
                        grad:add_to(k-1,l-1,j-1,-AiAj*gy/(4*h))
                    end
                end
            end
        end
    end
    return f/(2*h)
end

function to_cubic(cq)
    local N=cq:depth()
    local n=cq:height()
    local i,d
    for i=0,N-1 do
        for d=0,n-1 do
            local row=cq:row(i,d)
            cubic.convert(row)
        end
    end
end

function to_natural(cq,cq2,work)
    local N=cq:depth()
    local n=cq:height()
    local i,d
    for i=0,N-1 do
        for d=0,n-1 do
            local row=cq:row(i,d)
            local row2=cq2:row(i,d)
            cubic.natural_spline(row,row2,work)
        end
    end
end

function solve_alpha(data,env,ws)
    local q=data.q
    local m=q:depth()-1
    local n=q:height()
    local N=q:width()
    local alpha=data.alpha
    local cq=data.cq
    local cq2=data.cq2
    local calpha=data.calpha
    local calpha2=data.calpha2
    local dist=ws.dist
    local K=ws.K
    local Pk=ws.mid
    local workn=ws.workn
    local workm=ws.workm
    local k,d,t
    local h=1/m

    q:rearrange("210",cq)
    --to_cubic(cq)
    to_natural(cq,cq2,workm)
    for k=0,m do
        t=h*k
        local PkT=q:plane(k)
        PkT:rearrange("021",Pk)
        if env.radial then
            distance_matrix(Pk,dist,env.dist_func,workn)
            kernel_matrix_radial(N,dist,env.mu,env.kernel_func,K)
        else
            kernel_matrix(Pk,env.mu,env.kernel_func,K,workn)
        end
        lapack.pptrf(N,K)
        for d=0,n-1 do
            local alphakd=alpha:row(k,d)
            for i=0,N-1 do
                local row=cq:row(i,d)
                local row2=cq2:row(i,d)
                --alphakd:set(i,cubic.evald(row,t))
                alphakd:set(i,cubic.natural_spline_evald(row,row2,t))
            end
            lapack.pptrs(N,K,alphakd)
        end
    end
    alpha:rearrange("210",calpha)
    --to_cubic(calpha)
    to_natural(calpha,calpha2,workm)
end

function v_norm2(t,data)
    local cq=data.cq
    local cq2=data.cq2
    local calpha=data.calpha
    local calpha2=data.calpha2
    local N=cq:depth()
    local n=cq:height()
    local result=0
    local i,d
    for i=0,N-1 do
        for d=0,n-1 do
            local cqid=cq:row(i,d)
            local cqid2=cq2:row(i,d)
            local calphaid=calpha:row(i,d)
            local calphaid2=calpha2:row(i,d)
            --result=result+cubic.evald(cqid,t)*cubic.eval(calphaid,t)
            result=result+cubic.natural_spline_evald(cqid,cqid2,t)*
                cubic.natural_spline_eval(calphaid,calphaid2,t)
        end
    end
    return result
end

function v(x,t,vxt,data,env,ws)
    local radial=env.radial
    local cq=data.cq
    local cq2=data.cq2
    local calpha=data.calpha
    local calpha2=data.calpha2
    local N=cq:depth()
    local n=cq:height()
    local qt=ws.workn
    local alphat=ws.workn2
    local workn=ws.workn3
    local i,d
    vxt:zero()
    for i=0,N-1 do
        for d=0,n-1 do
            local cqid=cq:row(i,d)
            local cqid2=cq2:row(i,d)
            local calphaid=calpha:row(i,d)
            local calphaid2=calpha2:row(i,d)
            --qt:set(d,cubic.eval(cqid,t))
            qt:set(d,cubic.natural_spline_eval(cqid,cqid2,t))
            --alphat:set(d,cubic.eval(calphaid,t))
            alphat:set(d,cubic.natural_spline_eval(calphaid,calphaid2,t))
        end
        if radial then
            local dist=env.dist_func(x,qt,workn)
            blas.axpy(env.kernel_func(dist),alphat,vxt)
        else
            blas.axpy(env.kernel_func(x,qt,workn),alphat,vxt)
        end
    end
end

function alloc_workspace(n,N,m)
    local ws={
        workn=array.double(n),
        workn2=array.double(n),
        workn3=array.double(n),
        workN=array.double(N),
        workN2=array.double(N),
        workm=array.double(m+1),
        midT=array.double(n,N),
        mid=array.double(N,n),
        dist=array.double(N*(N+1)/2),
        K=array.double(N*(N+1)/2),
        gradKx=array.double(N,N,n),
        gradKy=array.double(N,N,n)
    }
    return ws
end

function alloc_data(n,N,m)
    local data={
        q=array.double(m+1,n,N),
        alpha=array.double(m+1,n,N),
        cq=array.double(N,n,m+1),
        cq2=array.double(N,n,m+1),
        calpha=array.double(N,n,m+1),
        calpha2=array.double(N,n,m+1),
        grad=array.double(m+1,n,N),
        src=array.double(N,n),
        dst=array.double(N,n)
    }
    return data
end

function clamped_thin_plate_spline(mu)
    local env={
        kernel_func=function(x,y,work)
            local r2=distE2(x,y,work)
            local nx=1-normE2(x)
            local ny=1-normE2(y)
            if r2>0 then
                return nx*ny/2-r2/2*math.log(math.abs(nx*ny/r2+1))
            else
                return nx*ny/2
            end
        end,
        grad_kernel_func=function(vk,x,y,gradx,work)
            local r2=distE2(x,y,work)
            if r2>0 then
                local nx=1-normE2(x)
                local ny=1-normE2(y)
                blas.copy(x,gradx)
                blas.axpy(-1,y,gradx)
                local f=1/(nx*ny+r2)
                local f1=-math.log(math.abs(nx*ny/r2+1))+f*nx*ny
                blas.scal(f1,gradx)
                f1=ny/2+r2*ny*f
                blas.axpy(f1,x,gradx)
            else
                local ny=1-normE2(y)
                blas.copy(x,gradx)
                blas.scal(0.5*ny,gradx)
            end
        end,
        in_domain=function(x) return normE2(x)<1 end,
        radial=false,
        mu=mu
    }
    return env
end

function euclidean_heat_kernel(tau,mu,n)
    local env={
        dist_func=distE,
        kernel_func=function(r)
            return 1/(4*math.pi*tau)^(n/2)*math.exp(-r*r/(4*tau))
        end,
        kernel_dfunc=function(r)
            return -2*r/((4*tau)*(4*math.pi*tau)^(n/2))*math.exp(-r*r/(4*tau))
        end,
        in_domain=function(x) return true end,
        gradx_dist_func=gradx_distE,
        radial=true,
        mu=mu
    }
    return env
end

function shifted_laplacian(tau,mu)
    local env={
        dist_func=distE,
        kernel_func=function(r)
            return (1+r/tau)*math.exp(-r/tau)
        end,
        kernel_dfunc=function(r)
            return -r/(tau*tau)*math.exp(-r/tau)
        end,
        in_domain=function(x) return true end,
        gradx_dist_func=gradx_distE,
        radial=true,
        mu=mu
    }
    return env
end

function hyperbolic_shifted_laplacian(tau,mu)
    local env={
        dist_func=distH,
        kernel_func=function(r)
            return (1+r/tau)*math.exp(-r/tau)
        end,
        kernel_dfunc=function(r)
            return -r/(tau*tau)*math.exp(-r/tau)
        end,
        in_domain=function(x) return normE2(x)<1 end,
        gradx_dist_func=gradx_distH,
        radial=true,
        mu=mu
    }
    return env
end

function euclidean_radial_characteristics(tau,beta,mu)
    --beta>=(n+1)/2
    local env={
        dist_func=distE,
        kernel_func=function(r)
            if r<tau then
                return (1-r*r/tau*tau)^beta
            else
                return 0
            end
        end,
        kernel_dfunc=function(r)
            if r<tau then
                local v=-2*r*beta/(tau*tau)*(1-r*r/tau*tau)^(beta-1)
                return v
            else
                return 0
            end
        end,
        in_domain=function(x) return true end,
        gradx_dist_func=gradx_distE,
        radial=true,
        mu=mu
    }
    return env
end

function hyperbolic_radial_characteristics(tau,beta,mu)
    --beta>=(n+1)/2
    local env={
        dist_func=distH,
        kernel_func=function(r)
            if r<tau then
                return (1-r*r/tau*tau)^beta
            else
                return 0
            end
        end,
        kernel_dfunc=function(r)
            if r<tau then
                local v=-2*r*beta/(tau*tau)*(1-r*r/tau*tau)^(beta-1)
                return v
            else
                return 0
            end
        end,
        in_domain=function(x) return normE2(x)<1 end,
        gradx_dist_func=gradx_distH,
        radial=true,
        mu=mu
    }
    return env
end

function euclidean_inverse_multiquadrics(tau,mu)
    local env={
        dist_func=distE,
        kernel_func=function(r)
            return 1/math.sqrt(r*r+tau*tau)
        end,
        kernel_dfunc=function(r)
            return -r/math.sqrt(r*r+tau*tau)^3
        end,
        in_domain=function(x) return true end,
        gradx_dist_func=gradx_distE,
        radial=true,
        mu=mu
    }
    return env
end

function hyperbolic_inverse_multiquadrics(tau,mu)
    local env={
        dist_func=distH,
        kernel_func=function(r)
            return 1/math.sqrt(r*r+tau*tau)
        end,
        kernel_dfunc=function(r)
            return -r/math.sqrt(r*r+tau*tau)^3
        end,
        in_domain=function(x) return normE2(x)<1 end,
        gradx_dist_func=gradx_distH,
        radial=true,
        mu=mu
    }
    return env
end

function hyperbolic_gaussian(tau,mu,n)
    local env={
        dist_func=distH,
        kernel_func=function(r)
            return 1/(4*math.pi*tau)^(n/2)*math.exp(-r*r/(4*tau))
        end,
        kernel_dfunc=function(r)
            return -2*r/((4*tau)*(4*math.pi*tau)^(n/2))*math.exp(-r*r/(4*tau))
        end,
        in_domain=function(x) return normE2(x)<1 end,
        gradx_dist_func=gradx_distH,
        radial=true,
        mu=mu
    }
    return env
end

function euclidean_heat_kernel_lut(tau,mu,n,step,max_lut_size)

    local buf=array.double(max_lut_size)
    local i=0
    local rho=0
    repeat
        local result= 1/(4*math.pi*tau)^(n/2)*math.exp(-rho*rho/(4*tau))
        buf:set(i,result)
        i=i+1
        rho=rho+step
    until result<1e-10 or i==max_lut_size
    rho=rho-step
    print(rho,i)
    local lut=array.double(i)
    blas.copy(i,buf,lut)
    cubic.convert(lut)

    local env={
        dist_func=distE,
        kernel_func=function(r)
            if r>rho then
                return 0
            else
                return cubic.eval(lut,r/rho)
            end
        end,
        kernel_dfunc=function(r)
            if r>rho then
                return 0
            else
                return 1/rho*cubic.evald(lut,r/rho)
            end
        end,
        in_domain=function(x) return normE2(x)<1 end,
        gradx_dist_func=gradx_distE,
        radial=true,
        mu=mu,
        lut=lut,
        max_r=rho
    }
    return env
end

function hyperbolic_heat_kernel(tau,mu,step,max_lut_size)

    function f(r)
        return
        function(s)
            return math.sqrt(2)*math.exp(-tau/4)/(4*math.pi*tau)^(3/2)*
            s*math.exp(-s^2/(4*tau))/math.sqrt(math.cosh(s)-math.cosh(r))
        end
    end

    local buf=array.double(max_lut_size)
    local i=0
    local rho=0
    repeat
        local result=gsl.integrate {f=f(rho),a=rho,algorithm="qagiu"}
        buf:set(i,result)
        i=i+1
        rho=rho+step
    until result<1e-10 or i==max_lut_size
    rho=rho-step
    print(rho,i)
    local lut=array.double(i)
    blas.copy(i,buf,lut)
    cubic.convert(lut)

    local env={
        dist_func=distH,
        kernel_func=function(r)
            if r>rho then
                return 0
            else
                return cubic.eval(lut,r/rho)
            end
        end,
        kernel_dfunc=function(r)
            if r>rho then
                return 0
            else
                return 1/rho*cubic.evald(lut,r/rho)
            end
        end,
        in_domain=function(x) return normE2(x)<1 end,
        gradx_dist_func=gradx_distH,
        radial=true,
        mu=mu,
        lut=lut,
        max_r=rho
    }
    return env
end

function hyperbolicBK_heat_kernel(tau,mu,step,max_lut_size)

    function f(r)
        return
        function(s)
            return math.sqrt(2)*math.exp(-tau/4)/(4*math.pi*tau)^(3/2)*
            s*math.exp(-s^2/(4*tau))/math.sqrt(math.cosh(s)-math.cosh(r))
        end
    end

    local buf=array.double(max_lut_size)
    local i=0
    local rho=0
    repeat
        local result=gsl.integrate {f=f(rho),a=rho,algorithm="qagiu"}
        buf:set(i,result)
        i=i+1
        rho=rho+step
    until result<1e-10 or i==max_lut_size
    rho=rho-step
    print(rho,i)
    local lut=array.double(i)
    blas.copy(i,buf,lut)
    cubic.convert(lut)

    local env={
        dist_func=distBK,
        kernel_func=function(r)
            if r>rho then
                return 0
            else
                return cubic.eval(lut,r/rho)
            end
        end,
        kernel_dfunc=function(r)
            if r>rho then
                return 0
            else
                return 1/rho*cubic.evald(lut,r/rho)
            end
        end,
        in_domain=function(x) return normE2(x)<1 end,
        gradx_dist_func=gradx_distBK,
        radial=true,
        mu=mu,
        lut=lut,
        max_r=rho
    }
    return env
end

function alloc_solver(data,env,ws)
    local l=20
    local q=data.q
    local grad=data.grad
    local m=q:depth()-1
    local n=q:height()
    local N=q:width()
    local opt=lbfgsb.lbfgsb((m-1)*n*N,l)
    opt:n_set((m-1)*n*N)
    opt:m_set(l)
    opt:factr_set(100000)
    opt:pgtol_set(0.0005)
    opt:print_set(true)
    opt:grad_set(grad:data(1,0,0))
    local solver={
        q=q,
        grad=grad,
        opt=opt,
        task="start",
        iterate=function(self)
            if self.task=="start" then
                self.task=opt:start(q:data(1,0,0))
            elseif self.task=="fg" then
                opt:f_set(gradS(data,env,ws))
                self.task=opt:call()
            elseif self.task=="new_x" then
                self.task=opt:call()
            end
        end
    }
    return solver
end

function init_data(data,pts0,pts1)
    local q=data.q
    local m=q:depth()-1
    local n=q:height()
    local N=q:width()
    local src=data.src
    local dst=data.dst
    local k,d,i
    for i=0,N-1 do
        for d=0,n-1 do
            src:set(i,d,pts0[i+1][d+1])
            dst:set(i,d,pts1[i+1][d+1])
        end
    end
    for k=0,m do
        local t=k/m
        for d=0,n-1 do
            for i=0,N-1 do
                q:set(k,d,i,(1-t)*pts0[i+1][d+1]+t*pts1[i+1][d+1])
            end
        end
    end
end

--[[
m=100
n=2
N=3

data=alloc_data(n,N,m)
init_data(data,
    {{-0.5,0.0},{0.0,-0.5},{0.1,0.0}},
    {{0.0,0.4},{-0.4,0.1},{0.3,0.0}} )

env=hyperbolic_heat_kernel(1,0.05,0.001,16536)
--env=euclidean_heat_kernel_lut(1,0.05,n,0.001,16536)
--env=euclidean_heat_kernel(1,0.05,n)
ws=alloc_workspace(N,n)
solver=alloc_solver(data,env,ws)
repeat
    solver:iterate()
until solver.task=="conv"
solve_alpha(data,env,ws)
]]


