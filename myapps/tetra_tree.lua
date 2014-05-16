dofile("modules.lua")
require("array")
require("lpt")
require("interval")

tetra_tree={}

function tetra_tree.new()
	local t={}
	t._tree=lpt.lpt3d_tree()
	t._vid={}
	t._vid_size=0
	t._vertices=array.double(1024,3)
	t._vert=array.double(4,3)
	t._pnt=array.double(3)
	t._tree:node_reset()
	setmetatable(t,tetra_tree)
	repeat
    	local c=t._tree:node_code()
    	t:process_vertices(c)
  	until not t._tree:node_next()	
	return t
end

function tetra_tree:process_vertices(c)
	c:simplex(self._vert:data())
  	for i=0,3 do 
    	local x=self._vert:get(i,0)
    	local y=self._vert:get(i,1)
    	local z=self._vert:get(i,2)
    	local vc=lpt.morton3_10(x,y,z)
    	if self._vid[vc]==nil then
      		self._vid[vc]=self._vid_size
      		self._vertices:set(self._vid_size,0,x)
      		self._vertices:set(self._vid_size,1,y)
      		self._vertices:set(self._vid_size,2,z)
      		self:inc_vid_size()
    	end
  	end    
end

function tetra_tree:inc_vid_size()
	local h=self._vertices:height()
	if self._vid_size==(h-1) then
		local temp=array.double(2*h,3)
		temp:copy(self._vertices)
		self._vertices=temp
	end
	self._vid_size=self._vid_size+1
end

function tetra_tree:is_leaf(c)
	return self._tree:is_leaf(c)
end

function tetra_tree:split(c)
	self._tree:compat_bisect(c)
    local recent={}
    repeat 
      local rc=self._tree:recent_code()
      self:process_vertices(rc)
      recent[#recent+1]=rc
    until not self._tree:recent_next()
    return recent
end

function tetra_tree:vertices(c)
	c:simplex(self._vert:data())
  	local vids={}
  	local xs={}
  	local ys={}
  	local zs={}
  	for i=1,4 do    		
  		xs[i]=self._vert:get(i-1,0)
    	ys[i]=self._vert:get(i-1,1)
    	zs[i]=self._vert:get(i-1,2)
    	local vc=lpt.morton3_10(xs[i],ys[i],zs[i])
    	vids[i]=self._vid[vc]    	
  	end
  	if c:orientation()<0 then
  		xs[3],xs[4]=xs[4],xs[3]
  		ys[3],ys[4]=ys[4],ys[3]
  		zs[3],zs[4]=zs[4],zs[3]
  		vids[3],vids[4]=vids[4],vids[3] 		
  	end
  	return vids,xs,ys,zs
end

function tetra_tree:points(c)
	c:simplex(self._vert:data())
  	local vids={}
  	local xs={}
  	local ys={}
  	local zs={}
  	for i=1,4 do    		
  		xs[i]=self._vert:get(i-1,0)
    	ys[i]=self._vert:get(i-1,1)
    	zs[i]=self._vert:get(i-1,2)
    	local vc=lpt.morton3_10(xs[i],ys[i],zs[i])
    	vids[i]=self._vid[vc]    	
    	xs[i]=self._vertices:get(vids[i],0)
    	ys[i]=self._vertices:get(vids[i],1)
    	zs[i]=self._vertices:get(vids[i],2)
  	end
  	if c:orientation()<0 then
  		xs[3],xs[4]=xs[4],xs[3]
  		ys[3],ys[4]=ys[4],ys[3]
  		zs[3],zs[4]=zs[4],zs[3]
  		vids[3],vids[4]=vids[4],vids[3] 		
  	end
  	return vids,xs,ys,zs
end

function tetra_tree:leafs()
	return coroutine.wrap( function ()
		self._tree:node_reset()
		repeat 
    		if self._tree:node_is_leaf() then
	    		local c=self._tree:node_code()
      			coroutine.yield(c)
  			end
  		until not self._tree:node_next()
  	end)
end

function tetra_tree:set(x,y,z,xd,yd,zd)
	local vc=lpt.morton3_10(x,y,z)
    self._vertices:set(self._vid[vc],0,xd)
    self._vertices:set(self._vid[vc],1,yd) 
	self._vertices:set(self._vid[vc],2,zd) 
end

function tetra_tree:cells(x,y,z)
	self._pnt:set(0,x)
	self._pnt:set(1,y)	
	self._pnt:set(2,z)	
	self._tree:search_all(self._pnt:data())
	local recent={}
	repeat 
      local rc=self._tree:recent_code()      
      recent[#recent+1]=rc
    until not self._tree:recent_next()
    return recent
end

function tetra_tree:bounding_box(c) 
  c:simplex(self._vert:data())
  local max_x=-math.huge
  local min_x=math.huge
  local max_y=-math.huge
  local min_y=math.huge
  local max_z=-math.huge
  local min_z=math.huge
  for i=0,3 do 
    max_x=math.max(max_x,self._vert:get(i,0))
    min_x=math.min(min_x,self._vert:get(i,0))
    max_y=math.max(max_y,self._vert:get(i,1))
    min_y=math.min(min_y,self._vert:get(i,1))
    max_z=math.max(max_z,self._vert:get(i,2))
    min_z=math.min(min_z,self._vert:get(i,2))
  end
  return interval.new(min_x,max_x),interval.new(min_y,max_y),interval.new(min_z,max_z)
end

tetra_tree.__index=tetra_tree

return tetra_tree