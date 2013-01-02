dofile("modules.lua")
require("iuplua")
require("iupluagl")
require("luagl")
require("luaglu")
require("matrix")

points={}
points.src={}
points.dst={}
points.src.x={}
points.src.y={}
points.dst.x={}
points.dst.y={}

lg={}

function dist(x,y,u,v)
    return math.sqrt((x-u)*(x-u)+(y-v)*(y-v))
end

function gauss(x,y,u,v)
    local l=dist(x,y,u,v)
    return math.exp(-l^2)
end

function green0(x,y,u,v)
    local l=dist(x,y,u,v)
    return math.exp(-l)
end

function green1(x,y,u,v)
    local l=dist(x,y,u,v)
    return 2*(1+l)*math.exp(-l)
end

function green2(x,y,u,v)
    local l=dist(x,y,u,v)
    return 8*(3+3*l+l*l)*math.exp(-l)
end

function green3(x,y,u,v)
    local l=dist(x,y,u,v)
    return 8*(15+15*l+6*l*l+l*l*l)*math.exp(-l)
end

lg[1]=green0
lg[2]=green1
lg[3]=green2
lg[4]=green3
lg[5]=gauss

function click(pts,x,y,err)
    for i=1,#pts.x do
        if math.abs(x-pts.x[i])<err and
            math.abs(y-pts.y[i])<err then
            return i
        end
    end
    return 0
end

function S(g)
    local mat={}
    for i=1,#points.src.x do
        mat[i]={}
        for j=1,#points.src.x do
            mat[i][j]=g(points.src.x[i],points.src.y[i],points.src.x[j],points.src.y[j])
            if i==j then
                mat[i][j]=mat[i][j]+(sigma.value)^4
            end
        end
    end
    return mat
end

function interp(alpha,g,x,y)
    local tx=0
    local ty=0
    for i=1,#points.src.x do
        local w=g(points.src.x[i],points.src.y[i],x,y)
        tx=tx+alpha.x.array:get(i-1)*w
        ty=ty+alpha.y.array:get(i-1)*w
    end
    return tx,ty
end

cnv = iup.glcanvas { buffer="DOUBLE", rastersize = "480x480" }
sigma = iup.val {orientation="HORIZONTAL", value=0.5, max=1}
listg = iup.list { "K0", "K1", "K2", "K3", "Gaussian" ; dropdown="YES", value=2 }
vbox= iup.vbox { cnv,iup.hbox {sigma,listg} }
dlg = iup.dialog {vbox; title="spline2d"}

function sigma:valuechanged_cb()
    cnv:action(0,0)
end

function listg:valuechanged_cb()
    cnv:action(0,0)
end

-- chamada quando a janela OpenGL é redimensionada
function cnv:resize_cb(width, height)
    --print("resize")
    iup.GLMakeCurrent(self)
    gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela
    self.width=width
    self.height=height
    self.pixel_width=2/width
    gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
    gl.LoadIdentity()                -- carrega a matriz identidade
    gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
    gl.LoadIdentity()                -- carrega a matriz identidade
end

function cnv:convert(x,y)
    x=2*x/self.width-1
    y=1-2*y/self.height
    return x,y
end

-- chamada quando a janela OpenGL necessita ser desenhada
function cnv:action(x, y)
    --print("action")
    iup.GLMakeCurrent(self)
    -- limpa a tela e o z-buffer
    gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
    gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
    gl.LoadIdentity()

    gl.PointSize(6.0)
    gl.Color(1,0,0)
    gl.Begin('POINTS')
    for i=1,#points.src.x do
        gl.Vertex(points.src.x[i],points.src.y[i])
    end
    gl.End()
    gl.Color(0,0,1)
    gl.Begin('POINTS')
    for i=1,#points.dst.x do
        gl.Vertex(points.dst.x[i],points.dst.y[i])
    end
    gl.End()
    gl.Color(1,1,0)
    gl.LineWidth(1.0)
    gl.Begin('LINES')
    for i=1,#points.src.x do
        gl.Vertex(points.src.x[i],points.src.y[i])
        gl.Vertex(points.dst.x[i],points.dst.y[i])
    end
    gl.End()
    gl.Color(0.4,0.4,0.4)
    for i=-1,1,0.1 do
        gl.Begin('LINE_STRIP')
        for j=-1,1,0.1 do
            gl.Vertex(i,j)
        end
        gl.End()
    end
    for j=-1,1,0.1 do
        gl.Begin('LINE_STRIP')
        for i=-1,1,0.1 do
            gl.Vertex(i,j)
        end
        gl.End()
    end
    -- troca buffers
    if #points.src.x>0 then
        local g=lg[math.floor(listg.value)]
        local s=matrix.new(S(g))
        local dx=matrix.new({points.dst.x})
        local dy=matrix.new({points.dst.y})
        local alpha={}
        alpha.x=s:solve(dx)
        alpha.y=s:solve(dy)
        gl.PointSize(1.0)
        gl.Color(1,1,1)
        for x=-1,1,0.1 do
            gl.Begin('LINE_STRIP')
            for y=-1,1,0.1 do
                local fx,fy=interp(alpha,g,x,y)
                gl.Vertex(fx,fy)
            end
            gl.End()
        end
        for y=-1,1,0.1 do
            gl.Begin('LINE_STRIP')
            for x=-1,1,0.1 do
                local fx,fy=interp(alpha,g,x,y)
                gl.Vertex(fx,fy)
            end
            gl.End()
        end
    end
    iup.GLSwapBuffers(self)
end

-- chamada quando a janela OpenGL é criada
function cnv:map_cb()
    --print("map")
    iup.GLMakeCurrent(self)
    gl.ClearColor(0.0,0.0,0.0,0.0)                  -- cor de fundo preta
    gl.ClearDepth(1.0)                              -- valor do z-buffer
    gl.Disable('DEPTH_TEST')                         -- habilita teste z-buffer
    gl.Enable('CULL_FACE')
    gl.ShadeModel('FLAT')
    seli=0
    selt=0
end

-- chamada quando uma tecla é pressionada
function cnv:k_any(c)
    if c == iup.K_ESC then
        -- sai da aplicação
        iup.ExitLoop()
    end
end

function cnv:button_cb(but,pressed,x,y,status)
    iup.GLMakeCurrent(self)
    if pressed==1 then
        x,y=cnv:convert(x,y)
        seli=click(points.dst,x,y,5*self.pixel_width)
        if seli>0 then
            selt=2 --src
        else
            seli=click(points.src,x,y,5*self.pixel_width)
            if seli>0 then
                selt=1
            else
                points.src.x[#points.src.x+1]=x
                points.src.y[#points.src.y+1]=y
                points.dst.x[#points.dst.x+1]=x
                points.dst.y[#points.dst.y+1]=y
            end
        end
    else
        seli=0
    end
    cnv:action(0,0)
end

function cnv:motion_cb(x,y,status)
    if seli>0 then
        x,y=cnv:convert(x,y)
        if selt==1 then
            points.src.x[seli]=x
            points.src.y[seli]=y
        else
            points.dst.x[seli]=x
            points.dst.y[seli]=y
        end
        cnv:action(0,0)
    end
end

-- exibe a janela
dlg:show()
-- entra no loop de eventos
iup.MainLoop()
