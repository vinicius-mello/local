dofile("modules.lua")
require("array")
require("csg")
require("lpt")
require("stl")
vert=array.double(12)
pnt=array.double(3)

dofile(arg[1])

out=stl.create(arg[2],"lpt")

stats=csg.stats(obj)



obj= csg.scale {
  csg.translate {
    obj,
    dir=-stats.center
  },
  ratio=1/stats.size  
}

tree=lpt.lpt3d_tree()
ratio=0.1


function draw_tetra(cur,id,ratio)
    cur:simplex(vert:data())
  local a={vert:get(0),vert:get(1),vert:get(2)}
  local b={vert:get(3),vert:get(4),vert:get(5)}
  local c={vert:get(6),vert:get(7),vert:get(8)}
  local d={vert:get(9),vert:get(10),vert:get(11)}
  if cur:orientation()<0 then
    c,d=d,c
  end
  
  local ac,bc,dc=shrink(a,b,d,ratio)
  local ba,ca,da=shrink(b,c,d,ratio)
  local ad,cd,bd=shrink(a,c,b,ratio)
  local ab,db,cb=shrink(a,d,c,ratio)
  
  draw_quad(ab,db,dc,ac)
  draw_quad(ab,ad,cd,cb)
  draw_quad(ad,ac,bc,bd)
  draw_quad(bd,ba,ca,cd)
  draw_quad(ba,bc,dc,da)
  draw_quad(cb,ca,da,db)

  draw_face(ab,ac,ad)
  draw_face(ba,bd,bc)
  draw_face(ca,cb,cd)
  draw_face(da,dc,db)
end

function visible_neighbor(p)
  pnt:set(0,p[1])
  pnt:set(1,p[2])
  pnt:set(2,p[3])
  tree:search_all(pnt:data())
  repeat
    if visible[tree:recent_id()] then
      return true
    end
  until not tree:recent_next()
  return false
end

neighborhood={}
function extend_boundary(cur)
  cur:simplex(vert:data())
  local vs={}
  vs[1]={vert:get(0),vert:get(1),vert:get(2)}
  vs[2]={vert:get(3),vert:get(4),vert:get(5)}
  vs[3]={vert:get(6),vert:get(7),vert:get(8)}
  vs[4]={vert:get(9),vert:get(10),vert:get(11)}
  for i=1,4 do 
    pnt:set(0,vs[i][1])
    pnt:set(1,vs[i][2])
    pnt:set(2,vs[i][3])
    tree:search_all(pnt:data())
    repeat
      neighborhood[tree:recent_id()]=true
    until not tree:recent_next()
  end
  return
end


function close_holes(cur,id,ratio)
    cur:simplex(vert:data())
  local a=vec.new {vert:get(0),vert:get(1),vert:get(2)}
  local b=vec.new {vert:get(3),vert:get(4),vert:get(5)}
  local c=vec.new {vert:get(6),vert:get(7),vert:get(8)}
  local d=vec.new {vert:get(9),vert:get(10),vert:get(11)}
  if cur:orientation()<0 then
    c,d=d,c
  end
  
  local ac,bc,dc=shrink(a,b,d,ratio)
  local ba,ca,da=shrink(b,c,d,ratio)
  local ad,cd,bd=shrink(a,c,b,ratio)
  local ab,db,cb=shrink(a,d,c,ratio)

  local vad=visible_neighbor(0.5*(a+d))
  if vad then
    draw_quad(ac,ab,db,dc)  
  end
  local vac=visible_neighbor(0.5*(a+c))
  if vac then
    draw_quad(ab,ad,cd,cb)  
  end
  local vab=visible_neighbor(0.5*(a+b))
  if vab then
    draw_quad(ad,ac,bc,bd)  
  end
  local vbc=visible_neighbor(0.5*(b+c))
  if vbc then
    draw_quad(bd,ba,ca,cd)  
  end
  local vbd=visible_neighbor(0.5*(b+d))
  if vbd then
    draw_quad(ba,bc,dc,da)  
  end
  local vcd=visible_neighbor(0.5*(c+d))
  if vcd then
    draw_quad(cb,ca,da,db)  
  end
  if visible_neighbor(a) then
    draw_face(ab,ac,ad)
    if not vab then 
      draw_face(ad,ac,a+2*ratio*(b-a))
    end
    if not vac then 
      draw_face(ab,ad,a+2*ratio*(c-a))
    end
    if not vad then 
      draw_face(ac,ab,a+2*ratio*(d-a))
    end
  end
  if visible_neighbor(b) then
    draw_face(ba,bd,bc)
    if not vab then 
      draw_face(b+2*ratio*(a-b),bc,bd)
    end
    if not vbc then 
      draw_face(bd,ba,b+2*ratio*(c-b))
    end
    if not vbd then 
      draw_face(ba,bc,b+2*ratio*(d-b))
    end
  end
  if visible_neighbor(c) then
    draw_face(ca,cb,cd)
    if not vac then 
      draw_face(c+2*ratio*(a-c),cd,cb)
    end
    if not vbc then 
      draw_face(c+2*ratio*(b-c),ca,cd)
    end
    if not vcd then 
      draw_face(cb,ca,c+2*ratio*(d-c))
    end
  end
  if visible_neighbor(d) then
    draw_face(da,dc,db)
    if not vad then 
      draw_face(d+2*ratio*(a-d),db,dc)
    end
    if not vbd then 
      draw_face(d+2*ratio*(b-d),dc,da)
    end
    if not vcd then 
      draw_face(d+2*ratio*(c-d),da,db)
    end
  end
end

function draw_face(a,b,c)
  local va=vec.new(a) 
  local vb=vec.new(b) 
  local vc=vec.new(c) 
  local normal=vec.cross(vb-va,vc-va)
  add_face(normal,a,b,c)
end

function draw_quad(a,b,c,d)
  local va=vec.new(a) 
  local vb=vec.new(b) 
  local vc=vec.new(c) 
  local vc=vec.new(d) 
  local normal=vec.cross(vb-va,vc-va)
  add_face(normal,a,b,c)
  add_face(normal,a,c,d)
end

function shrink(a,b,c,ratio)
  local as={(1-2*ratio)*a[1]+ratio*b[1]+ratio*c[1],
    (1-2*ratio)*a[2]+ratio*b[2]+ratio*c[2],
    (1-2*ratio)*a[3]+ratio*b[3]+ratio*c[3]}
  local bs={ratio*a[1]+(1-2*ratio)*b[1]+ratio*c[1],
    ratio*a[2]+(1-2*ratio)*b[2]+ratio*c[2],
    ratio*a[3]+(1-2*ratio)*b[3]+ratio*c[3]}
  local cs={ratio*a[1]+ratio*b[1]+(1-2*ratio)*c[1],
    ratio*a[2]+ratio*b[2]+(1-2*ratio)*c[2],
    ratio*a[3]+ratio*b[3]+(1-2*ratio)*c[3]}
    return as,bs,cs
end

function add_face(normal,a,b,c)
--[[  stl:set(stl_count,0,normal[1])
  stl:set(stl_count,1,normal[2])
  stl:set(stl_count,2,normal[3])
  stl:set(stl_count,3,a[1])
  stl:set(stl_count,4,a[2])
  stl:set(stl_count,5,a[3])
  stl:set(stl_count,6,b[1])
  stl:set(stl_count,7,b[2])
  stl:set(stl_count,8,b[3])
  stl:set(stl_count,9,c[1])
  stl:set(stl_count,10,c[2])
  stl:set(stl_count,11,c[3])
  stl_count=stl_count+1]]
  out:write_facet(normal,a,b,c)
end

function subdivide_to(p,level)
    pnt:set(0,p[1])
    pnt:set(1,p[2])
    pnt:set(2,p[3])
    local leaf=tree:search(pnt:data())
    while leaf:simplex_level()<level do
        tree:compat_bisect(leaf)
        leaf=tree:search(pnt:data())
    end 
    return leaf
end

function inside(tetra)
  local p=vec.new {0,0,0}
  for i=0,3 do
    p[1]=tetra:get(3*i)
    p[2]=tetra:get(3*i+1)
    p[3]=tetra:get(3*i+2)
    if obj.classify(p)>0 then
      return false
    end
  end
  return true
end

boundary={}
for p in obj.points() do
    local leaf=subdivide_to(p,12)
    boundary[#boundary+1]=leaf
end

for i=1,#boundary do
  extend_boundary(boundary[i])
end

visible={}
tree:node_reset()
repeat 
  if tree:node_is_leaf() then
    local cur=tree:node_code()
    local id=tree:node_id()
    cur:simplex(vert:data())
    visible[id]=inside(vert)
  end
until not tree:node_next()


tree:node_reset()
repeat 
  if tree:node_is_leaf() then
    local cur=tree:node_code()
    local id=tree:node_id()
    if visible[id] then 
      draw_tetra(cur,id,ratio)
    end
  end
until not tree:node_next()

print("closing holes")
tree:node_reset()
repeat 
  if tree:node_is_leaf() then
    local cur=tree:node_code()
    local id=tree:node_id()
    if neighborhood[id] and (not visible[id]) then 
      close_holes(cur,id,ratio)
    end
  end
until not tree:node_next()

out:close()

--[[
print("solid ")
for i=0,stl_count-1 do
  print("facet normal",stl:get(i,0),stl:get(i,1),stl:get(i,2))
  print("\touter loop")
  print("\t\tvertex",stl:get(i,3),stl:get(i,4),stl:get(i,5))
  print("\t\tvertex",stl:get(i,6),stl:get(i,7),stl:get(i,8))
  print("\t\tvertex",stl:get(i,9),stl:get(i,10),stl:get(i,11))
  print("\tendloop")
  print("endfacet")
end
print("endsolid ")
]]