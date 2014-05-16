require("vec")

csg={}

local default={
	radius=1.0,
	density=100,
	center=vec.new {0,0,0},
	normal=vec.new {0,0,1},
	eps=0.000001,
	side=1.0,
	from=vec.new {0,0,0},
	to=vec.new {0,0,1}
}

function csg.defaults(pars)
	for k,v in pairs(pars) do
		default[k]=pars[k]
	end
end

function math.round(num) 
    if num >= 0 then
    	return math.floor(num+.5) 
    else 
    	return math.ceil(num-.5)
   	end
end

function csg.sphere(pars)
	local radius=pars.radius or default.radius
	local density=pars.density or default.density
	local center
	if pars.center then 
		center=vec.new(pars.center)
	else
		center=default.center
	end
	local eps=pars.eps or default.eps
	local t={}
	t.classify=function(p)
		local v=vec.norm(p-center)-radius
		if math.abs(v)<eps then
			return 0
		else 
			return v
		end 
	end
	--http://www.cmu.edu/biolphys/deserno/pdf/sphere_equi.pdf
	t.points=function() return coroutine.wrap(
		function()
			local a=1.0/density
			local d=math.sqrt(a)
			local Mtheta=math.round(math.pi/d)
			local dtheta=math.pi/Mtheta
			local dphi=a/dtheta
			for m=0,Mtheta-1 do
				local theta=math.pi*(m+0.5)/Mtheta
				local Mphi=math.round(2*math.pi*math.sin(theta)/dphi)
				for n=0,Mphi-1 do
					local phi=2*math.pi*n/Mphi
					local p=vec.new {0,0,0}
					p[1]=center[1]+radius*math.sin(theta)*math.cos(phi)
					p[2]=center[2]+radius*math.sin(theta)*math.sin(phi)
					p[3]=center[3]+radius*math.cos(theta)
					coroutine.yield(p) 
				end
			end
			return nil
		end
	) end
	return t
end

function csg.intersection(pars)
	local t={}
	t.classify=function(p)
		local max=-math.huge
		for i=1,#pars do
			max=math.max(max,pars[i].classify(p))
		end
		return max
	end
	t.points=function() return coroutine.wrap(
		function()
			for i=1,#pars do
				for p in pars[i].points() do
					if t.classify(p)==0 then 
						coroutine.yield(p)
					end
				end
			end 
			return nil
		end
	) end
	return t
end

function csg.union(pars)
	local t={}
	t.classify=function(p)
		local min=math.huge
		for i=1,#pars do
			min=math.min(min,pars[i].classify(p))
		end
		return min
	end
	t.points=function() return coroutine.wrap(
		function()
			for i=1,#pars do
				for p in pars[i].points() do
					if t.classify(p)==0 then 
						coroutine.yield(p)
					end
				end
			end 
			return nil
		end
	) end
	return t
end

function csg.difference(pars)
	local t={}
	t.classify=function(p)
		local c1=pars[1].classify(p)
		local c2=pars[2].classify(p)
		if c1==0 and c2==0 then
			return default.eps
		end
		return math.max(c1,-c2)
	end
	t.points=function() return coroutine.wrap(
		function()
			for i=1,2 do
				for p in pars[i].points() do
					if t.classify(p)==0 then 
						coroutine.yield(p)
					end
				end
			end 
			return nil
		end
	) end
	return t
end

function csg.plane(pars)
	local t={}
	local center
	if pars.center then 
		center=vec.new(pars.center)
	else
		center=default.center
	end
	local normal
	if pars.normal then 
		normal=vec.new(pars.normal)
	else
		normal=default.normal
	end
	local density=pars.density or default.density
	local eps=pars.eps or default.eps
	local side=pars.side or default.side
	normal=vec.normalize(normal)
	t.classify=function(p)
		local v=vec.dot(normal,p-center)
		if math.abs(v)<eps then
			return 0
		else 
			return v
		end 
	end
	t.points= function() return coroutine.wrap(
		function()
			local a=1.0/density
			local d=math.sqrt(a)
			local M=math.floor(side/d)
			local delta=(side-M*d)/2
			local j=vec.new {0,1,0}
			local u=vec.cross(normal,j)
			if vec.norm2(u)<0.0001 then
				local i=vec.new {1,0,0}
				u=vec.cross(normal,i)
			end
			u=vec.normalize(u)
			local v=vec.cross(normal,u)
			for x=-side/2+delta,side/2,d do
				for y=-side/d+delta,side/2,d do
					local p=center+x*u+y*v
					coroutine.yield(p)
				end
			end
			return nil
		end
	) end
	return t
end

function csg.translate(pars)
	local t={}
	local dir=vec.new(pars.dir)
	t.classify=function(p)
		return pars[1].classify(p-dir)
	end
	t.points=function() return coroutine.wrap(
		function()
			for p in pars[1].points() do
				coroutine.yield(p+dir)
			end 
			return nil
		end
	) end
	return t
end

function csg.scale(pars)
	local t={}
	local ratio=pars.ratio
	t.classify=function(p)
		return pars[1].classify((1/ratio)*p)
	end
	t.points=function() return coroutine.wrap(
		function()
			for p in pars[1].points() do
				coroutine.yield(ratio*p)
			end 
			return nil
		end
	) end
	return t
end

function csg.box(pars)
	local height=pars.height
	local length=pars.length
	local depth=pars.depth
	local max=math.max(height,length,depth)*1.1
	return csg.intersection {
		csg.plane { center={length/2,0,0}, normal={1,0,0}, side=max },
		csg.plane { center={-length/2,0,0}, normal={-1,0,0}, side=max },
		csg.plane { center={0,height/2,0}, normal={0,1,0}, side=max },
		csg.plane { center={0,-height/2,0}, normal={0,-1,0}, side=max },
		csg.plane { center={0,0,depth/2}, normal={0,0,1}, side=max },
		csg.plane { center={0,0,-depth/2}, normal={0,0,-1}, side=max },
	}	
end

function csg.cylinder(pars)
	local t={}
	local from
	if pars.from then 
		from=vec.new(pars.from)
	else
		from=default.from
	end
	local to
	if pars.to then 
		to=vec.new(pars.to)
	else
		to=default.to
	end
	local radius=pars.radius or default.radius
	local density=pars.density or default.density
	local eps=pars.eps or default.eps
	local axis=to-from
	local side=vec.norm(axis)
	axis=(1/side)*axis
	t.classify=function(p)
		local v=math.sqrt(vec.norm2(p-from)-vec.dot(axis,p-from)^2)-radius
		if math.abs(v)<eps then
			return 0
		else 
			return v
		end 
	end
	t.points= function() return coroutine.wrap(
		function()
			local a=1.0/density
			local d=math.sqrt(a)
			local delta=(side % d)/2
			local delta2=(2*math.pi*radius % d)/2
			local j=vec.new {0,1,0}
			local u=vec.cross(axis,j)
			if vec.norm2(u)<0.0001 then
				local i=vec.new {1,0,0}
				u=vec.cross(axis,i)
			end
			u=vec.normalize(u)
			local v=vec.cross(axis,u)
			for z=delta,side,d do
				for l=0+delta2,2*math.pi*radius,d do
					local p=from+z*axis+radius*math.cos(l/radius)*u+
						radius*math.sin(l/radius)*v
					coroutine.yield(p)
				end
			end
			return nil
		end
	) end
	return csg.intersection {
	 	t,
	 	csg.plane { center=from, normal=-axis },
	 	csg.plane { center=to, normal=axis },
	}
end 

function csg.stats(pars)
	local xmin=math.huge
	local xmax=-math.huge
	local ymin=math.huge
	local ymax=-math.huge
	local zmin=math.huge
	local zmax=-math.huge
	local npoints=0
	local xmean=0
	local ymean=0
	local zmean=0	
	for p in pars.points() do
		xmin=math.min(xmin,p[1])
		xmax=math.max(xmax,p[1])
		ymin=math.min(ymin,p[2])
		ymax=math.max(ymax,p[2])
		zmin=math.min(zmin,p[3])
		zmax=math.max(zmax,p[3])
		npoints=npoints+1
		xmean=xmean+p[1]
		ymean=ymean+p[2]
		zmean=zmean+p[3]
	end
	xmean=xmean/npoints
	ymean=ymean/npoints
	zmean=zmean/npoints
	length=xmax-xmin
	height=ymax-ymin
	depth=zmax-zmin
	return {
		xmax=xmax,
		ymax=ymax,
		zmax=zmax,
		xmin=xmin,
		ymin=ymin,
		zmin=zmin,
		length=length,
		height=height,
		depth=depth,
		npoints=npoints,
		size=math.max(length,height,depth),
		center=vec.new {(xmax+xmin)/2,(ymax+ymin)/2,(zmax+zmin)/2},
		barycenter=vec.new {xmean,ymean,zmean}
	}
end


return csg
