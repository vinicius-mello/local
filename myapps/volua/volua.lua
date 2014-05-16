dofile("modules.lua")
require("win")
require("gl2")
require("array")
require("cubic")
require("colormap")
require("matrix")

engine={}
engine.win=win.New("volua")

require("processors")

function engine.win:Reshape(width, height)
    gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela

    self.width=width
    self.height=height

    gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
    gl.LoadIdentity()                -- carrega a matriz identidade
    self.radius=1.41
    glu.LookAt(0,0,4*self.radius,0,0,0,0,1,0)
    engine.model_track:resize(self.radius)
    engine.light_track:resize(self.radius)
end

function engine.win:draw_ball()
    gl.Disable('LIGHTING')
    gl.Color(1,1,0)
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
end



function engine.win:draw_rays()
    gl.Disable('LIGHTING')
    gl.Color(1,1,0)
    gl.Begin('LINES')
    for x=-self.radius,self.radius,self.radius/4 do
        for y=-self.radius,self.radius,self.radius/4 do
            gl.Vertex(x,y,0)
            gl.Vertex(x,y,1000)
        end
    end
    gl.End()
end



-- chamada quando a janela OpenGL necessita ser desenhada
function engine.win:Display()
    engine.frame=engine.frame+1
    gl.ClearColor(0.0,0.0,0.0,0.0)
    gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
    gl.LoadIdentity()                -- carrega a matriz identidade
    glu.Perspective(60,self.width/self.height,0.01,1000)
    gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
    gl.LoadIdentity()
    glu.LookAt(0,0,4*self.radius,0,0,0,0,1,0)

    canvas:render()

    gl.PushMatrix()
    engine.model_track:transform()
    self:draw_ball()
    gl.PopMatrix()
    if self.light_dragging then
        gl.PushMatrix()
        --gl.LoadIdentity()
        engine.light_track:transform()
        gl.Light ('LIGHT0', 'POSITION',{0,0,1000,1})
        self:draw_rays()
        gl.PopMatrix()
    end
    
 end

-- chamada quando a janela OpenGL é criada
function engine.win:Init()
    print("Iniciando GLEW")
    gl2.init()
    print("Configurando OpenGL")
    gl.ClearDepth(1.0)                              -- valor do z-buffer
    gl.Enable('DEPTH_TEST')                         -- habilita teste z-buffer
    gl.DepthFunc('LEQUAL')                          -- tipo do teste
    gl.Light ('LIGHT0', 'AMBIENT', {0,0,0,1})
    gl.Light ('LIGHT0', 'DIFFUSE', {1,1,1,1})
    gl.Light ('LIGHT0', 'SPECULAR', {1,1,1,1})

    gl.ShadeModel('SMOOTH')
    --gl.Enable ('LIGHTING')
    --gl.Enable ('LIGHT0')
    --gl.LightModel('LIGHT_MODEL_TWO_SIDE',{1,1,1,1})
    gl.Enable ('CULL_FACE')
    gl.Enable ('DEPTH_TEST')
    gl.Enable ('NORMALIZE')

    print("Iniciando a trackball")
    engine.model_track=gl2.trackball()
    engine.light_track=gl2.trackball()
    self.pressed=false
    engine.dragging=false
    self.light_dragging=false
    self.viewpoint=matrix.new(4,1)
    self.inv=matrix.new(4,4)

    engine.null=array.uint()
    engine.frame=0
    engine.depth={}
    engine.depth[2]=engine:tex2d(gl.DEPTH_COMPONENT,512,512,gl.DEPTH_COMPONENT,gl.UNSIGNED_SHORT)
    engine.depth[1]=engine:tex2d(gl.DEPTH_COMPONENT,256,256,gl.DEPTH_COMPONENT,gl.UNSIGNED_SHORT)
    engine.depth[0]=engine:tex2d(gl.DEPTH_COMPONENT,128,128,gl.DEPTH_COMPONENT,gl.UNSIGNED_SHORT)

    --print(gl.DEPTH_COMPONENT)

    engine.fb1=gl2.frame_buffer()
    engine.fb2=gl2.frame_buffer()

    dofile(arg[1])
end 


-- chamada quando uma tecla é pressionada
function engine.win:Keyboard(key,x,y)
    if key==27 then
        os.exit()
    end
end

function engine.win:Mouse(button,state,x,y)
    if button==glut.LEFT_BUTTON and
        state==glut.DOWN then
        engine.model_track:start_motion(x,y)
        engine.light_track:start_motion(x,y)
        self.pressed=true
        self.mod_status=self:GetModifiers()
    else
        self.pressed=false
    end
    engine.dragging=false
    self.light_dragging=false
end

function engine.win:Motion(x,y)
    if self.pressed then
        if self:ActiveShift(self.mod_status) and self:ActiveCtrl(self.mod_status) then
            engine.light_track:move_rotation(x,y)
            self.light_dragging=true
        elseif self:ActiveShift(self.mod_status) then
            engine.model_track:move_scaling(x,y)
            engine.dragging=true
        elseif self:ActiveCtrl(self.mod_status) then
            engine.model_track:move_pan(x,y)
            engine.dragging=true
        elseif self:ActiveAlt(self.mod_status) then
            engine.model_track:move_zoom(x,y)
            engine.dragging=true
        else
            engine.model_track:move_rotation(x,y)
            engine.dragging=true
        end
    end
end

function engine:bind_fb1(tex,depth)
    if tex:width()==256 then
        depth=depth or engine.depth[1]
    elseif tex:width()==512 then
        depth=depth or engine.depth[2]
    else
        depth=depth or engine.depth[0]
    end 
    self.fb1:attach_tex(gl2.COLOR_ATTACHMENT0,
        gl.TEXTURE_2D,tex:object_id(),0)
    self.fb1:attach_tex(gl2.DEPTH_ATTACHMENT,
        gl.TEXTURE_2D,depth:object_id(),0)    
    --    self.fb1:attach_rb(gl2.DEPTH_ATTACHMENT,self.rb512:object_id())
    self.fb1:check()
    self.fb1:bind()
    gl.Viewport(0,0,tex:width(),tex:height())
end

function engine:unbind_fb1()
    self.fb1:unbind()
    self.fb1:attach_tex(gl2.COLOR_ATTACHMENT0,
        gl.TEXTURE_2D,0,0)
    self.fb1:attach_rb(gl2.DEPTH_ATTACHMENT,0)
end

function engine:bind_fb2(tex) 
    if tex:width()==256 then
        depth=depth or engine.depth[1]
    elseif tex:width()==512 then
        depth=depth or engine.depth[2]
    else
        depth=depth or engine.depth[0]
    end 
    self.fb2:attach_tex(gl2.COLOR_ATTACHMENT0,
        gl.TEXTURE_2D,tex:object_id(),0)
    self.fb2:attach_tex(gl2.DEPTH_ATTACHMENT,
        gl.TEXTURE_2D,depth:object_id(),0)    
    --    self.fb1:attach_rb(gl2.DEPTH_ATTACHMENT,self.rb512:object_id())
    self.fb2:check()
    self.fb2:bind()
    gl.Viewport(0,0,tex:width(),tex:height())
end

function engine:unbind_fb2()
    self.fb2:unbind()
    self.fb2:attach_tex(gl2.COLOR_ATTACHMENT0,
        gl.TEXTURE_2D,0,0)
    self.fb2:attach_rb(gl2.DEPTH_ATTACHMENT,0)
end

function engine:load_shaders(vs,fs)
    local fsh=gl2.fragment_shader()
    fsh:load_source(fs)
    local vsh=gl2.vertex_shader()
    vsh:load_source(vs)
    local prog=gl2.program()
    prog:attach(vsh)
    prog:attach(fsh)
    prog:link()
    vsh:print_log()
    fsh:print_log()
    prog:print_log()
    return prog
end

function engine:tex2d(internalFormat, width, height, format, type, data)
    data=data or engine.null
    local tex=gl2.color_texture2d()
    tex:set(0,internalFormat,width,height,0,format,type,data:data())
   --[[ tex:bind()
    gl.TexParameter('TEXTURE_2D','TEXTURE_MIN_FILTER','NEAREST')
    gl.TexParameter('TEXTURE_2D','TEXTURE_MAG_FILTER','NEAREST')
    tex:unbind()]]
    return tex
end

function engine:tex1d(internalFormat, width, format, type, data)
    data=data or engine.null
    local tex=gl2.color_texture1d()
    tex:set(0,internalFormat,width,0,format,type,data:data())
    tex:bind()
    gl.TexParameter(gl.TEXTURE_1D,gl.TEXTURE_WRAP_S,gl.CLAMP_TO_EDGE)
    tex:unbind()
   --[[ tex:bind()
    gl.TexParameter('TEXTURE_2D','TEXTURE_MIN_FILTER','NEAREST')
    gl.TexParameter('TEXTURE_2D','TEXTURE_MAG_FILTER','NEAREST')
    tex:unbind()]]
    return tex
end

function engine:tex3d(internalFormat, width, height, depth, format, type, data)
    data = data or engine.null
    local tex = gl2.color_texture3d()
    tex:set(0, internalFormat, width, height, depth, 0, format, type, data:data())
    return tex
end

engine.win.Loop()

