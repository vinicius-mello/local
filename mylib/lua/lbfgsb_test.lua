require("array")
require("lbfgsb")

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
local grad=vec {0,0}

local opt=lbfgsb.lbfgsb(5,5)
opt:n_set(2)
opt:m_set(2)
opt:grad_set(grad:data())
task=opt:start(x:data())
repeat 
  if task=="fg" then
		opt:f_set(f(x))
		df(x,grad)
  elseif task=="new_x" then
		print("new_x")
  elseif task=="error" then
		print("error")
		break
  elseif task=="abno" then
		print("abno")
		break
  end
	task=opt:call()
until task=="conv"
print(task)

print(x:get(0),x:get(1))


