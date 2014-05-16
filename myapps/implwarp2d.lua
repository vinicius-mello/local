dofile("modules.lua")
require("win")
require("gl2")
require("triangle_tree")
require("adia")
require("Heap")
require("queue")

require("functions2d")
dofile("util2d.lua")


function rescale(f)
  return function(x,y)
    x=2*x
    y=2*y
    return f(x,y)
  end
end


function adaptation_test(diam,k)
  return function (q)
    local Ix,Iy=tree:bounding_box(q)
    local I=eq[0](Ix,Iy)
    local int=I:contains(0)
    local dx=eq[1](Ix,Iy)
    local dy=eq[2](Ix,Iy)
    local dg=dx*dx+dy*dy
    if not int then
      return true
    elseif Ix:diam()<=diam then
      return true
    elseif not dg:contains(0) then
      dg=interval.sqrt(dg)
      dx=dx/dg
      dy=dy/dg
      if math.max(dx:diam(),dy:diam())<k then
        return true
      end
    end
    return false
  end
end

function goodtriangle_test(mct) 
  return function(xs,ys)
    return triangle_quality(xs,ys)<=mct
  end
end

function reset(pars)
  print("reset")
  src_flag={}
  lmk_src={}
  lmk_dst={}
  heap=Heap.new()
  tree=triangle_tree.new()
  local x=ad.var(2,1)
  local y=ad.var(2,2)
  f=rescale(functions2d[functions2d.names[pars.func+1]])
  eq=f(x,y)
  stop=adaptation_test(2^pars.diam,pars.k)
  goodtriangle=goodtriangle_test(pars.mct)
  one_step=coroutine.create(main)
end

cnv = win.New("implwarp2d")

function draw_triangle(c)
  local vids,xs,ys=tree:points(c)
  --[[
  local tq=1-goodtriangle(xs,ys)
  gl.Color(tq,tq,tq)
  gl.Begin('TRIANGLES')
  gl.Vertex(xs[1],ys[1])
  gl.Vertex(xs[2],ys[2])
  gl.Vertex(xs[3],ys[3])
  gl.End()
	]]
  gl.Color(0,0,0)
	gl.Begin('LINE_LOOP')
 	gl.Vertex(xs[1],ys[1])
 	gl.Vertex(xs[2],ys[2])
 	gl.Vertex(xs[3],ys[3])
	gl.End()
  gl.PointSize(4.0)
  gl.Begin('POINTS')
  for i=1,3 do
    local x=xs[i]
    local y=ys[i]
    if f(x,y) <=0.000001 then 
      gl.Color(1,0,0)
    else
      gl.Color(0,0,1)
    end
    gl.Vertex(x,y)
  end
  gl.End()

end

-- chamada quando a janela OpenGL é redimensionada
function cnv:Reshape(width, height)
  gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela
	self.width=width
	self.height=height
  gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
  gl.LoadIdentity()                -- carrega a matriz identidade
  gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
  gl.LoadIdentity()                -- carrega a matriz identidade
end

-- chamada quando a janela OpenGL necessita ser desenhada
function cnv:Display()
  -- limpa a tela e o z-buffer
  gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
  gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
	gl.LoadIdentity()         
  for c in tree:leafs() do 
      draw_triangle(c)
  end  
end

-- chamada quando a janela OpenGL é criada
function cnv:Init()
  gl.ClearColor(1.0,1.0,1.0,0)                  -- cor de fundo preta
  gl.ClearDepth(1.0)                              -- valor do z-buffer
  gl.Disable('DEPTH_TEST')                         -- habilita teste z-buffer
  gl.Enable('CULL_FACE')                         
  gl.ShadeModel('FLAT')  
  self.pars=bar.New("Parameters")
  self.pars:NewVar {name="func",
     type={name="Functions",
                enum=functions2d.names }
  }
  self.pars.func=0
  self.pars:NewVar {name="diam", type=tw.TYPE_DOUBLE, properties="min=-6 max=-2 step=1"}
    self.pars.diam=-4
  self.pars:NewVar {name="k", type=tw.TYPE_DOUBLE, properties="min=0.5 max=10 step=0.5"}
    self.pars.k=1
  self.pars:NewVar {name="mct", type=tw.TYPE_DOUBLE, properties="min=1 max=8 step=0.5"}
    self.pars.mct=5
  self.pars:AddButton( "Reset", function() reset(self.pars) end)
  reset(self.pars)
end

-- chamada quando uma tecla é pressionada
function cnv:Keyboard(c,x,y)
  if c == 27 then
  -- sai da aplicação
    os.exit()
  elseif c == 32 then
    coroutine.resume(one_step)
  end
end


function main()
  print("main")
  subdivide()
  coroutine.yield()
  split_edges()
  coroutine.yield()
  tubular()
  coroutine.yield()
  snap()
end

function subdivide()
  print("subdivide")
  local qc=queue.new()
  for c in tree:leafs() do
    qc:pushleft(c)
  end
  while not qc:empty() do
    local c=qc:popright()
    if tree:is_leaf(c) and not stop(c) then
      local recent=tree:split(c)
      for i=1,#recent do qc:pushleft(recent[i]) end
      if math.random()<0.1 then coroutine.yield() end
    end    
  end
end

function split_edges()
  print("split")
  local qc=queue.new()
  for c in tree:leafs() do
    qc:pushleft(c)
  end
  while not qc:empty() do
    local c=qc:popright()
    if tree:is_leaf(c) then      
      local vids,xs,ys=tree:vertices(c)
      local edge={{1,2},{1,3},{2,3}}
      for i=1,3 do
        local x1=xs[edge[i][1]]
        local y1=ys[edge[i][1]]
        local x2=xs[edge[i][2]]
        local y2=ys[edge[i][2]]
        local f1=f(x1,y1)
        local f2=f(x2,y2)
        if f1*f2<0 then
          local t=bisect(
            function(t)
              return f((1-t)*x1+t*x2,(1-t)*y1+t*y2)
            end, 1/512)
          if t>0.4 and t<0.6 then 
            local recent=tree:split(c)
            for i=1,#recent do
              if recent[i]:orthant_level()<=7 then 
                qc:pushleft(recent[i])
              end
            end
            if math.random()<0.1 then coroutine.yield() end
            break
          end
        end  
      end
    end
  end
end

function tubular()
  print("tubular")
  for c in tree:leafs() do
    local vids,xs,ys=tree:vertices(c)
    local fs={}
    for i=1,3 do
      fs[i]=f(xs[i],ys[i])
    end
    if (fs[1]*fs[2]<=0) or (fs[1]*fs[3]<=0) or (fs[2]*fs[3]<=0) then
      local others={{2,3},{1,3},{1,2}}
      for i=1,3 do
        local x=xs[i]
        local y=ys[i] 
        local x1=xs[others[i][1]]
        local y1=ys[others[i][1]]
        local x2=xs[others[i][2]]
        local y2=ys[others[i][2]]
        local xp,yp=newton(eq,x,y,0.00001)
        if inside(xp,yp,xs,ys) then            
          local d=(x-xp)^2+(y-yp)^2
          local d1=(x1-xp)^2+(y1-yp)^2
          local d2=(x2-xp)^2+(y2-yp)^2
          if (d<d1 and d<d2) and not src_flag[vids[i]] then
            src_flag[vids[i]]=true
            lmk_src[#lmk_src+1]={x,y}
            lmk_dst[#lmk_dst+1]={xp,yp}
            heap:push(#lmk_src,-d)
          end
        end
      end
    end
  end
end

function snap()
  print("snap")
  while not heap:isempty() do
    local i,d=heap:pop()
    local x=lmk_src[i][1]
    local y=lmk_src[i][2]
    local xd=lmk_dst[i][1]
    local yd=lmk_dst[i][2]
    tree:set(x,y,xd,yd)
    local cells=tree:cells(x,y)
    for i=1,#cells do
      local c=cells[i]
      local vids,xs,ys=tree:points(c)
      if not goodtriangle(xs,ys) then
        tree:set(x,y,x,y)
        break
      end
    end
    coroutine.yield()
  end
end


win.Loop()
