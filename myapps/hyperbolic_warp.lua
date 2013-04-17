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

__kernel void init_vtx(int gr, __global double2 * vtx)
{
   int i = get_global_id(0);
   int j = get_global_id(1);
   double grd=(double)gr;
   double x=2.0*((double)i)/grd-1.0;
   double y=2.0*((double)j)/grd-1.0;
   double2 c=(double2)(x,y);
   vtx[i*(gr+1)+j]=c;
};

]]

ctrl_win=win.New("test")


ctrl_win.lines={}
ctrl_win.lines.x={}
ctrl_win.lines.y={}
ctrl_win.splines={}
ctrl_win.splines.x={}
ctrl_win.splines.y={}
ctrl_win.max_ctrl=6
ctrl_win.mesh_gr=100


function ctrl_win:Reshape(width, height)
    gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela
    gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
    gl.LoadIdentity()                -- carrega a matriz identidade
    gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
    gl.LoadIdentity()                -- carrega a matriz identidade
    self.w=width
    self.h=height
    self.px=math.max(2/width,2/height)
end

-- chamada quando a janela OpenGL necessita ser desenhada
function ctrl_win:Display()
    -- limpa a tela e o z-buffer
    local i
    gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
    gl.PointSize(5.0)
    gl.Color(1,1,0)
    gl.Begin('POINTS')
    for i=1,#self.lines.x do
        local j
        for j=0,self.max_ctrl do
            local x=self.lines.x[i]:get(j)
            local y=self.lines.y[i]:get(j)
            gl.Vertex(x,y)
        end
    end
    gl.End()
    if self.drag=="new" then
        gl.Color(0,1,1)
        gl.Begin('LINES')
        gl.Vertex(self.origin_x, self.origin_y)
        gl.Vertex(self.target_x, self.target_y)
        gl.End()
    end
    gl.Color(1,1,0)
    for i=1,#self.splines.x do
        local j
        gl.Begin('LINE_STRIP')
        for j=0,64 do
            local t=j/64
            local x=cubic.eval(self.splines.x[i],t)
            local y=cubic.eval(self.splines.y[i],t)
            gl.Vertex(x,y)
        end
        gl.End()
    end
    gl.Enable('TEXTURE_2D')
    self.texsrc:bind()
    gl.EnableClientState('VERTEX_ARRAY')
    gl.EnableClientState('TEXTURE_COORD_ARRAY')
    gl2.draw_quads(self.mesh_idx)
    gl.DisableClientState('VERTEX_ARRAY')
    gl.DisableClientState('TEXTURE_COORD_ARRAY')
    gl.Disable('TEXTURE_2D')
end

function ctrl_win:new_line()
    local i
    local size=#self.lines.x+1
    self.lines.x[size]=array.double(self.max_ctrl+1)
    self.lines.y[size]=array.double(self.max_ctrl+1)
    self.splines.x[size]=array.double(self.max_ctrl+1)
    self.splines.y[size]=array.double(self.max_ctrl+1)
    for i=0,self.max_ctrl do
        local t=i/self.max_ctrl
        self.lines.x[size]:set(i,self.origin_x*(1-t)+self.target_x*t)
        self.lines.y[size]:set(i,self.origin_y*(1-t)+self.target_y*t)
    end
    self.splines.x[size]:copy(self.lines.x[size])
    self.splines.y[size]:copy(self.lines.y[size])
    cubic.convert(self.splines.x[size])
    cubic.convert(self.splines.y[size])
end

function ctrl_win:find(x,y)
    local i
    for i=1,#self.lines.x do
        local j
        for j=0,self.max_ctrl do
            local ctrl_x=self.lines.x[i]:get(j)
            local ctrl_y=self.lines.y[i]:get(j)
            if math.abs(ctrl_x-x)<3*self.px
                and math.abs(ctrl_y-y)<3*self.px then
                return i,j
            end
        end
    end
    return 0,0
end

function ctrl_win:normalize(x,y)
    x=2*x/self.w-1
    y=1-2*y/self.h
    local norm=math.sqrt(x*x+y*y)
    if norm>1 then
        x=x/norm
        y=y/norm
    end
    return x,y
end

function ctrl_win:Mouse(button,state,x,y)
    x,y=self:normalize(x,y)
    if button==glut.LEFT_BUTTON then
        if state==glut.DOWN then
             if glut.GetModifiers()==glut.ACTIVE_CTRL then
                self.target_x=x
                self.origin_x=x
                self.target_y=y
                self.origin_y=y
                self.drag="new"
            else
                local i,j=self:find(x,y)
                if i~=0 then
                    self.drag="ctrl"
                    self.ctrl_i=i
                    self.ctrl_j=j
                else
                    self.drag=nil
                end
            end
        elseif state==glut.UP then
            if self.drag=="new" and
                glut.GetModifiers()==glut.ACTIVE_CTRL then
                self:new_line()
            elseif self.drag=="ctrl" then
                self.splines.x[self.ctrl_i]:copy(self.lines.x[self.ctrl_i])
                self.splines.y[self.ctrl_i]:copy(self.lines.y[self.ctrl_i])
                cubic.convert(self.splines.x[self.ctrl_i])
                cubic.convert(self.splines.y[self.ctrl_i])
            end
            self.drag=nil
        end
    end
end

function ctrl_win:Motion(x,y)
    x,y=self:normalize(x,y)
    if self.drag=="new" then
        self.target_x=x
        self.target_y=y
    elseif self.drag=="ctrl" then
        self.lines.x[self.ctrl_i]:set(self.ctrl_j,x)
        self.lines.y[self.ctrl_i]:set(self.ctrl_j,y)
    end
end

function ctrl_win:PassiveMotion(x,y)
end

function ctrl_win:Keyboard(key,x,y)
    if key==27 then
        os.exit()
    end
end

function ctrl_win:Special(key,x,y)
end

function ctrl_win:build_mesh()
    local i,j
    local gr=self.mesh_gr
    self.mesh_vtx=array.double(gr+1,gr+1,2)
    self.mesh_tex=array.float(gr+1,gr+1,2)
    self.mesh_idx=array.uint(gr,gr,4)
    for i=0,gr do
        local x=i/gr*2-1
        for j=0,gr do
            local y=j/gr*2-1
            --self.mesh_vtx:set(i,j,0,x)
            --self.mesh_vtx:set(i,j,1,y)
            self.mesh_tex:set(i,j,0,i/gr)
            self.mesh_tex:set(i,j,1,j/gr)
        end
    end

    for i=0,gr-1 do
        for j=0,gr-1 do
            local base=i*(gr+1)+j
            self.mesh_idx:set(i,j,0,base)
            self.mesh_idx:set(i,j,1,base+(gr+1))
            self.mesh_idx:set(i,j,2,base+(gr+1)+1)
            self.mesh_idx:set(i,j,3,base+1)
        end
    end
end

function ctrl_win:reset_mesh()
    local gr=self.mesh_gr
    gl.Flush()
    self.cmd:write_buffer(self.mem_vtx, true, 0,
        self.mesh_vtx:size_of(), self.mesh_vtx:data())
    self.cmd:finish()
    self.krn_init_vtx:arg(0,gr)
    self.krn_init_vtx:arg(1,self.mem_vtx)
    self.cmd:range_kernel2d(self.krn_init_vtx,0,0,gr+1,gr+1,1,1)
    print(cl.host_get_error())
    self.cmd:finish()
    print(cl.host_get_error())
    self.cmd:read_buffer(self.mem_vtx, true, 0,
        self.mesh_vtx:size_of(), self.mesh_vtx:data())
    self.cmd:finish()
    print(cl.host_get_error())
end


function ctrl_win:init_cl()
    self.ctx=cl.context(0)
    self.ctx:add_device(gpu_id)
    self.ctx:initGL()
    print(cl.host_get_error())
    self.cmd=cl.command_queue(self.ctx,0,0)
end

function ctrl_win:Init()
    gl2.init()
    self:init_cl()
    gl.ClearColor(0.0,0.0,0.0,0.5)
    gl.ClearDepth(1.0)
    gl.Enable('DEPTH_TEST')
    gl.Disable('CULL_FACE')
    gl.ShadeModel('FLAT')
    self:build_mesh()
    gl.EnableClientState('VERTEX_ARRAY')
    gl2.vertex_array(self.mesh_vtx)
    gl.DisableClientState('VERTEX_ARRAY')
    gl.EnableClientState('TEXTURE_COORD_ARRAY')
    gl2.texcoord_array(self.mesh_tex)
    gl.DisableClientState('TEXTURE_COORD_ARRAY')
    self.image=array.byte(512,512,4)
    self.image:read("tiling_3_5.512x512.rgba")
    self.texsrc=gl2.color_texture2d()
    self.texsrc:set(0,gl.RGBA,512,512,0,gl.RGBA,gl.UNSIGNED_BYTE,self.image:data())
    self.pars=bar.new("Parameters")
    self.pars.a={type=tw.TYPE_DOUBLE,properties="help='a'"}
    self.mem_vtx=cl.mem(self.ctx,
        cl.MEM_READ_WRITE,self.mesh_vtx:size_of())
    self.prg=cl.program(self.ctx,kernel_src)
    self.krn_init_vtx=cl.kernel(self.prg, "init_vtx")
    print(cl.host_get_error())
    self:reset_mesh()
end

win.Loop()
