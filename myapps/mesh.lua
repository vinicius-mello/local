dofile("modules.lua")
require("win")
require("ply")
require("gl2")
require("array")
require("vec")

print("Lendo header do arquivo ply")
filename=arg[1]
mesh=ply.load(filename)
mesh:print_header()

deg=array.uint(mesh.vertex.size)
vtx=array.float(mesh.vertex.size,3)
nml=array.float(mesh.vertex.size,3)
idx=array.uint(mesh.face.size,3)

bb={
    xa=math.huge,
    xb=-math.huge,
    ya=math.huge,
    yb=-math.huge,
    za=math.huge,
    zb=-math.huge
}  --bounding box


function mesh.vertex_read_cb(i,reg)
    vtx:set(i,0,reg.x)
    vtx:set(i,1,reg.y)
    vtx:set(i,2,reg.z)
    nml:set(i,0,0)
    nml:set(i,1,0)
    nml:set(i,2,0)
    deg:set(i,0)
    bb.xa=math.min(bb.xa, reg.x)
    bb.xb=math.max(bb.xb, reg.x)
    bb.ya=math.min(bb.ya, reg.y)
    bb.yb=math.max(bb.yb, reg.y)
    bb.za=math.min(bb.za, reg.z)
    bb.zb=math.max(bb.zb, reg.z)
end

function mesh.face_read_cb(i,reg)
    local v={}
    local ii={}
    for j=1,3 do -- recupera os vertices e acumula o grau de cada vertice
        local k=idx:set(i,j-1,reg.vertex_indices[j])
        ii[j]=k
        deg:set(k,deg:get(k)+1)
        v[j]=vec.new { vtx:get(k,0), vtx:get(k,1), vtx:get(k,2) }
    end
    local a=v[2]-v[1]
    local b=v[3]-v[1]
    local n=a^b
    local norm=math.sqrt(n%n)
    n=1.0/norm*n
    for j=1,3 do
        local k=reg.vertex_indices[j]
        local ns=vec.new { nml:get(k,0), nml:get(k,1), nml:get(k,2) }
        ns=ns+n
        nml:set(k,0,ns[1])
        nml:set(k,1,ns[2])
        nml:set(k,2,ns[3])
    end
end

print("Processando arquivo ply")
mesh:read_data()
print("Bounding Box: ["..bb.xa..","..bb.xb.."]x["..bb.ya..","..bb.yb.."]x["..bb.za..","..bb.zb.."]")


--normaliza normais
for i=0,mesh.vertex.size-1 do
    local ns=vec.new { nml:get(i,0), nml:get(i,1), nml:get(i,2) }
    ns=1/deg:get(i)*ns
    nml:set(i,0,ns[1])
    nml:set(i,1,ns[2])
    nml:set(i,2,ns[3])
end
deg=nil

--centro da bounding box
bb.xm=(bb.xa+bb.xb)/2
bb.ym=(bb.ya+bb.yb)/2
bb.zm=(bb.za+bb.zb)/2

-- monta interface

ctrl_win=win.New("clgl")

function ctrl_win:Reshape(width, height)
    gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela

    gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
    gl.LoadIdentity()                -- carrega a matriz identidade
    glu.Perspective(60,width/height,0.01,1000)

    gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
    gl.LoadIdentity()                -- carrega a matriz identidade
    self.radius=math.max((bb.zb-bb.za)/2,(bb.yb-bb.ya)/2,(bb.xb-bb.xa)/2)
    glu.LookAt(0,0,4*self.radius,0,0,0,0,1,0)
    self.model_track:resize(self.radius)
    self.light_track:resize(self.radius)
end

function ctrl_win:draw_ball()
    gl.Disable('LIGHTING')
    gl.Begin('LINE_LOOP')
    for theta=0,2*math.pi,math.pi/30 do
        gl.Vertex(self.radius*math.cos(theta),0.0,self.radius*math.sin(theta))
    end
    gl.End()
    gl.Begin('LINE_LOOP')
    for theta=0,2*math.pi,math.pi/30 do
        gl.Vertex(0.0,self.radius*math.cos(theta),self.radius*math.sin(theta))
    end
    gl.End()
    gl.Begin('LINE_LOOP')
    for theta=0,2*math.pi,math.pi/30 do
        gl.Vertex(self.radius*math.cos(theta),self.radius*math.sin(theta),0.0)
    end
    gl.End()
    gl.Enable('LIGHTING')
end

function ctrl_win:draw_rays()
    gl.Disable('LIGHTING')
    gl.Begin('LINES')
    for x=-self.radius,self.radius,self.radius/4 do
        for y=-self.radius,self.radius,self.radius/4 do
            gl.Vertex(x,y,0)
            gl.Vertex(x,y,1000)
        end
    end
    gl.End()
    gl.Enable('LIGHTING')
end

-- chamada quando a janela OpenGL necessita ser desenhada
function ctrl_win:Display()
    -- limpa a tela e o z-buffer
    gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
    gl.EnableClientState('VERTEX_ARRAY')
    gl.EnableClientState('NORMAL_ARRAY')
    gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
    gl.LoadIdentity()
    glu.LookAt(0,0,4*self.radius,0,0,0,0,1,0)

    if self.dragging then
        gl.PushMatrix()
        self.model_track:rotate()
        gl.Color(1,1,1)
        self:draw_ball(self.radius)
        gl.PopMatrix()
    end
    if self.light_dragging then
        gl.PushMatrix()
        self.light_track:rotate()
        gl.Color(1,1,0)
        self:draw_rays()
        gl.PopMatrix()
    end

    gl.PushMatrix()
    self.light_track:transform()
    gl.Light ('LIGHT0', 'POSITION',{0,0,1000,1})
    gl.PopMatrix()

    self.model_track:transform()
    gl.Translate(-bb.xm,-bb.ym,-bb.zm)
    self.prog:bind()
    gl2.draw_triangles(idx)
    self.prog:unbind()
    gl.DisableClientState('NORMAL_ARRAY')
    gl.DisableClientState('VERTEX_ARRAY')
end

-- chamada quando a janela OpenGL é criada
function ctrl_win:Init()
    print("Iniciando GLEW")
    gl2.init()
    print("Habilitando arrays")
    gl.EnableClientState('VERTEX_ARRAY')
    gl2.vertex_array(vtx)
    gl.DisableClientState('VERTEX_ARRAY')
    gl.EnableClientState('NORMAL_ARRAY')
    gl2.normal_array(nml)
    gl.DisableClientState('NORMAL_ARRAY')

    print("Configurando OpenGL")
    gl.ClearColor(0.0,0.0,0.0,0.5)                  -- cor de fundo preta
    gl.ClearDepth(1.0)                              -- valor do z-buffer
    gl.Enable('DEPTH_TEST')                         -- habilita teste z-buffer
    gl.DepthFunc('LEQUAL')                          -- tipo do teste
    gl.Light ('LIGHT0', 'AMBIENT', {0,0,0,1})
    gl.Light ('LIGHT0', 'DIFFUSE', {1,1,1,1})
    gl.Light ('LIGHT0', 'SPECULAR', {1,1,1,1})

    gl.ShadeModel('SMOOTH')
    gl.Enable ('LIGHTING')
    gl.Enable ('LIGHT0')
    gl.LightModel('LIGHT_MODEL_TWO_SIDE',{1,1,1,1})
    gl.Enable ('CULL_FACE')
    gl.Enable ('DEPTH_TEST')
    gl.Enable ('NORMALIZE')

    print("Iniciando a trackball")
    self.model_track=gl2.trackball()
    self.light_track=gl2.trackball()
    self.pressed=false
    self.dragging=false
    self.light_dragging=false

    print("Configurando os shaders")
    self.fsh=gl2.fragment_shader()
    self.fsh:load_source("mesh.frag")
    self.vsh=gl2.vertex_shader()
    self.vsh:load_source("mesh.vert")
    self.prog=gl2.program()
    self.prog:attach(self.vsh)
    self.prog:attach(self.fsh)
    self.prog:link()
    self.vsh:print_log()
    self.fsh:print_log()
    self.prog:print_log()
end

-- chamada quando uma tecla é pressionada
function ctrl_win:Keyboard(key,x,y)
    if key==27 then
        os.exit()
    end
end

function ctrl_win:Mouse(button,state,x,y)
    if button==glut.LEFT_BUTTON and
        state==glut.DOWN then
        self.model_track:start_motion(x,y)
        self.light_track:start_motion(x,y)
        self.pressed=true
        self.mod_status=self:GetModifiers()
    else
        self.pressed=false
    end
    self.dragging=false
    self.light_dragging=false
end

function ctrl_win:Motion(x,y)
    if self.pressed then
        if self:ActiveShift(self.mod_status) and self:ActiveCtrl(self.mod_status) then
            self.light_track:move_rotation(x,y)
            self.light_dragging=true
        elseif self:ActiveShift(self.mod_status) then
            self.model_track:move_scaling(x,y)
            self.dragging=true
        elseif self:ActiveCtrl(self.mod_status) then
            self.model_track:move_pan(x,y)
            self.dragging=true
        elseif self:ActiveAlt(self.mod_status) then
            self.model_track:move_zoom(x,y)
            self.dragging=true
        else
            self.model_track:move_rotation(x,y)
            self.dragging=true
        end
    end
end

win.Loop()
