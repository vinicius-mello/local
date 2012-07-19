function bissect(f,ta,tb,eps,roots)
  local tm=(ta+tb)/2
  if tb-ta<eps then
	append(roots,tm)
  else
	local sa=f(ta)
	local sb=f(tb)
	local sm=f(tm)
	if sa*sm<0 then
	  bissect(f,ta,tm,eps,roots)
	end
	if sm*sb<0 then
	  bissect(f,tm,tb,eps,roots)
	end
  end
end

function find_roots_by_bissection(n,eps)
  return
  function(f)
    local roots={}
    local ta=0
    local s=f(ta)
    for i=1,n do
      local tb=i/n
      local ns=f(tb)
	  if s*ns<0 then
	    bissect(f,ta,tb,eps,roots)
	  end
	  s=ns
	  ta=tb
    end
    return roots
  end
end

function find_min_by_sampling(n)
  return
  function(f)
    local m=math.huge
	local tm
	for i=0,n do
      local t=i/n
      local v=f(t)
	  if v<m then
	    tm=t
		m=v
	  end
    end
    return m,tm
  end
end
