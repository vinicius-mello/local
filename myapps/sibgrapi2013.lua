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
    return 2*distE2(x,y,work)/((1-normE2(x))*(1-normE2(y)))
end

function distH(x,y,work)
    return math.acosh(1+deltaH(x,y,work))
end

function gradx_distE(x,y,grad,work)
    blas.copy(x,grad)
    blas.axpy(-1,y,grad)
    blas.scal(1/distE(x,y,work),grad)
end

function grady_distE(x,y,grad,work)
    blas.copy(y,grad)
    blas.axpy(-1,x,grad)
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

function grady_distH(x,y,grad,work)
    local del=deltaH(x,y,work)
    local f=2*del/math.sqrt(2*del+del*del)
    blas.copy(y,grad)
    blas.axpy(-1,x,grad)
    blas.scal(f/normE2(grad),grad)
    blas.axpy(f/(1-normE2(y)),y,grad)
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

function kernel_matrix(N,dist,mu,kernel_func,K)
    local i,j
    for i=0,N-1 do
        for j=i,N-1 do
            K:sym_set(i,j,kernel_func(dist:sym_get(i,j)))
        end
        K:sym_set(i,i,K:sym_get(i,i)+mu)
    end
end

function kernel_grad_matrix(pts,dist,kernel_dfunc,
    gradx_dist_func, grady_dist_func,gradKx,gradKy,work)
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
            grady_dist_func(x,y,gy,work)
            blas.scal(dk,gx)
            blas.scal(dk,gy)
        end
    end
end

function S(q,env,ws)
    -- q=array.double((m+1),n,N)
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
        distance_matrix(mid,dist,env.dist_func,workn)
        kernel_matrix(N,dist,env.mu,env.kernel_func,K)
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

function gradS(q,env,grad,ws)
    -- q=array.double((m+1),n,N)
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
        distance_matrix(mid,dist,env.dist_func,workn)
        kernel_matrix(N,dist,env.mu,env.kernel_func,K)
        kernel_grad_matrix(mid,dist,env.kernel_dfunc,
            env.gradx_dist_func, env.grady_dist_func,
            gradKx,gradKy,workn)
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

function alloc_workspace(N,n)
    local ws={
        workn=array.double(n),
        workN=array.double(N),
        workN2=array.double(N),
        midT=array.double(n,N),
        mid=array.double(N,n),
        dist=array.double(N*(N+1)/2),
        K=array.double(N*(N+1)/2),
        gradKx=array.double(N,N,n),
        gradKy=array.double(N,N,n),
    }
    return ws
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
        gradx_dist_func=gradx_distE,
        grady_dist_func=grady_distE,
        mu=mu,
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
    lut:copy(buf)
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
        gradx_dist_func=gradx_distH,
        grady_dist_func=grady_distH,
        mu=mu,
        lut=lut,
        max_r=rho
    }
    return env
end

function gen_q(pts0, pts1, m)
    local n=#pts0[1]
    local N=#pts0
    local q=array.double((m+1),n,N)
    local src=array.double(N,n)
    local dst=array.double(N,n)
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
    return q,src,dst
end

m=100
q,src,dst=gen_q(
    {{-0.5,0.0},{0.0,-0.5},{0.1,0.0}},
    {{0.0,0.4},{-0.4,0.1},{0.3,0.0}},
    m)
n=q:height()
N=q:width()

env=hyperbolic_heat_kernel(1,0.05,0.001,16536)
eps=0.00000001
print((env.kernel_func(0.001+eps)-env.kernel_func(0.001))/eps)
print(env.kernel_dfunc(0.001))

--env=euclidean_heat_kernel(1,0.05,n)
ws=alloc_workspace(N,n)
grad=array.double(m+1,n,N)

f=gradS(q,env,grad,ws)
print(f)



