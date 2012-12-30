dofile("modules.lua")
require("array")
require("blas")
require("lapack")
require("lbfgsb")
require("tcl")
require("luagl")
require("luaglu")

function distance_matrix(pts,dist)
	local N=pts[0]:size()
	for i=0,N-1 do	
		dist:sym_set(i,i,0)
		for j=i+1,N-1 do	
			local t=0
			for d=0,#pts do
				local v=pts[d]:get(i)-pts[d]:get(j)
				t=t+v*v
			end
			dist:sym_set(i,j,math.sqrt(t))
		end
	end
end

function S_matrix(N,G,dist,S,dS)
	for i=0,N-1 do
		S:sym_set(i,i,G.g(0)+G.delta)
		dS:sym_set(i,i,0)
		for j=i+1,N-1 do
			local dij=dist:sym_get(i,j)
			S:sym_set(i,j,G.g(dij))
			dS:sym_set(i,j,G.dg(dij)/dij)
		end
	end
end


function geodesic_fdf(G,n,N,m,q,grad)
	local h=1/m
	local k,d,i,j
	local mid={}
	for d=0,n-1 do
		mid[d]=array.array_double(N)
	end
	local dist=array.array_double(N*(N+1)/2)
	local S=array.array_double(N*(N+1)/2)
	local dS=array.array_double(N*(N+1)/2)
	local pp=array.array_double(N)
	local Spp=array.array_double(N)
	local temp=array.array_double(N)
	local f=0
	grad:zero()
	for k=0,m-1 do 
		local projk={}
		local projk1={}
		for d=0,n-1 do
			projk[d]=array.array_double(N,q:data(),k*n*N+d*N)
			projk1[d]=array.array_double(N,q:data(),(k+1)*n*N+d*N)
			mid[d]:zero()
			blas.axpy(0.5,projk[d],mid[d])
			blas.axpy(0.5,projk1[d],mid[d])
		end
		distance_matrix(mid,dist)
		S_matrix(N,G,dist,S,dS)
		lapack.pptrf(N,S)
		for d=0,n-1 do
			blas.copy(projk1[d],pp)
			blas.axpy(-1.0,projk[d],pp)
			blas.copy(pp,Spp)
			lapack.pptrs(N,S,Spp)
			f=f+blas.dot(pp,Spp)/h
			for i=0,N-1 do
				local v=2.0*Spp:get(i)/h
				grad:add_to((k+1)*n*N+d*N+i,v)
				grad:add_to((k)*n*N+d*N+i,-v)
				local dl
				for dl=0,n-1 do
					for j=0,N-1 do 
						temp:set(j, dS:sym_get(i,j)*
							(mid[dl]:get(i)-mid[dl]:get(j)))
					end
					v=Spp:get(i)*blas.dot(temp,Spp)/h
					grad:add_to((k+1)*n*N+dl*N+i,-v)
					grad:add_to((k)*n*N+dl*N+i,-v)
				end
			end
		end
	end
	return f
end

function geodesic_f(G,n,N,m,q)
	local h=1/m
	local k,d,i,j
	local mid={}
	for d=0,n-1 do
		mid[d]=array.array_double(N)
	end
	local dist=array.array_double(N*(N+1)/2)
	local S=array.array_double(N*(N+1)/2)
	local dS=array.array_double(N*(N+1)/2)
	local pp=array.array_double(N)
	local Spp=array.array_double(N)
	local temp=array.array_double(N)
	local f=0
	for k=0,m-1 do 
		local projk={}
		local projk1={}
		for d=0,n-1 do
			projk[d]=array.array_double(N,q:data(),k*n*N+d*N)
			projk1[d]=array.array_double(N,q:data(),(k+1)*n*N+d*N)
			mid[d]:zero()
			blas.axpy(0.5,projk[d],mid[d])
			blas.axpy(0.5,projk1[d],mid[d])
		end
		distance_matrix(mid,dist)
		S_matrix(N,G,dist,S,dS)
		lapack.pptrf(N,S)
		for d=0,n-1 do
			blas.copy(projk1[d],pp)
			blas.axpy(-1.0,projk[d],pp)
			blas.copy(pp,Spp)
			lapack.pptrs(N,S,Spp)
			f=f+blas.dot(pp,Spp)/h
		end
	end
	return f
end

function gen_q(pts0, pts1, m)
	local n=#pts0[1]
	local N=#pts0
	local q=array.array_double((m+1)*n*N)
	for k=0,m do
		local t=k/m
		for d=0,n-1 do
			for i=0,N-1 do
				q:set(k*n*N+d*N+i,(1-t)*pts0[i+1][d+1]+t*pts1[i+1][d+1])
			end
		end
	end
	return q
end

G={ g=function (x) return math.exp(-x*x) end,
		dg=function (x) return -2*x*math.exp(-x*x) end,
		delta=0.1 }
n=2	
N=3
m=100

--q=gen_q( {{-0.5,-0.5},{-0.5,0.0},{-0.5,0.5}},
--  {{0.5,-0.05},{0.5,0.0},{0.5,0.05}}, m)
q=gen_q( {{0.0,0.5},{-0.5,0.0},{0.1,0.0}},
  {{0.0,-0.5},{0.5,0.0},{0.1,0.0}}, m)
grad=array.array_double((m+1)*n*N)

opt=lbfgsb.lbfgsb((m-1)*n*N,20)
opt:n_set((m-1)*n*N)
opt:m_set(20)
opt:factr_set(1000000)
opt:pgtol_set(0.05)
opt:print_set(true)
opt:grad_set(grad:data(n*N))
task=opt:start(q:data(n*N))

-- chamada quando a janela OpenGL é redimensionada
function ReshapeCallback(win)
	width=tcl(win.." cget -width")+0
	height=tcl(win.." cget -height")+0
  gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela
  gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
  gl.LoadIdentity()                -- carrega a matriz identidade
  gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
  gl.LoadIdentity()                -- carrega a matriz identidade
end

function DisplayCallback(win)
  -- limpa a tela e o z-buffer
  gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
  gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
  gl.LoadIdentity()         
  gl.Color(1,0,1)
	for i=0,N-1 do
 		gl.Begin('LINE_STRIP')
		for k=0,m do 
			gl.Vertex(q:get(k*n*N+i),q:get(k*n*N+N+i))
		end
  	gl.End()
	end
  tcl(win.." swapbuffers")
end

-- chamada quando a janela OpenGL é criada
function CreateCallback(win)
  gl.ClearColor(0.0,0.0,0.0,0.0)                  -- cor de fundo preta
  gl.ClearDepth(1.0)                              -- valor do z-buffer
  gl.Disable('DEPTH_TEST')                         -- habilita teste z-buffer
  gl.Enable('CULL_FACE')                         
  gl.ShadeModel('FLAT')
end


function TimerCallback(win)
  if task=="fg" then
		print("fg")
		opt:f_set(geodesic_fdf(G,n,N,m,q,grad))
  elseif task=="new_x" then
		print("new_x")
  	tcl(win.." postredisplay")
  elseif task=="error" then
		print("error")
  elseif task=="abno" then
		print("abno")
  end
	task=opt:call()
end

tcl [[

  package require Togl 2.1
	lua_proc DisplayCallback
	lua_proc ReshapeCallback
	lua_proc CreateCallback
	lua_proc TimerCallback
  togl .hello -time 50 -width 500 -height 500 \
                     -double true -depth true \
                     -createproc CreateCallback \
                     -reshapeproc ReshapeCallback \
                     -timercommand TimerCallback \
                     -displayproc DisplayCallback 
  pack .hello

]]

TkMainLoop()
