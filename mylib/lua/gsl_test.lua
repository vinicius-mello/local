require("array")
require("gsl")

function vec(t) 
  local m=#t
	local a=array.array_double(m)
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
gsl.fminimize(f,
  { eps=0.00001,
    maxiter=500,
    starting_point=x ,
		algorithm="nmsimplex2rand",
    step_sizes=vec {0.5,0.5},
    show_iterations=true })

print(x:get(0),x:get(1))

local x=vec {5,7}
gsl.fdfminimize(f,df,
  { eps=0.00001,
    maxiter=500,
    starting_point=x ,
		algorithm="steepest_descent",
    show_iterations=true })

print(x:get(0),x:get(1))

function rosenbrock(v,w)
	local x=v:get(0)
	local y=v:get(1)
	w:set(0,1-x)
	w:set(1,10*(y-x*x))
end

local x=vec {-10,-5}
gsl.fsolve(rosenbrock, 
	{ algorithm="dnewton",
    starting_point=x ,
    show_iterations=true })

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
gsl.fdfsolve(rosenbrock, rosenbrock_df,
	{ algorithm="hybridsj",
    starting_point=x ,
    show_iterations=true })

print(x:get(0),x:get(1))

