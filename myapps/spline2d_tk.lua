dofile("modules.lua")
require("luagl")
require("luaglu")
require("tcl")
require("matrix")

points={}
points.src={}
points.dst={}
points.src.x={}
points.src.y={}
points.dst.x={}
points.dst.y={}

lg={}
sigma=0
kernel=3

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
                mat[i][j]=mat[i][j]+(sigma)^4
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

function sigma_changed_cb(val)
    sigma=val+0
    tcl(".c.gl postredisplay")
end

function kernel_changed_cb(val)
    kernel=val+1
    tcl(".c.gl postredisplay")
end

-- chamada quando a janela OpenGL é redimensionada
function reshape_cb(win)
    --print("resize")
    width=tcl(win.." cget -width")+0
    height=tcl(win.." cget -height")+0
    gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela
    pixel_width=2/width
    gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
    gl.LoadIdentity()                -- carrega a matriz identidade
    gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
    gl.LoadIdentity()                -- carrega a matriz identidade
end

function convert(x,y)
    x=2*x/width-1
    y=1-2*y/height
    return x,y
end

-- chamada quando a janela OpenGL necessita ser desenhada
function display_cb(win)
    --print("action")
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
        local g=lg[math.floor(kernel)]
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
    tcl(win.." swapbuffers")
end

-- chamada quando a janela OpenGL é criada
function create_cb()
    --print("map")
    gl.ClearColor(0.0,0.0,0.0,0.0)                  -- cor de fundo preta
    gl.ClearDepth(1.0)                              -- valor do z-buffer
    gl.Disable('DEPTH_TEST')                         -- habilita teste z-buffer
    gl.Enable('CULL_FACE')
    gl.ShadeModel('FLAT')
    seli=0
    selt=0
end


function button_cb(win,pressed,x,y)
    pressed=pressed+0
    x=x+0
    y=y+0
    if pressed==1 then
        x,y=convert(x,y)
        seli=click(points.dst,x,y,5*pixel_width)
        if seli>0 then
            selt=2 --src
        else
            seli=click(points.src,x,y,5*pixel_width)
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
    tcl(win.." postredisplay")
end

function motion_cb(win,x,y)
    x=x+0
    y=y+0
    if seli>0 then
        x,y=convert(x,y)
        if selt==1 then
            points.src.x[seli]=x
            points.src.y[seli]=y
        else
            points.dst.x[seli]=x
            points.dst.y[seli]=y
        end
        tcl(win.." postredisplay")
    end
end

tcl [[

package require Tk 8.6
package require Togl 2.1

lua_proc display_cb reshape_cb create_cb
lua_proc sigma_changed_cb kernel_changed_cb
lua_proc button_cb motion_cb

wm title . "Spline 1d"
grid [ttk::frame .c -padding "3 3 3 3"] -column 0 -row 0 -sticky nwes
grid columnconfigure . 0 -weight 1; grid rowconfigure . 0 -weight 1
togl .c.gl -time 1 -width 500 -height 500 \
-double true -depth true \
-createproc create_cb \
-reshapeproc reshape_cb \
-displayproc display_cb
bind .c.gl <ButtonPress> {
    button_cb %W 1 %x %y
}
bind .c.gl <ButtonRelease> {
    button_cb %W 0 %x %y
}
bind .c.gl <Motion> {
    motion_cb %W %x %y
}
grid .c.gl -column 0 -row 0 -rowspan 1 -columnspan 2 -sticky nwes
grid columnconfigure .c 0 -weight 1; grid rowconfigure .c 0 -weight 1
grid [ttk::combobox .c.k -values "K0 K1 K2 K3 Gaussian" -state readonly] -row 1 -column 0
.c.k current 3
bind .c.k <<ComboboxSelected>> {
    kernel_changed_cb [.c.k current]
}
grid [ttk::scale .c.s -command sigma_changed_cb -orient horizontal \
-length 200 -from 0.0 -to 1.0] -row 1 -column 1
.c.s set 0.5

]]

-- exibe a janela
-- entra no loop de eventos
TkMainLoop()
