dofile("modules.lua")
require("array")
require("lpt")
require("interval")

triangle_tree={}

function triangle_tree.new()
	local t={}
	t._tree=lpt.lpt2d_tree()
	t._vid={}
	t._vid_size=0
	t._vertices=array.double(1024,2)
	t._vert=array.double(3,2)
	t._pnt=array.double(2)
	t._tree:node_reset()
	setmetatable(t,triangle_tree)
	repeat
    	local c=t._tree:node_code()
    	t:process_vertices(c)
  	until not t._tree:node_next()	
	return t
end

function triangle_tree:process_vertices(c)
	c:simplex(self._vert:data())
  	for i=0,2 do 
    	local x=self._vert:get(i,0)
    	local y=self._vert:get(i,1)
    	local vc=lpt.morton2_16(x,y)
    	if self._vid[vc]==nil then
      		self._vid[vc]=self._vid_size
      		self._vertices:set(self._vid_size,0,x)
      		self._vertices:set(self._vid_size,1,y)
      		self:inc_vid_size()
    	end
  	end    
end

function triangle_tree:inc_vid_size()
	local h=self._vertices:height()
	if self._vid_size==(h-1) then
		local temp=array.double(2*h,2)
		temp:copy(self._vertices)
		self._vertices=temp
	end
	self._vid_size=self._vid_size+1
end

function triangle_tree:is_leaf(c)
	return self._tree:is_leaf(c)
end

function triangle_tree:split(c)
	self._tree:compat_bisect(c)
    local recent={}
    repeat 
      local rc=self._tree:recent_code()
      self:process_vertices(rc)
      recent[#recent+1]=rc
    until not self._tree:recent_next()
    return recent
end

function triangle_tree:vertices(c)
	c:simplex(self._vert:data())
  	local vids={}
  	local xs={}
  	local ys={}
  	for i=1,3 do    		
  		xs[i]=self._vert:get(i-1,0)
    	ys[i]=self._vert:get(i-1,1)
    	local vc=lpt.morton2_16(xs[i],ys[i])
    	vids[i]=self._vid[vc]    	
  	end
    if c:orientation()<0 then
      xs[2],xs[3]=xs[3],xs[2]
      ys[2],ys[3]=ys[3],ys[2]
      vids[2],vids[3]=vids[3],vids[2]     
    end
  	return vids,xs,ys
end

function triangle_tree:points(c)
	c:simplex(self._vert:data())
  	local vids={}
  	local xs={}
  	local ys={}
  	for i=1,3 do    		
  		xs[i]=self._vert:get(i-1,0)
    	ys[i]=self._vert:get(i-1,1)
    	local vc=lpt.morton2_16(xs[i],ys[i])
    	vids[i]=self._vid[vc]    	
    	xs[i]=self._vertices:get(vids[i],0)
    	ys[i]=self._vertices:get(vids[i],1)
  	end
    if c:orientation()<0 then
      xs[2],xs[3]=xs[3],xs[2]
      ys[2],ys[3]=ys[3],ys[2]
      vids[2],vids[3]=vids[3],vids[2]     
    end
  	return vids,xs,ys
end

function triangle_tree:leafs()
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

function triangle_tree:set(x,y,xd,yd)
	local vc=lpt.morton2_16(x,y)
    self._vertices:set(self._vid[vc],0,xd)
    self._vertices:set(self._vid[vc],1,yd) 
end

function triangle_tree:cells(x,y)
	self._pnt:set(0,x)
	self._pnt:set(1,y)	
	self._tree:search_all(self._pnt:data())
	local recent={}
	repeat 
      local rc=self._tree:recent_code()      
      recent[#recent+1]=rc
    until not self._tree:recent_next()
    return recent
end

function triangle_tree:bounding_box(c) 
  c:simplex(self._vert:data())
  local max_x=-math.huge
  local min_x=math.huge
  local max_y=-math.huge
  local min_y=math.huge
  for i=0,2 do 
    max_x=math.max(max_x,self._vert:get(i,0))
    min_x=math.min(min_x,self._vert:get(i,0))
    max_y=math.max(max_y,self._vert:get(i,1))
    min_y=math.min(min_y,self._vert:get(i,1))
  end
  return interval.new(min_x,max_x),interval.new(min_y,max_y)
end

triangle_tree.__index=triangle_tree

return triangle_tree


