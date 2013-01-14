require("array")
require("gsl")
require("ginac")

local function cat(...)
    local t = {}
    for n = 1,select("#",...) do
        local arg = select(n,...)
        if type(arg)=="table" then
            for _,v in ipairs(arg) do
                t[#t+1] = v
            end
        else
            t[#t+1] = arg
        end
    end
    return t
end

local function midpoint(Ld,qs,dot_qs,q0,q1,h)
    local dof=#qs
    local repl={}
    for i=1,dof do
        repl[qs[i]:tostring()]=(q0[i]+q1[i])/2
        repl[dot_qs[i]:tostring()]=(q1[i]-q0[i])/h
    end
    Ld=(Ld:subs(repl))*h
    return Ld
end

local function trapezoidal(Ld,qs,dot_qs,q0,q1,h)
    local dof=#qs
    local repl0={}
    local repl1={}
    local repld={}
    for i=1,dof do
        repl0[qs[i]:tostring()]=q0[i]
        repl1[qs[i]:tostring()]=q1[i]
        repld[dot_qs[i]:tostring()]=(q1[i]-q0[i])/h
    end
    Ld=(Ld:subs(repl0)+Ld:subs(repl1))*h/2
    Ld=Ld:subs(repld)
    return Ld
end

function iteration_map(L, qs, dot_qs, dt, consts)
    local dof=#qs
    local Ld
    if consts then Ld=L:subs(consts) end
    local h=ginac.symbol("h")
    local q0={}
    local q1={}
    local p0={}
    for i=1,dof do
        q0[i]=ginac.symbol("q0"..i)
        q1[i]=ginac.symbol("q1"..i)
        p0[i]=ginac.symbol("p0"..i)
    end
    --  Ld=midpoint(Ld,qs,dot_qs,q0,q1,h)
    Ld=trapezoidal(Ld,qs,dot_qs,q0,q1,h)
    Ld=Ld:subs {h=dt}
    local eq0={}
    local eq1={}
    for i=1,dof do
        eq0[i]=p0[i]+Ld:diff(q0[i])
        eq1[i]=Ld:diff(q1[i])
    end
    local f=ginac.compile(eq0,cat(q0,q1,p0))
    local Jac={}
    for i=1,dof do
        for j=1,dof do
            Jac[#Jac+1]=eq0[i]:diff(q1[j])
        end
    end
    local Jf=ginac.compile(Jac,cat(q0,q1,p0))
    local g=ginac.compile(eq1,cat(q0,q1))

    local temp=array.double(3*dof)
    local M=
    function(v,w)
        temp:copy(v,dof)
        f(temp,w)
    end
    local JM=
    function(v,j)
        temp:copy(v,dof)
        Jf(temp,j)
    end
    local tq1=array.double(dof)
    return
    function(q0,p0) 
        tq1:copy(q0)
        temp:copy(q0)
        temp:copy(p0,2*dof)
        gsl.solve {
            f=M,
            df=JM,
            algorithm="hybridsj",
            starting_point=tq1 ,
            show_iterations=false
        }
        temp:copy(tq1,dof)
        g(temp,p0)
        q0:copy(tq1)
    end
end

