require("array")
require("gsl")

function vec(t)
    local m=#t
    local a=array.double(m)
    for i=1,m do
        a:set(i-1,t[i])
    end
    return a
end

function f(a)
    local x=a:get(0)
    local y=a:get(1)
    return 10 * (x - 1) * (x - 1) + 20 * (y - 2) * (y - 2) + 30
end

function df(a,g)
    local x=a:get(0)
    local y=a:get(1)
    g:set(0,20*(x-1))
    g:set(1,40*(y-2))
end

local x=vec {5,7}

gsl.minimize {
    f=f,
    eps=0.00001,
    maxiter=500,
    starting_point=x ,
    algorithm="nmsimplex2",
    --    step_sizes=1,
    show_iterations=true
}

print(x:get(0),x:get(1))

local x=vec {5,7}

gsl.minimize {
    f=f,
    df=df,
    eps=0.00001,
    maxiter=500,
    starting_point=x ,
    algorithm="vector_bfgs",
    show_iterations=true
}

print(x:get(0),x:get(1))


function rosenbrock(v,w)
    local x=v:get(0)
    local y=v:get(1)
    w:set(0,1-x)
    w:set(1,10*(y-x*x))
end

local x=vec {-10,-5}

gsl.solve {
    f=rosenbrock,
    algorithm="dnewton",
    starting_point=x ,
    show_iterations=true
}

print(x:get(0),x:get(1))

function rosenbrock_df(v,j)
    local x=v:get(0)
    local y=v:get(1)
    j:set(0,0,-1)
    j:set(0,1,0)
    j:set(1,0,-20*x)
    j:set(1,1,10)
end

local x=vec {-10,-5}
gsl.solve {
    f=rosenbrock,
    df=rosenbrock_df,
    algorithm="gnewton",
    starting_point=x ,
    show_iterations=true
}

print(x:get(0),x:get(1))

function int_f(s)
    return s*math.exp(-s*s/4)/math.sqrt(math.cosh(s)-math.cosh(2))
end

result,abserr=gsl.integrate {
    f=int_f,
    a=2,
    b=100,
    algorithm="cquad"
}

print(result,abserr)

a=vec {0,0,0,0,1,0,0,0}
haar=gsl.dwt(gsl.haar,2)
haar:inverse(a)
for i=0,7 do print(a:get(i)) end

b=vec {1,2,3,4,5,6,7,8}
a=vec {0,0,0,0,0,0,0,0}
dct8=gsl.dct(8)
dct8:forward(b,a)
for i=0,7 do print(a:get(i)) end

