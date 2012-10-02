dofile("modules.lua")
require("iuplua")
require("iupluagl")
require("luagl")
require("luaglu")
require("array")
require("gl2")
require("cl")

gl2.init()

print(cl.host:nplatforms())
print(cl.host:ndevices(0))
print(cl.host:get_platform_info(0,cl.PLATFORM_NAME))
print(cl.host:get_device_info(0,0,cl.DEVICE_NAME))
print(cl.host:get_device_info(0,0,cl.DEVICE_EXTENSIONS))

ctx=cl.context(0)
ctx:add_device(0)
ctx:init()
cmd=cl.command_queue(ctx,0,0)

kernel_src= [[
__kernel void turn_gray(__write_only image2d_t bmp)
{

   int x = get_global_id(0);
   int y = get_global_id(1); 

   int2 coords = (int2)(x,y);
   //Attention to RGBA order
	 float4 val=(float4)(0.5f,0.5f,0.5f,1.0f);
   write_imagef(bmp, coords, val);
};
]]

prg=cl.program(ctx,kernel_src)
krn=cl.kernel(prg, "turn_gray")

cnv = iup.glcanvas { buffer="DOUBLE", rastersize = "480x480" }
dlg = iup.dialog {cnv; title="spline1d"}

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
	cmd:add_object(self.cltex)      
	cmd:aquire_globject()
	cmd:finish()
	krn:arg(0,self.cltex)
	cmd:range_kernel2d(krn,0,0,480,480,1,1)
	cmd:finish()
	cmd:add_object(self.cltex)      
	cmd:release_globject()
	cmd:finish()
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
	self.buff=array.array_float(480,480)
	for i=1,480 do 
		for j=1,480 do
			self.buff:set(i-1,j-1,((i+j) % 256)/256);
		end
	end
	self.tex=gl2.color_texture2d()
	self.tex:set(0,1,480,480,0,gl.LUMINANCE,gl.FLOAT,self.buff:data())
	self.cltex=cl.gl_texture2d(ctx,cl.MEM_WRITE_ONLY,gl.TEXTURE_2D,0,self.tex:object_id())
end

-- chamada quando uma tecla é pressionada
function cnv:k_any(c)
  if c == iup.K_ESC then
  -- sai da aplicação
    iup.ExitLoop()
  end
end

-- exibe a janela
dlg:show()
-- entra no loop de eventos
iup.MainLoop()
