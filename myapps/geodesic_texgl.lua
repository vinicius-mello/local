dofile("modules.lua")
require("array")
require("blas")
require("lapack")
require("lbfgsb")
require("cubic")
require("tcl")
require("gl2")
require("luagl")
require("luaglu")
require("cl")

kernel_src= [[

float g(float t)
{
    return exp(-t*t);
}

double bspline(double t)
{
    t = (t>0) ? t :  (-t);
    double a = 2.0 - t;

    if (t < 1.0)
        return 2.0/3.0 - 0.5*t*t*a;
    else if (t < 2.0)
        return a*a*a / 6.0;
    else
        return 0.0;
}

double cubic_eval(int l, __global double* c, double t)
{
    double v=0;
    double tt=t*((double)(l-1));
    double b=(double)floor((float)tt);
    double delta=tt-b;
    int bi=(int)b;
    int i;
    for(i=-1;i<=2;++i) {
        int index=bi+i;
        if(index<0) index=-index;
        else if(index>=l) index=2*l-index-2;
        v+=c[index]*bspline(delta-i);
    }
    return v;
}

__kernel void kern(float tf, float dtf, int N, int m, int gr,
    __global double * cq, __global double * calpha, __global double * grid)
{
    double t=(double)tf;
    double dt=(double)dtf;
    int I = get_global_id(0);
    int J = get_global_id(1);

    double2 v=(double2)(0.0,0.0);
    double2 p=(double2)(grid[2*(gr+1)*I+2*J],grid[2*(gr+1)*I+2*J+1]);
    for(int i=0;i<N;++i) {
        double2 qt;
        qt.x=cubic_eval(m+1,cq+i*2*(m+1),t);
        qt.y=cubic_eval(m+1,cq+i*2*(m+1)+(m+1),t);
        double2 alphat;
        alphat.x=cubic_eval(m+1,calpha+i*2*(m+1),t);
        alphat.y=cubic_eval(m+1,calpha+i*2*(m+1)+(m+1),t);
        float2 d;
        d.x=(float)(qt.x-p.x);
        d.y=(float)(qt.y-p.y);
        double r=(double)g(hypot(d.x,d.y));
        v.x+=alphat.x*r;
        v.y+=alphat.y*r;
    }
    p.x=p.x+v.x*dt;
    p.y=p.y+v.y*dt;
    grid[2*(gr+1)*I+2*J]=p.x;
    grid[2*(gr+1)*I+2*J+1]=p.y;
};
]]

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


function gen_q(pts0, pts1, m)
    local n=#pts0[1]
    local N=#pts0
    local q=array.double((m+1),n,N)
    local src=array.double(N,n)
    local dst=array.double(N,n)
    local k,d,i
    for i=0,N-1 do
        for d=0,n-1 do
            src:set(i,d,pts0[i+1][d+1])
            dst:set(i,d,pts1[i+1][d+1])
        end
    end
    for k=0,m do
        local t=k/m
        for d=0,n-1 do
            for i=0,N-1 do
                q:set(k,d,i,(1-t)*pts0[i+1][d+1]+t*pts1[i+1][d+1])
            end
        end
    end
    return q,src,dst
end

function setup_cl()
    cl.host_init()
    ctx=cl.context(0)
    ctx:add_device(1)
    ctx:init()
    cmd=cl.command_queue(ctx,0,0)
    prg=cl.program(ctx,kernel_src)
    print(cl.host_get_error())
    krn=cl.kernel(prg, "kern")
    print(cl.host_get_error())

    memcq=cl.mem(ctx,cl.MEM_READ_ONLY,cq:size_of())
    print(cq:size_of(),cl.host_get_error())
    memcalpha=cl.mem(ctx,cl.MEM_READ_ONLY,calpha:size_of())
    print(calpha:size_of(),cl.host_get_error())
    memgrid=cl.mem(ctx,cl.MEM_READ_WRITE,grid:size_of())
    print(grid:size_of(),cl.host_get_error())
end

function run_kernel()
    print("run_kernel")
    cmd:write_buffer(memcq, true, 0, cq:size_of(), cq:data())
    cmd:write_buffer(memcalpha, true, 0, calpha:size_of(), calpha:data())
    cmd:write_buffer(memgrid, true, 0, grid:size_of(), grid:data())
    krn:arg_float(0,t)
    krn:arg_float(1,dt)
    krn:arg(2,N)
    krn:arg(3,m)
    krn:arg(4,gr)
    krn:arg(5,memcq)
    krn:arg(6,memcalpha)
    krn:arg(7,memgrid)
    cmd:range_kernel2d(krn,0,0,gr+1,gr+1,1,1)
    print(cl.host_get_error())
    cmd:finish()
    print(cl.host_get_error())
    cmd:read_buffer(memgrid, true, 0, grid:size_of(), grid:data())
end

G={ g=function (x) return math.exp(-x*x) end,
dg=function (x) return -2*x*math.exp(-x*x) end,
delta=0.00 }
n=2
N=3
m=100
gr=64
t=0
steps=2
dt=1/m/steps

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
--[[q,src,dst=gen_q(
    {{-0.5,-0.45},{0.5,-0.45},{0.0,0.0}},
    {{-0.7,-0.1},{0.7,-0.1},{0.0,0.0}},
    m)]]
q,src,dst=gen_q(
    {{-0.5,0.0},{0.0,-0.5},{0.1,0.0}},
    {{0.0,0.4},{-0.4,0.1},{0.3,0.0}},
    m)
grad=array.double(m+1,n,N)
alpha=array.double(m+1,n,N)
cq=array.double(N,n,m+1)
calpha=array.double(N,n,m+1)
grid=array.double(gr+1,gr+1,2)
vxt=array.double(2)

for i=0,gr do
    for j=0,gr do
        grid:set(i,j,0,-1.0+2*j/gr)
        grid:set(i,j,1,-1.0+2*i/gr)
    end
end
opt=lbfgsb.lbfgsb((m-1)*n*N,20)
opt:n_set((m-1)*n*N)
opt:m_set(20)
opt:factr_set(1000000)
opt:pgtol_set(0.05)
--opt:print_set(true)
opt:grad_set(grad:data(1,0,0))
task="init"

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
    gl.PointSize(6.0)
    gl.Color(1,0,0)
    gl.Begin('POINTS')
    for i=0,N-1 do
        gl.Vertex(src:get(i,0),src:get(i,1))
    end
    gl.End()
    gl.Color(0,0,1)
    gl.Begin('POINTS')
    for i=0,N-1 do
        gl.Vertex(dst:get(i,0),dst:get(i,1))
    end
    gl.End()
    gl.PointSize(1.0)
    gl.Color(1,1,0)
    for i=0,N-1 do
        gl.Begin('LINE_STRIP')
        for k=0,m do
            gl.Vertex(q:get(k,0,i),q:get(k,1,i),0.1)
        end
        gl.End()
    end
    texsrc:bind()
    gl.Enable('TEXTURE_2D')
    for i=0,gr-1 do
        for j=0,gr-1 do
            gl.Begin('QUADS')
            local x0y1=grid:row(i+1,j)
            local x1y1=grid:row(i+1,j+1)
            local x1y0=grid:row(i,j+1)
            local x0y0=grid:row(i,j)
            --[[
            gl.TexCoord((x0y1:get(0)+1)/2,1-(x0y1:get(1)+1)/2)
            gl.Vertex(2*j/gr-1,2*(i+1)/gr-1,0.5)
            gl.TexCoord((x0y0:get(0)+1)/2,1-(x0y0:get(1)+1)/2)
            gl.Vertex(2*j/gr-1,2*(i)/gr-1,0.5)
            gl.TexCoord((x1y0:get(0)+1)/2,1-(x1y0:get(1)+1)/2)
            gl.Vertex(2*(j+1)/gr-1,2*(i)/gr-1,0.5)
            gl.TexCoord((x1y1:get(0)+1)/2,1-(x1y1:get(1)+1)/2)
            gl.Vertex(2*(j+1)/gr-1,2*(i+1)/gr-1,0.5)
            --]]
            gl.TexCoord(j/gr,1.0-(i+1)/gr)
            gl.Vertex(x0y1:get(0),x0y1:get(1),0.5)
            gl.TexCoord(j/gr,1.0-i/gr)
            gl.Vertex(x0y0:get(0),x0y0:get(1),0.5)
            gl.TexCoord((j+1)/gr,1.0-i/gr)
            gl.Vertex(x1y0:get(0),x1y0:get(1),0.5)
            gl.TexCoord((j+1)/gr,1.0-(i+1)/gr)
            gl.Vertex(x1y1:get(0),x1y1:get(1),0.5)
            
            gl.End()
        end
    end
    gl.Disable('TEXTURE_2D')
    tcl(win.." swapbuffers")
end


-- chamada quando a janela OpenGL é criada
function CreateCallback(win)
    gl2.init()
    setup_cl()
    gl.ClearColor(0.0,0.0,0.0,0.0)                  -- cor de fundo preta
    gl.ClearDepth(1.0)                              -- valor do z-buffer
    gl.Enable('DEPTH_TEST')                         -- habilita teste z-buffer
    gl.Enable('CULL_FACE')
    gl.ShadeModel('FLAT')

    image=array.byte(512,512,4)
    image:read("mandril.512x512.rgba")
    texsrc=gl2.color_texture2d()
    texsrc:set(0,gl.RGBA,512,512,0,gl.RGBA,gl.UNSIGNED_BYTE,image:data())
end


function TimerCallback(win)
    if task=="start" then
        task=opt:start(q:data(1,0,0))
    elseif task=="fg" then
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
        for it=1,steps do
            --[[
            for i=0,gr do
                for j=0,gr do
                    local x=grid:row(i,j)
                    v(x,t,G,cq,calpha,vxt)
                    blas.axpy(dt,vxt,x)
                end
            end
            --]]
            run_kernel()
            for i=0,N-1 do
                local x=src:row(i)
                v(x,t,G,cq,calpha,vxt)
                blas.axpy(dt,vxt,x)
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
    lua_global task
    togl .hello -time 50 -width 500 -height 500 \
    -double true -depth true \
    -createproc CreateCallback \
    -reshapeproc ReshapeCallback \
    -timercommand TimerCallback \
    -displayproc DisplayCallback
    bind . <Key-Escape> { exit }
    bind . <Key-space> { set task "start" }
    pack .hello

]]

TkMainLoop()
