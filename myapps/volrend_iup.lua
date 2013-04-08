dofile("modules.lua")
require("iuplua")
require("iupluagl")
require("luagl")
require("luaglu")
require("cl")
require("gl2")
require("array")

cl.host_init()
print("platform 0 info:",cl.host_get_platform_info(0,cl.PLATFORM_NAME))
print("#devices in platform 0:",cl.host_ndevices(0))
gpu_id=nil
for i=0,cl.host_ndevices(0)-1 do
    local dtype=cl.host_get_device_info(0,i,cl.DEVICE_TYPE)
    if string.find(dtype,"gpu") then
        gpu_id=i
    end
    print("device 0,"..i.." info:",cl.host_get_device_info(0,i,cl.DEVICE_NAME))
end
print("using device 0,"..gpu_id)
print("  extensions:",cl.host_get_device_info(0,gpu_id,cl.DEVICE_EXTENSIONS))

kernel_src= [[

const sampler_t samplersrc = CLK_NORMALIZED_COORDS_TRUE |
CLK_ADDRESS_REPEAT         |
CLK_FILTER_LINEAR;

float density(float3 p) {
  float x=p.x*p.x;
  float y=p.y*p.y;
  return x*x+y*y/2.0f;
}

float3 grad_density(float3 p) {
  return (float3)(2.0f*p.x*p.x*p.x,2.0f*p.y*p.y*p.y,0.0f);
}

__kernel void kern(__read_only image2d_t entry,
    __read_only image2d_t exit,  __write_only image2d_t tex)
{
    const float Samplings = 25.0;

    int x = get_global_id(0);
    int y = get_global_id(1);

    int2 coords = (int2)(x,y);
    float2 tcoords = (float2)(x,y)/512.0f;

    float3 a=read_imagef(entry,samplersrc,tcoords).xyz;
    float3 b=read_imagef(exit,samplersrc,tcoords).xyz;

    float3 dir=b-a;
    int steps = (int)(floor(Samplings * length(dir)));
    float3 diff1 = dir / (float)(steps);
    
    float4 result = (float4)(0.0);

    for (int i=0; i<steps; i++) {
        float3 p=2.0f*a-1.0f;
		
		p=transform(p);
		
   		float value=density(p);
		
        if(value<0.005) {
			float3 n=grad_density(p);
			n=n*(1.0f/length(n));
			
			n=transform_normal(n);			
			
			dir=-dir*(1.0f/length(dir));
			result=(float4)(dot(n,dir),0.0f,0.0f,0.0f);
            break;
        }
        a+=diff1;
    }

    write_imagef(tex, coords, result);
};
]]

ctrl_win = iup.glcanvas { buffer="DOUBLE", rastersize = "480x480" }
dlg = iup.dialog { iup.vbox {ctrl_win} ; title="volrend"}

function ctrl_win:resize_cb(width, height)
	iup.GLMakeCurrent(self)
    gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela

    self.width = width
    self.height = height

    gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
    gl.LoadIdentity()                -- carrega a matriz identidade
    self.radius = 0.705
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
    self.krn:arg(0,self.cltex_entry)
    self.krn:arg(1,self.cltex_exit)
    self.krn:arg(2,self.cltex)
    self.cmd:range_kernel2d(self.krn,0,0,512,512,1,1)
    self.cmd:finish()
    self.cmd:add_object(self.cltex_entry)
    self.cmd:add_object(self.cltex_exit)
    self.cmd:add_object(self.cltex)
    self.cmd:release_globject()
    self.cmd:finish()
end

-- chamada quando a janela OpenGL necessita ser desenhada
function ctrl_win:action(x, y)
	iup.GLMakeCurrent(self)
	
    gl.ClearColor(0.0,0.0,0.0,0.0)                  -- cor de fundo preta
    -- limpa a tela e o z-buffer
    gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
    gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
    gl.LoadIdentity()                -- carrega a matriz identidade
    glu.Perspective(60,self.width/self.height,0.01,1000)
    gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
    gl.LoadIdentity()
    glu.LookAt(0,0,4*self.radius,0,0,0,0,1,0)
	
	-- Adcionado - Begin
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
	-- Adicionado - End

    gl.PushMatrix()
    self.light_track:transform()
    gl.Light ('LIGHT0', 'POSITION',{0,0,1000,1})
    gl.PopMatrix()

    gl.PushMatrix()
    self.model_track:transform()
    gl.Translate(-0.5,-0.5,-0.5)
    self:draw_textures()
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
	
	-- troca buffers
    iup.GLSwapBuffers(self)
end

-- chamada quando a janela OpenGL é criada
function ctrl_win:map_cb()
	iup.GLMakeCurrent(self)
	
    print("Iniciando GLEW")
    gl2.init()

    self.ctx=cl.context(0)
    self.ctx:add_device(gpu_id)
    self.ctx:initGL()
    self.cmd=cl.command_queue(self.ctx,0,0)
    self.prg=cl.program(self.ctx,kernel_src)
    self.krn=cl.kernel(self.prg, "kern")

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

    local null=array.uint()
    self.tex=gl2.color_texture2d()
    self.tex:set(0,gl.RGBA,512,512,0,gl.RGBA,gl.UNSIGNED_BYTE,null:data())
    self.cltex=cl.gl_texture2d(self.ctx,cl.MEM_WRITE_ONLY,gl.TEXTURE_2D,0,self.tex:object_id())

    self.tex_entry=gl2.color_texture2d()
    self.tex_entry:set(0,gl.RGBA,512,512,0,gl.RGBA,gl.UNSIGNED_BYTE,null:data())
    self.cltex_entry=cl.gl_texture2d(self.ctx,cl.MEM_READ_ONLY,gl.TEXTURE_2D,0,self.tex_entry:object_id())

    self.tex_exit=gl2.color_texture2d()
    self.tex_exit:set(0,gl.RGBA,512,512,0,gl.RGBA,gl.UNSIGNED_BYTE,null:data())
    self.cltex_exit=cl.gl_texture2d(self.ctx,cl.MEM_READ_ONLY,gl.TEXTURE_2D,0,self.tex_exit:object_id())

    self.rb=gl2.render_buffer()
    self.rb:set(gl.DEPTH_COMPONENT,512,512)
    self.fbo=gl2.frame_buffer()
end

-- chamada quando uma tecla é pressionada
function ctrl_win:k_any(c)
    if c == iup.K_ESC then
		iup.ExitLoop()
        --os.exit()
    end
	ctrl_win:action(0,0)
end

function ctrl_win:button_cb(but,pressed,x,y,status)
	iup.GLMakeCurrent(self)
    if pressed == 1 then
        self.model_track:start_motion(x,y)
        self.light_track:start_motion(x,y)
        self.pressed = true
    else
        self.pressed = false
    end
    self.dragging = false
    self.light_dragging = false
	ctrl_win:action(0,0)
end

function ctrl_win:motion_cb(x,y,status)
	iup.GLMakeCurrent(self)
    if self.pressed then
        if iup.isshift(status) and iup.iscontrol(status) then
            self.light_track:move_rotation(x,y)
            self.light_dragging = true
        elseif iup.isshift(status) then
            self.model_track:move_scaling(x,y)
            self.dragging = true
        elseif iup.iscontrol(status) then
            self.model_track:move_pan(x,y)
            self.dragging = true
        elseif iup.isalt(status) then
            self.model_track:move_zoom(x,y)
            self.dragging = true
        else
            self.model_track:move_rotation(x,y)
            self.dragging = true
        end
		ctrl_win:action(0,0)
    end
end

-- exibe a janela
dlg:show()
--filter_dlg:show()
-- entra no loop de eventos
iup.MainLoop()
