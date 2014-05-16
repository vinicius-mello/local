dofile("modules.lua")
require("win")
require("gl2")
require("array")
require("cubic")
require("colormap")
require("transfer")
require("matrix")

ctrl_win=win.New("volrend_glsl")

function ctrl_win:readAll(file)
    local f = io.open(file, "rb")
    local content = f:read("*all")
    f:close()
    return content
end

function ctrl_win:Reshape(width, height)
    gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela

    self.width=width
    self.height=height

    gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
    gl.LoadIdentity()                -- carrega a matriz identidade
    self.radius=0.705
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

function ctrl_win:draw_cube()
    gl.Disable('LIGHTING')
    gl.Begin('QUADS')
    gl.Color(0,0,0)
    gl.Vertex(0,0,0)
    gl.Color(0,1,0)
    gl.Vertex(0,1,0)
    gl.Color(1,1,0)
    gl.Vertex(1,1,0)
    gl.Color(1,0,0)
    gl.Vertex(1,0,0)
    gl.Color(0,0,1)
    gl.Vertex(0,0,1)
    gl.Color(1,0,1)
    gl.Vertex(1,0,1)
    gl.Color(1,1,1)
    gl.Vertex(1,1,1)
    gl.Color(0,1,1)
    gl.Vertex(0,1,1)
    gl.Color(1,0,0)
    gl.Vertex(1,0,0)
    gl.Color(1,1,0)
    gl.Vertex(1,1,0)
    gl.Color(1,1,1)
    gl.Vertex(1,1,1)
    gl.Color(1,0,1)
    gl.Vertex(1,0,1)
    gl.Color(0,0,0)
    gl.Vertex(0,0,0)
    gl.Color(0,0,1)
    gl.Vertex(0,0,1)
    gl.Color(0,1,1)
    gl.Vertex(0,1,1)
    gl.Color(0,1,0)
    gl.Vertex(0,1,0)

    gl.Color(0,1,0)
    gl.Vertex(0,1,0)
    gl.Color(0,1,1)
    gl.Vertex(0,1,1)
    gl.Color(1,1,1)
    gl.Vertex(1,1,1)
    gl.Color(1,1,0)
    gl.Vertex(1,1,0)

    gl.Color(0,0,0)
    gl.Vertex(0,0,0)
    gl.Color(1,0,0)
    gl.Vertex(1,0,0)
    gl.Color(1,0,1)
    gl.Vertex(1,0,1)
    gl.Color(0,0,1)
    gl.Vertex(0,0,1)
    gl.End()
    gl.Enable('LIGHTING')
end

function ctrl_win:draw_textures()
    gl.ClearColor(0.0,0.0,0.0,0.0)
    self.fbo:attach_tex(gl2.COLOR_ATTACHMENT0,
        gl.TEXTURE_2D,self.tex_exit:object_id(),0)
    self.fbo:attach_rb(gl2.DEPTH_ATTACHMENT,self.rb:object_id())
    self.fbo:check()

    self.fbo:bind()
    gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
    gl.FrontFace('CW')
    self:draw_cube()
    gl.Flush()
    self.fbo:unbind()

    self.fbo:attach_tex(gl2.COLOR_ATTACHMENT0,
        gl.TEXTURE_2D,0,0)
    self.fbo:attach_rb(gl2.DEPTH_ATTACHMENT,0)

    self.fbo:attach_tex(gl2.COLOR_ATTACHMENT0,
        gl.TEXTURE_2D,self.tex_entry:object_id(),0)
    self.fbo:attach_rb(gl2.DEPTH_ATTACHMENT,self.rb:object_id())
    self.fbo:check()

    self.fbo:bind()
    gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
    gl.FrontFace('CCW')
    self:draw_cube()
    gl.Flush()
    self.fbo:unbind()

    self.fbo:attach_tex(gl2.COLOR_ATTACHMENT0,
        gl.TEXTURE_2D,0,0)
    self.fbo:attach_rb(gl2.DEPTH_ATTACHMENT,0)
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

function ctrl_win:run_shader()
    gl.ClearColor(1.0,1.0,1.0,1.0)
 

    --gl2.active_texture(2)
 
    self.fbo:attach_tex(gl2.COLOR_ATTACHMENT0,
        gl.TEXTURE_2D,self.tex:object_id(),0)
    self.fbo:attach_rb(gl2.DEPTH_ATTACHMENT,self.rb:object_id())
    self.fbo:check()

    self.fbo:bind()
    
    
    gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
 
    self.prog:bind()

    gl2.active_texture(0)
    self.tex_entry:bind()
    gl2.active_texture(1)
    self.tex_exit:bind()

    self.prog:uniformi("front",0)
    self.prog:uniformi("back",1)
    

    
    --gl.Color(1,0,0)
    gl.Begin('QUADS')
    gl.Vertex(-1,-1)
    gl.Vertex(1,-1)
    gl.Vertex(1,1)
    gl.Vertex(-1,1)
    gl.End()
    gl.Flush()

 --   gl2.draw_triangles(self.idx)
    self.prog:unbind()
    --gl2.disable_vertex_attrib_array(1)
    --gl.DisableClientState('VERTEX_ARRAY')
      
 
    self.fbo:unbind()
    self.fbo:attach_tex(gl2.COLOR_ATTACHMENT0,
        gl.TEXTURE_2D,0,0)
    self.fbo:attach_rb(gl2.DEPTH_ATTACHMENT,0)
    
end

-- chamada quando a janela OpenGL necessita ser desenhada
function ctrl_win:Display()
    gl.ClearColor(0.0,0.0,0.0,0.0)                  -- cor de fundo preta
    -- limpa a tela e o z-buffer
    gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
    gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
    gl.LoadIdentity()                -- carrega a matriz identidade
    glu.Perspective(60,self.width/self.height,0.01,1000)
    gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
    gl.LoadIdentity()
    glu.LookAt(0,0,4*self.radius,0,0,0,0,1,0)

    gl.PushMatrix()
    self.light_track:transform()
    gl.Light ('LIGHT0', 'POSITION',{0,0,1000,1})
    gl.PopMatrix()

    gl.PushMatrix()
    self.model_track:transform()
    gl.Translate(-0.5,-0.5,-0.5)

    self:draw_textures()
    gl.PopMatrix()

    gl.PushMatrix()
    self.viewpoint:set(0,0,0)
    self.viewpoint:set(1,0,0)
    self.viewpoint:set(2,0,1)
    self.viewpoint:set(3,0,1)
    gl.Translate(0.5,0.5,0.5)
    self.model_track:inverse_transform()
    gl2.GetModelviewMatrix(self.inv.array:data())
    self.inv=self.inv:transpose()
    --print(self.inv)
    self.viewpoint=self.inv*self.viewpoint
    --print(self.viewpoint)

    gl.PopMatrix()
    
    gl.TexEnv('TEXTURE_ENV_MODE','REPLACE')
    gl.Disable('LIGHTING')
    gl.MatrixMode('PROJECTION')
    gl.LoadIdentity()
    gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
    gl.LoadIdentity()
    self:run_shader()

    gl2.active_texture(0)
    gl.Enable('TEXTURE_2D')
    self.tex:bind()
    gl.Begin('QUADS')
    gl.TexCoord(0,0)
    gl.Vertex(-1,-1)
    gl.TexCoord(1,0)
    gl.Vertex(1,-1)
    gl.TexCoord(1,1)
    gl.Vertex(1,1)
    gl.TexCoord(0,1)
    gl.Vertex(-1,1)
    gl.End()
    self.tex:unbind()
    gl.Disable('TEXTURE_2D') 
    
    gl.Enable('LIGHTING')
end

-- chamada quando a janela OpenGL é criada
function ctrl_win:Init()
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
    self.viewpoint=matrix.new(4,1)
    self.inv=matrix.new(4,4)

    local null=array.uint()
    self.tex=gl2.color_texture2d()
    self.tex:set(0,gl.RGBA,512,512,0,gl.RGBA,gl.UNSIGNED_BYTE,null:data())

    self.tex_entry=gl2.color_texture2d()
    --self.tex_entry:set(0,gl.RGBA,512,512,0,gl.RGBA,gl.UNSIGNED_BYTE,null:data())
    self.tex_entry:set(0,gl.RGBA,512,512,0,gl.RGBA,gl.FLOAT,null:data())

    self.tex_exit=gl2.color_texture2d()
    --self.tex_exit:set(0,gl.RGBA,512,512,0,gl.RGBA,gl.UNSIGNED_BYTE,null:data())
    self.tex_exit:set(0,gl.RGBA,512,512,0,gl.RGBA,gl.FLOAT,null:data())

    self.rb=gl2.render_buffer()
    self.rb:set(gl.DEPTH_COMPONENT,512,512)
    self.fbo=gl2.frame_buffer()

    self.transfer_array=array.float(1024,4)

    self.volume_array=array.float(32,32,32)
    self:fill_volume()
    cubic.convert(self.volume_array)

    print("Configurando os shaders")
    self.fsh=gl2.fragment_shader()
    self.fsh:load_source("volrend.frag")
    self.vsh=gl2.vertex_shader()
    self.vsh:load_source("volrend.vert")
    self.prog=gl2.program()
    self.prog:attach(self.vsh)
    self.prog:attach(self.fsh)
    --self.prog:bind_attribute(1,"aCorner")
    self.prog:link()
    self.vsh:print_log()
    self.fsh:print_log()
    self.prog:print_log()
 --[[   self.vtx=array.float(4,2)
    self.vtx:set(0,0,-1)
    self.vtx:set(0,1,-1)
    self.vtx:set(1,0,1)
    self.vtx:set(1,1,-1)
    self.vtx:set(2,0,1)
    self.vtx:set(2,1,1)
    self.vtx:set(3,0,-1)
    self.vtx:set(3,1,1)
    self.idx=array.int(2,4)
    self.idx:set(0,0,0)
    self.idx:set(0,1,1)
    self.idx:set(0,2,2)
    self.idx:set(1,0,0)
    self.idx:set(1,1,2)
    self.idx:set(1,2,3)

    gl.EnableClientState('VERTEX_ARRAY')
    gl2.vertex_array(self.vtx)
    gl.DisableClientState('VERTEX_ARRAY')
    ]]
    self.pars=bar.New("teste")

end

function ctrl_win:fill_volume()
    local i,j,k
    local x,y,z
    local max_v=0.749173;
    local min_v=0.0;
    for i=0,self.volume_array:width()-1 do
        x=2*i/(self.volume_array:width()-1)-1
        for j=0,self.volume_array:height()-1 do
            y=2*j/(self.volume_array:height()-1)-1
            for k=0,self.volume_array:depth()-1 do
                z=2*k/(self.volume_array:depth()-1)-1
                local v=x*x+y*y+z*z-x*x*x*x-y*y*y*y-z*z*z*z
                self.volume_array:set(k,i,j, (v-min_v)/(max_v-min_v))
            end
        end
    end
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
