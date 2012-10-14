dofile("modules.lua")
require("iuplua")
require("iupluagl")
require("luagl")
require("luaglu")
require("array")
require("gl2")
require("luail")
require("luailut")
require("cl")

il=luail
ilut=luailut
gl2.init()
cl.host_init()
il.Init()
ilut.Init()
ilut.Enable(ilut.OPENGL_CONV)
ilut.Renderer(ilut.OPENGL)

print(cl.host_nplatforms())
print(cl.host_ndevices(0))
print(cl.host_get_platform_info(0,cl.PLATFORM_NAME))
print(cl.host_get_device_info(0,0,cl.DEVICE_NAME))
print(cl.host_get_device_info(0,0,cl.DEVICE_EXTENSIONS))



kernel_src= [[
#pragma OPENCL EXTENSION cl_amd_printf : enable

const sampler_t samplersrc = CLK_NORMALIZED_COORDS_TRUE |
                           CLK_ADDRESS_REPEAT         |
                           CLK_FILTER_LINEAR;

__kernel void kern(float t, __read_only image2d_t src, __write_only image2d_t dst)
{

   int x = get_global_id(0);
   int y = get_global_id(1); 
	 //printf("%d,%d\n",x,y);
   int2 coords = (int2)(x,y);
   float2 tcoords = (float2)(x,y);
   tcoords.x=tcoords.x/512.0+t*0.1;
   tcoords.y=tcoords.y/512.0+t*0.3;
   //Attention to RGBA order
   uint4 c=read_imageui(src,samplersrc,tcoords);
   //float4 c=(float4)(1.0,0.0,0.0,0.0);
   write_imageui(dst, coords, c);
};
]]

cnv = iup.glcanvas { buffer="DOUBLE", rastersize = "512x512" }
dlg = iup.dialog {cnv; title="clgl"}

function cnv:resize_cb(width, height)
	--print("resize")
  iup.GLMakeCurrent(self)
  gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela
	self.width=width
	self.height=height
  gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
  gl.LoadIdentity()                -- carrega a matriz identidade
  gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
  gl.LoadIdentity()                -- carrega a matriz identidade
end

function cnv:action(x, y)
  iup.GLMakeCurrent(self)
  gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
  gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
	gl.LoadIdentity()   
	self.cmd:add_object(self.cltexsrc)      
	self.cmd:add_object(self.cltexdst)      
	self.cmd:aquire_globject()
	self.cmd:finish()
	self.krn:arg_float(0,self.t)
	self.krn:arg(1,self.cltexsrc)
	self.krn:arg(2,self.cltexdst)
	self.cmd:range_kernel2d(self.krn,0,0,512,512,1,1)
	print(cl.host_get_error())
	self.cmd:finish()
	print(cl.host_get_error())
	self.cmd:add_object(self.cltexsrc)      
	self.cmd:add_object(self.cltexdst)      
	self.cmd:release_globject()
	self.cmd:finish()
	gl.Enable('TEXTURE_2D')
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
	gl.Disable('TEXTURE_2D')
  -- troca buffers
  iup.GLSwapBuffers(self)
	self.t=self.t+0.1
	print(self.t)
end

-- chamada quando a janela OpenGL é criada
function cnv:map_cb()
	--print("map")
  iup.GLMakeCurrent(self)
  gl.ClearColor(0.0,0.0,0.0,0.5)                  -- cor de fundo preta
  gl.ClearDepth(1.0)                              -- valor do z-buffer
  gl.Disable('DEPTH_TEST')                         -- habilita teste z-buffer
  gl.Enable('CULL_FACE')                         
  gl.ShadeModel('FLAT')

	self.ctx=cl.context(0)
	self.ctx:add_device(0)
	self.ctx:initGL()
	self.cmd=cl.command_queue(self.ctx,0,0)
	self.prg=cl.program(self.ctx,kernel_src)
	self.krn=cl.kernel(self.prg, "kern")

	local texid=ilut.GLLoadImage("mandril.png")
	print(texid)
	self.cltexsrc=cl.gl_texture2d(self.ctx,cl.MEM_READ_ONLY,gl.TEXTURE_2D,0,texid)
	print(cl.host_get_error())

	local null=array.array_uint()
	self.tex=gl2.color_texture2d()
	print(self.tex:object_id())
	self.tex:set(0,gl.RGBA,512,512,0,gl.RGBA,gl.UNSIGNED_BYTE,null:data())
	self.cltexdst=cl.gl_texture2d(self.ctx,cl.MEM_WRITE_ONLY,gl.TEXTURE_2D,0, self.tex:object_id())
	print(cl.host_get_error())
	self.t=0
end

-- chamada quando uma tecla é pressionada
function cnv:k_any(c)
  if c == iup.K_ESC then
  -- sai da aplicação
    iup.ExitLoop()
  end
end

timer = iup.timer{time=1}

function timer:action_cb()
  cnv:action(0,0)
  return iup.DEFAULT
end


-- exibe a janela
dlg:show()
timer.run = "YES"
-- entra no loop de eventos
iup.MainLoop()
