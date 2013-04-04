dofile("modules.lua")
require("gl2")
require("cl")
require("win")
require("array")
require("cubic")

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
    //uint4 c=read_imageui(src,samplersrc,tcoords);
    float4 c=read_imagef(src,samplersrc,tcoords);
    //float4 c=(float4)(1.0,0.0,0.0,0.0);
    //write_imageui(dst, coords, c);
    write_imagef(dst, coords, c);
};
]]

ctrl_win=win.New("clgl")

function ctrl_win:Reshape(width, height)
    gl.Viewport(0, 0, width, height)
    self.w=width
    self.h=height
    gl.MatrixMode('PROJECTION')
    gl.LoadIdentity()
    gl.MatrixMode('MODELVIEW')
    gl.LoadIdentity()
end

function ctrl_win:Display()
    gl.ClearColor(0.0,0.0,0.0,0.0)
    gl.ClearDepth(1.0)
    gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
    gl.MatrixMode('MODELVIEW')
    gl.LoadIdentity()
    self.cmd:add_object(self.cltexsrc)
    self.cmd:add_object(self.cltexdst)
    self.cmd:aquire_globject()
    self.cmd:finish()
    self.krn:arg_float(0,self.t)
    self.krn:arg(1,self.cltexsrc)
    self.krn:arg(2,self.cltexdst)
    self.cmd:range_kernel2d(self.krn,0,0,512,512,1,1)
    self.cmd:finish()
    self.cmd:add_object(self.cltexsrc)
    self.cmd:add_object(self.cltexdst)
    self.cmd:release_globject()
    self.cmd:finish()
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
    self.t=self.t+0.1
    print(self.t)
end

function ctrl_win:draw_texture()
    self.rb=gl2.render_buffer()
    self.rb:set(gl.DEPTH_COMPONENT,512,512)
    self.fbo=gl2.frame_buffer()
    self.fbo:attach_tex(gl2.COLOR_ATTACHMENT0,
        gl.TEXTURE_2D,self.texsrc:object_id(),0)
    self.fbo:attach_rb(gl2.DEPTH_ATTACHMENT,self.rb:object_id())
    self.fbo:check()
    self.fbo:bind()
    gl.ClearColor(0.0,0.0,0.0,0.0)
    gl.ClearDepth(1.0)
    gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
    gl.Begin('TRIANGLES')
    gl.Vertex(-0.5,-0.5)
    gl.Vertex(0.5,-0.5)
    gl.Vertex(0.0,0.5)
    gl.End()
    gl.Flush()
    self.fbo:unbind()
    --self.texsrc:bind()
    --gl2.generate_mipmap(gl.TEXTURE_2D)
    --self.texsrc:unbind()
end

function ctrl_win:Init()
    gl2.init()
    gl.Disable('DEPTH_TEST')
    gl.Enable('CULL_FACE')
    gl.ShadeModel('FLAT')

    self.ctx=cl.context(0)
    self.ctx:add_device(gpu_id)
    self.ctx:initGL()
    self.cmd=cl.command_queue(self.ctx,0,0)
    self.prg=cl.program(self.ctx,kernel_src)
    self.krn=cl.kernel(self.prg, "kern")

    --self.image=array.byte(512,512,4)
    --self.image:read("tiling_3_5.512x512.rgba")
    local null=array.uint()
    self.texsrc=gl2.color_texture2d()
    --self.texsrc:set(0,gl.RGBA,512,512,0,gl.RGBA,gl.UNSIGNED_BYTE,self.image:data())
    self.texsrc:set(0,gl.RGBA,512,512,0,gl.RGBA,gl.UNSIGNED_BYTE,null:data())
    self:draw_texture()
    self.cltexsrc=cl.gl_texture2d(self.ctx,cl.MEM_READ_ONLY,gl.TEXTURE_2D,0,self.texsrc:object_id())
    print(cl.host_get_error())

    self.tex=gl2.color_texture2d()
    self.tex:set(0,gl.RGBA,512,512,0,gl.RGBA,gl.UNSIGNED_BYTE,null:data())
    self.cltexdst=cl.gl_texture2d(self.ctx,cl.MEM_WRITE_ONLY,gl.TEXTURE_2D,0,self.tex:object_id())
    print(cl.host_get_error())
    self.t=0
end

function ctrl_win:Keyboard(key,x,y)
    if key==27 then
        os.exit()
    end
end

glut.IdleFunc(function() ctrl_win:PostRedisplay() end)

win.Loop()
