dofile("modules.lua")
require("gl2")
require("tcl")
require("luagl")
require("luaglu")
require("cl")
require("array")


cl.host_init()

print(cl.host_nplatforms())
print(cl.host_ndevices(0))
print(cl.host_get_platform_info(0,cl.PLATFORM_NAME))
print(cl.host_get_device_info(0,1,cl.DEVICE_NAME))
print(cl.host_get_device_info(0,1,cl.DEVICE_EXTENSIONS))

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
    float4 c=read_imagef(src,samplersrc,tcoords);
    //float4 c=(float4)(1.0,0.0,0.0,0.0);
    write_imagef(dst, coords, c);
};
]]


-- chamada quando a janela OpenGL é redimensionada
function ReshapeCallback(win)
    print("reshape")
    width=tcl(win.." cget -width")+0
    height=tcl(win.." cget -height")+0
    gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela
    gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
    gl.LoadIdentity()                -- carrega a matriz identidade
    gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
    gl.LoadIdentity()                -- carrega a matriz identidade
end

function DisplayCallback(win)
    --	print("display")
    gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
    gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
    gl.LoadIdentity()   

    cmd:add_object(cltexsrc)
    cmd:add_object(cltexdst)
    cmd:aquire_globject()
    cmd:finish()
    krn:arg_float(0,t)
    krn:arg(1,cltexsrc)
    krn:arg(2,cltexdst)
    cmd:range_kernel2d(krn,0,0,512,512,1,1)
    --	print(cl.host_get_error())
    --	print("finish")
    cmd:finish()
    --	print("end")
    --	print(cl.host_get_error())
    cmd:add_object(cltexsrc)
    cmd:add_object(cltexdst)
    cmd:release_globject()
    cmd:finish()

    tex:bind()
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
    t=t+0.1
    --	print(t)
    -- troca buffers
    tcl(win.." swapbuffers")
end

-- chamada quando a janela OpenGL é criada
function CreateCallback(win)
    gl2.init()
    gl.ClearColor(0.0,0.0,0.0,0.5)                  -- cor de fundo preta
    gl.ClearDepth(1.0)                              -- valor do z-buffer
    gl.Disable('DEPTH_TEST')                         -- habilita teste z-buffer
    gl.Enable('CULL_FACE')
    gl.ShadeModel('FLAT')

    ctx=cl.context(0)
    ctx:add_device(1)
    ctx:initGL()
    cmd=cl.command_queue(ctx,0,0)
    prg=cl.program(ctx,kernel_src)
    krn=cl.kernel(prg, "kern")

    image=array.byte(512,512,4)
    image:read("mandril.512x512.rgba")
    texsrc=gl2.color_texture2d()
    texsrc:set(0,gl.RGBA,512,512,0,gl.RGBA,gl.UNSIGNED_BYTE,image:data())

    cltexsrc=cl.gl_texture2d(ctx,cl.MEM_READ_ONLY,gl.TEXTURE_2D,0,texsrc:object_id())
    print(cl.host_get_error())

    imagedst=array.byte(512,512,4)
    tex=gl2.color_texture2d()
    print(tex:object_id())
    tex:set(0,gl.RGBA,512,512,0,gl.RGBA,gl.UNSIGNED_BYTE,imagedst:data())
    cltexdst=cl.gl_texture2d(ctx,cl.MEM_WRITE_ONLY,gl.TEXTURE_2D,0, tex:object_id())
    print(cl.host_get_error())

    t=0
end


function TimerCallback(win)
    tcl(win.." postredisplay")
end

tcl [[

package require Togl 2.1
lua_proc DisplayCallback
lua_proc ReshapeCallback
lua_proc CreateCallback
lua_proc TimerCallback
togl .hello -time 20 -width 512 -height 512 \
-double true -depth true \
-createproc CreateCallback \
-reshapeproc ReshapeCallback \
-timercommand TimerCallback \
-displayproc DisplayCallback 
pack .hello
bind . <Key-Escape> { exit }

]]

TkMainLoop()
