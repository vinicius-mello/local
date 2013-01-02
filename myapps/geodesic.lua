dofile("modules.lua")
require("array")
require("blas")
require("lapack")
require("lbfgsb")
require("cubic")
require("tcl")
require("luagl")
require("luaglu")


function distance_matrix(pts,dist)
    local N=pts:columns()
    local n=pts:rows()
    local i,j,d
    for i=0,N-1 do
        dist:sym_set(i,i,0)
        for j=i+1,N-1 do
            local t=0
            for d=0,n-1 do
                local v=pts:get(d,i)-pts:get(d,j)
                t=t+v*v
            end
            dist:sym_set(i,j,math.sqrt(t))
        end
    end
end


function S_matrix(N,G,dist,S,dS)
    local i,j
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


function geodesic_fdf(G,n,N,m,q,grad,work)
    local h=1/m
    local k,d,i,j
    local f=0

    local mid=work.mid
    local dist=work.dist
    local S=work.S
    local dS=work.dS
    local pp=work.pp
    local Spp=work.Spp
    local temp=work.temp

    grad:zero()
    for k=0,m-1 do
        local projk={}
        local projk1={}
        mid:zero()
        for d=0,n-1 do
            projk[d]=q:row(k,d)
            projk1[d]=q:row(k+1,d)
            local t=mid:row(d)
            blas.axpy(0.5,projk[d],t)
            blas.axpy(0.5,projk1[d],t)
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
                grad:add_to(k+1,d,i,v)
                grad:add_to(k,d,i,-v)
                local dl
                for dl=0,n-1 do
                    for j=0,N-1 do
                        temp:set(j, dS:sym_get(i,j)*
                        (mid:get(dl,i)-mid:get(dl,j)))
                    end
                    v=Spp:get(i)*blas.dot(temp,Spp)/h
                    grad:add_to(k+1,dl,i,-v)
                    grad:add_to(k,dl,i,-v)
                end
            end
        end
    end
    return f
end


function geodesic_alpha(G,n,N,m,q,cq,alpha,work)
    local h=1/m
    local k,d,i,t

    local dist=work.dist
    local S=work.S
    local dS=work.dS

    for k=0,m do
        t=h*k
        local projk=q:plane(k)
        distance_matrix(projk,dist)
        S_matrix(N,G,dist,S,dS)
        lapack.pptrf(N,S)
        for d=0,n-1 do
            local alphakd=alpha:row(k,d)
            for i=0,N-1 do
                alphakd:set(i,cubic.evald(cq:row(i,d),t))
            end
            lapack.pptrs(N,S,alphakd)
        end
    end
end


function v(x,t,G,cq,calpha,vxt)
    local N=cq:depth()
    local n=cq:height()
    local px=array.double(n)
    local pv=array.double(n)
    local i,d
    vxt:zero()
    for i=0,N-1 do
        blas.copy(x,px)
        for d=0,n-1 do
            local cqid=cq:row(i,d)
            local calphaid=calpha:row(i,d)
            px:add_to(d,-cubic.eval(cqid,t))
            pv:set(d,cubic.eval(calphaid,t))
        end
        local dist=math.sqrt(blas.dot(px,px))
        blas.axpy(G.g(dist),pv,vxt)
    end
end


function gen_q(pts0, pts1, m)
    local n=#pts0[1]
    local N=#pts0
    local q=array.double((m+1),n,N)
    local k,d,i
    for k=0,m do
        local t=k/m
        for d=0,n-1 do
            for i=0,N-1 do
                q:set(k,d,i,(1-t)*pts0[i+1][d+1]+t*pts1[i+1][d+1])
            end
        end
    end
    return q
end


function to_cubic(cq)
    local N=cq:depth()
    local n=cq:height()
    local i,d
    for i=0,N-1 do
        for d=0,n-1 do
            cubic.convert(cq:row(i,d))
        end
    end
end


G={ g=function (x) return math.exp(-x*x) end,
dg=function (x) return -2*x*math.exp(-x*x) end,
delta=0.0 }
n=2
N=3
m=100
gr=40
t=0
dt=0.001

work={
    mid=array.double(n,N),
    dist=array.double(N*(N+1)/2),
    S=array.double(N*(N+1)/2),
    dS=array.double(N*(N+1)/2),
    pp=array.double(N),
    Spp=array.double(N),
    temp=array.double(N)
}

--q=gen_q( {{-0.5,-0.5},{-0.5,0.0},{-0.5,0.5}},
--  {{0.5,-0.05},{0.5,0.0},{0.5,0.05}}, m)
q=gen_q( {{-0.5,0.0},{0.0,-0.5},{0.1,0.0}},
{{0.5,0.0},{0.0,0.5},{0.1,0.0}}, m)
grad=array.double(m+1,n,N)
alpha=array.double(m+1,n,N)
cq=array.double(N,n,m+1)
calpha=array.double(N,n,m+1)
grid=array.double(gr+1,gr+1,2)
vxt=array.double(2)

for i=0,gr do
    for j=0,gr do
        grid:set(i,j,0,-1.0+2*i/gr)
        grid:set(i,j,1,-1.0+2*j/gr)
    end
end
opt=lbfgsb.lbfgsb((m-1)*n*N,20)
opt:n_set((m-1)*n*N)
opt:m_set(20)
opt:factr_set(1000000)
opt:pgtol_set(0.05)
--opt:print_set(true)
opt:grad_set(grad:data(1,0,0))
task=opt:start(q:data(1,0,0))


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
            gl.Vertex(q:get(k,0,i),q:get(k,1,i),0.0)
        end
        gl.End()
    end
    gl.Color(0.5,0.5,0.5)
    for i=0,gr do
        gl.Begin('LINE_STRIP')
        for j=0,gr do
            local x=grid:row(i,j)
            gl.Vertex(x:get(0),x:get(1),0.5)
        end
        gl.End()
    end
    for j=0,gr do
        gl.Begin('LINE_STRIP')
        for i=0,gr do
            local x=grid:row(i,j)
            gl.Vertex(x:get(0),x:get(1),0.5)
        end
        gl.End()
    end
    tcl(win.." swapbuffers")
end


-- chamada quando a janela OpenGL é criada
function CreateCallback(win)
    gl.ClearColor(0.0,0.0,0.0,0.0)                  -- cor de fundo preta
    gl.ClearDepth(1.0)                              -- valor do z-buffer
    gl.Enable('DEPTH_TEST')                         -- habilita teste z-buffer
    gl.Enable('CULL_FACE')
    gl.ShadeModel('FLAT')
end


function TimerCallback(win)
    if task=="fg" then
        --print("fg")
        opt:f_set(geodesic_fdf(G,n,N,m,q,grad,work))
        task=opt:call()
    elseif task=="new_x" then
        --print("new_x")
        task=opt:call()
        tcl(win.." postredisplay")
    elseif task=="error" then
        print("error")
    elseif task=="abno" then
        print("abno")
    elseif task=="conv" then
        print("conv")
        q:rearrange("210",cq)
        to_cubic(cq)
        geodesic_alpha(G,n,N,m,q,cq,alpha,work)
        alpha:rearrange("210",calpha)
        to_cubic(calpha)
        task="integrate"
    elseif task=="integrate" then
        --print("integrate")
        for it=1,10 do
            for i=0,gr do
                for j=0,gr do
                    local x=grid:row(i,j)
                    v(x,t,G,cq,calpha,vxt)
                    blas.axpy(dt,vxt,x)
                end
            end
            t=t+dt
        end
        if t>1 then
            task="finished"
            print(task)
        end
        tcl(win.." postredisplay")
    end
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
