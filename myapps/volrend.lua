dofile("modules.lua")
require("win")
require("cl")
require("gl2")
require("array")
require("cubic")
require("colormap")
require("transfer")

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

kernel_src= [[

const sampler_t samplersrc = CLK_NORMALIZED_COORDS_TRUE |
CLK_ADDRESS_REPEAT         |
CLK_FILTER_LINEAR;


size_t offset(size_t k, size_t i, size_t j, size_t width_, size_t height_) {
    return k*width_*height_+i*width_+j;
}

float get(__global float* data_, size_t k, size_t i, size_t j, size_t width_, size_t height_){
    return data_[offset(k,i,j,width_,height_)];
}

float set(__global float* data_, size_t k, size_t i, size_t j, float v, size_t width_, size_t height_) {
    data_[offset(k,i,j,width_,height_)]=v;
    return v;
}

float bspline(float t)
{
    t = fabs(t);
    float a = 2.0f - t;

    if (t < 1.0f)
        return 2.0f/3.0f - 0.5f*t*t*a;
    else if (t < 2.0f)
        return a*a*a / 6.0f;
    else
        return 0.0f;
}

float bsplined(float t)
{

    float c=sign(t); //sgn
    t = fabs(t);
    float a = 2.0f - t;

    if (t < 1.0f)
        return c*t*(3.0f*t-4) / 2.0f;
    else if (t < 2.0f)
        return -c*a*a / 2.0f;
    else
        return 0.0f;
}

float eval(__global float* data_, float tx, float ty, float tz, size_t width_, size_t height_, size_t depth_){
    float ttx=tx*(width_-1);
    float bx=floor(ttx);
    float deltax=ttx-bx;
    int bix=(int)bx;

    float tty=ty*(height_-1);
    float by=floor(tty);
    float deltay=tty-by;
    int biy=(int)by;

    float ttz=tz*(depth_-1);
    float bz=floor(ttz);
    float deltaz=ttz-bz;
    int biz=(int)bz;

    float v=0.0f;
    for(int k=-1;k<=2;++k) {
        int indexz=biz+k;
        if(indexz<0) indexz=-indexz;
        else if(indexz>=depth_) indexz=2*depth_-indexz-2;
        for(int j=-1;j<=2;++j) {
            int indexy=biy+j;
            if(indexy<0) indexy=-indexy;
            else if(indexy>=height_) indexy=2*height_-indexy-2;
            for(int i=-1;i<=2;++i) {
                int indexx=bix+i;
                if(indexx<0) indexx=-indexx;
                else if(indexx>=width_) indexx=2*width_-indexx-2;
                v+=get(data_, indexz, indexx, indexy, width_, height_)*bspline(deltax-(float)i)*bspline(deltay-(float)j)*bspline(deltaz-(float)k);
            }
        }
    }
    return v;
}

float3 evald(__global float* data_, float tx, float ty, float tz, size_t width_, size_t height_, size_t depth_){
    float ttx=tx*(width_-1);
    float bx=floor(ttx);
    float deltax=ttx-bx;
    int bix=(int)bx;

    float tty=ty*(height_-1);
    float by=floor(tty);
    float deltay=tty-by;
    int biy=(int)by;

    float ttz=tz*(depth_-1);
    float bz=floor(ttz);
    float deltaz=ttz-bz;
    int biz=(int)bz;

    float3 v=0.0f;
    for(int k=-1;k<=2;++k) {
        int indexz=biz+k;
        if(indexz<0) indexz=-indexz;
        else if(indexz>=depth_) indexz=2*depth_-indexz-2;
        for(int j=-1;j<=2;++j) {
            int indexy=biy+j;
            if(indexy<0) indexy=-indexy;
            else if(indexy>=height_) indexy=2*height_-indexy-2;
            for(int i=-1;i<=2;++i) {
                int indexx=bix+i;
                if(indexx<0) indexx=-indexx;
                else if(indexx>=width_) indexx=2*width_-indexx-2;
                v.x+=get(data_, indexz, indexx, indexy, width_, height_)*bsplined(deltax-(float)i)*bspline(deltay-(float)j)*bspline(deltaz-(float)k);
                v.y+=get(data_, indexz, indexx, indexy, width_, height_)*bspline(deltax-(float)i)*bsplined(deltay-(float)j)*bspline(deltaz-(float)k);
                v.z+=get(data_, indexz, indexx, indexy, width_, height_)*bspline(deltax-(float)i)*bspline(deltay-(float)j)*bsplined(deltaz-(float)k);
            }
        }
    }
    return v;
}


float f_cube(float3 w) {
    float v=w.x*w.x+w.y*w.y+w.z*w.z-w.x*w.x*w.x*w.x-w.y*w.y*w.y*w.y-w.z*w.z*w.z*w.z;
    float max_v=0.749173;
    float min_v=0.0;
    return (v-min_v)/(max_v-min_v);
}

float3 f_cube_grad(float3 p) {
    float3 grad=(float3)(
        2.0f*p.x-4.0f*p.x*p.x*p.x,
        2.0f*p.y-4.0f*p.y*p.y*p.y,
        2.0f*p.z-4.0f*p.z*p.z*p.z
    );
    return 1.0f/0.749173f*grad;
}

__kernel void kern(
    __read_only image2d_t entry,
    __read_only image2d_t exit,
    __write_only image2d_t tex,
    __read_only image1d_t transfer,
    __global float * data,
    int width,
    int height,
    int depth
    )
{
    int x = get_global_id(0);
    int y = get_global_id(1);

    int2 coords = (int2)(x,y);
    float2 tcoords = (float2)(x,y)/512.0f;

    const float Samplings = 100.0f;
    const float k = 3.0f;

    float3 a=read_imagef(entry,samplersrc,tcoords).xyz;
    float3 b=read_imagef(exit,samplersrc,tcoords).xyz;

    float3 dir=b-a;
    int steps = (int)(floor(Samplings * length(dir)));
    float3 diff1 = dir / (float)(steps);
    dir=dir*(1.0f/length(dir));
    float delta=1.0f/Samplings;

    float4 result = (float4)(0.0,0.0,0.0,1.0);

    for (int i=0; i<steps; i++) {
        //float3 p=2.0f*a-1.0f;
        float3 p=a;

        //float value=f_cube(p);
        
        float value=eval(data,p.x,p.y,p.z,width,height,depth);

        float4 color=read_imagef(transfer,samplersrc,value);

        //float3 n=f_cube_grad(p);

        //float3 n=evald(data,p.x,p.y,p.z,width,height,depth);

        //n=-n*(1.0f/max(0.000001f,length(n)));
        // color.xyz=max(0.0f,dot(n,dir))*color.xyz;

        result.w*=pow(color.w,delta);
        result.xyz+=result.w*color.xyz*delta;
        if(result.w<0.05f) {
            i=steps;
            result.w=0.0f;
        }
        a+=diff1;
    }

    write_imagef(tex, coords, result);

};

]]

ctrl_win=win.New("volrend")

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
    --[[
    colormap.rgbamap(self.transfer_array, {
        r={0,0,0,1,0},
        g={0,0,0,0,0},
        b={0,1,0,0,0},
        a={0,.3,0,.5,0},
        t={0,0.4,0.5,0.6,1}
    })
    ]]
    if self.transfer_win and self.transfer_win.buildColorMap then
        self.transfer_win:buildColorMap(self.transfer_array)
    end
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
    --[[
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
    ]]
end

-- chamada quando a janela OpenGL é criada
function ctrl_win:Init()
    print("Iniciando GLEW")
    gl2.init()

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

    self.transfer_array=array.float(1024,4)
    --[[
    colormap.rgbamap(self.transfer_array, {
        r={0,0,1,0,0},
        g={0,0,1,0,0},
        b={0,0,0,0,0},
        a={0,1,1,0,0},
        t={0,0.4,0.5,0.6,1}
    })
    ]]
    local ifmt=cl.cl_image_format()
    ifmt.image_channel_order=cl.RGBA
    ifmt.image_channel_data_type=cl.FLOAT
    local idesc=cl.cl_image_desc()
    idesc.image_type=cl.MEM_OBJECT_IMAGE1D
    --print(cl.host_get_device_info(0,gpu_id,cl.DEVICE_IMAGE2D_MAX_WIDTH))
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
