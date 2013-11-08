dofile("modules.lua")
require("win")
require("cl")
require("gl2")
require("array")
require("cubic")
require("colormap")
require("transfer")
require("matrix")

cl.host_init()
print("platform 0 info:",cl.host_get_platform_info(0,cl.PLATFORM_NAME))
print("platform 0 version:",cl.host_get_platform_info(0,cl.PLATFORM_VERSION))
print("#devices in platform 0:",cl.host_ndevices(0))
gpu_id=nil
for i=0,cl.host_ndevices(0)-1 do
    local dtype=cl.host_get_device_info(0,i,cl.DEVICE_TYPE)
    print(i,dtype)
    if string.find(dtype,"gpu") then
        gpu_id=i
    end
    print("device 0,"..i.." info:",cl.host_get_device_info(0,i,cl.DEVICE_NAME))
end
print("using device 0,"..gpu_id)
print("  extensions:",cl.host_get_device_info(0,gpu_id,cl.DEVICE_EXTENSIONS))

ctrl_win=win.New("volrend")

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

function ctrl_win:run_kernel()
    self.cmd:add_object(self.cltex_entry)
    self.cmd:add_object(self.cltex_exit)
    self.cmd:add_object(self.cltex)
    self.cmd:aquire_globject()
    self.cmd:finish()

    self.transfer_win:buildColorMap(self.transfer_array)
    self.cmd:write_image(self.transfer, true, 0,0,0,1024,1,1,0,0,
        self.transfer_array:data())
    self.cmd:write_buffer(self.volume, true, 0, self.volume_array:size_of(), self.volume_array:data())
    self.krn:arg(0,self.cltex_entry)
    self.krn:arg(1,self.cltex_exit)
    self.krn:arg(2,self.cltex)
    self.krn:arg(3,self.transfer)
    self.krn:arg(4,self.volume)
    self.krn:arg(5,self.volume_array:width())
    self.krn:arg(6,self.volume_array:height())
    self.krn:arg(7,self.volume_array:depth())
    self.krn:arg_float(8,self.viewpoint:get(0,0))
    self.krn:arg_float(9,self.viewpoint:get(1,0))
    self.krn:arg_float(10,self.viewpoint:get(2,0))
    self.cmd:range_kernel2d(self.krn,0,0,512,512)
    self.cmd:finish()
    self.cmd:add_object(self.cltex_entry)
    self.cmd:add_object(self.cltex_exit)
    self.cmd:add_object(self.cltex)
    self.cmd:release_globject()
    self.cmd:finish()
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
    print(self.inv)
    self.viewpoint=self.inv*self.viewpoint
    print(self.viewpoint)

    gl.PopMatrix()

    self:run_kernel()

    gl.TexEnv('TEXTURE_ENV_MODE','REPLACE')
    gl.Disable('LIGHTING')
    gl.MatrixMode('PROJECTION')
    gl.LoadIdentity()
    gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
    gl.LoadIdentity()
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

    --Reading the kernel's files
    kernel_config      = self:readAll("kernels/config.c")
    kernel_raySetup    = self:readAll("kernels/raySetup.c")
    kernel_depth       = self:readAll("kernels/depth.c")
    kernel_shading     = self:readAll("kernels/shading.c")
    kernel_gradient    = self:readAll("kernels/gradient.c")
    kernel_compositing = self:readAll("kernels/compositing.c")
    kernel_transfer    = self:readAll("kernels/transfer.c")
    --kernel_            = self:readAll("kernels/kernel1.c")
    --kernel_            = self:readAll("kernels/kernel2.c")
    kernel_            = self:readAll("kernels/kernel3.c")

    kernel_src = kernel_config .. kernel_raySetup .. kernel_depth .. kernel_shading .. kernel_gradient .. kernel_compositing .. kernel_transfer .. kernel_
    --kernel_src = kernel_

    self.ctx=cl.context(0)
    self.ctx:add_device(gpu_id)
    self.ctx:initGL()
    self.cmd=cl.command_queue(self.ctx,0,0)
    self.prg=cl.program(self.ctx,kernel_src)
    print(cl.host_get_error())
    self.krn=cl.kernel(self.prg, "kern")
    print(cl.host_get_error())

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
    self.cltex=cl.gl_texture2d(self.ctx,cl.MEM_WRITE_ONLY,gl.TEXTURE_2D,0,self.tex:object_id())

    self.tex_entry=gl2.color_texture2d()
    --self.tex_entry:set(0,gl.RGBA,512,512,0,gl.RGBA,gl.UNSIGNED_BYTE,null:data())
    self.tex_entry:set(0,gl.RGBA,512,512,0,gl.RGBA,gl.FLOAT,null:data())
    self.cltex_entry=cl.gl_texture2d(self.ctx,cl.MEM_READ_ONLY,gl.TEXTURE_2D,0,self.tex_entry:object_id())

    self.tex_exit=gl2.color_texture2d()
    --self.tex_exit:set(0,gl.RGBA,512,512,0,gl.RGBA,gl.UNSIGNED_BYTE,null:data())
    self.tex_exit:set(0,gl.RGBA,512,512,0,gl.RGBA,gl.FLOAT,null:data())
    self.cltex_exit=cl.gl_texture2d(self.ctx,cl.MEM_READ_ONLY,gl.TEXTURE_2D,0,self.tex_exit:object_id())

    self.rb=gl2.render_buffer()
    self.rb:set(gl.DEPTH_COMPONENT,512,512)
    self.fbo=gl2.frame_buffer()

    self.transfer_array=array.float(1024,4)

    local ifmt=cl.cl_image_format()
    ifmt.image_channel_order=cl.RGBA
    ifmt.image_channel_data_type=cl.FLOAT
    local idesc=cl.cl_image_desc()
    idesc.image_type=cl.MEM_OBJECT_IMAGE1D
    idesc.image_width=1024
    idesc.image_height=0
    idesc.image_depth=0
    idesc.image_array_size=0
    idesc.image_row_pitch=0
    idesc.image_slice_pitch=0
    idesc.num_mip_levels=0
    idesc.num_samples=0
    --idesc.buffer=null:ptr()
    print(cl.host_get_error())
    self.transfer=cl.image(self.ctx,
        cl.MEM_READ_ONLY+cl.MEM_COPY_HOST_PTR,
        ifmt,idesc, self.transfer_array:data())
    self.volume_array=array.float(32,32,32)
    self:fill_volume()
    cubic.convert(self.volume_array)
    self.volume=cl.mem(self.ctx,cl.MEM_READ_ONLY,self.volume_array:size_of())
    print(cl.host_get_error())
    self.transfer_win=transfer.New("transfer",function()
        ctrl_win:PostRedisplay()
    end)
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
