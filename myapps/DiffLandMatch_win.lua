dofile("modules.lua")
dofile("DiffLandMatch.lua")
require("win")
require("gl2")
require("colormap")

test_win=win.New("test")

test_win.lmk_src={}
test_win.lmk_dst={}

function test_win:Reshape(width, height)
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
function test_win:Display()
    -- limpa a tela e o z-buffer
    local i
    gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
    gl.PointSize(5.0)
    gl.LineWidth(3.0)
    gl.Begin('POINTS')
    gl.Color(1,0,0)
    for i=1,#self.lmk_src do
        local x=self.lmk_src[i][1]
        local y=self.lmk_src[i][2]
        gl.Vertex(x,y)
    end
    gl.Color(0,0,1)
    for i=1,#self.lmk_dst do
        local x=self.lmk_dst[i][1]
        local y=self.lmk_dst[i][2]
        gl.Vertex(x,y)
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
    gl.Begin('LINES')
    for i=1,#self.lmk_src do
        local xs=self.lmk_src[i][1]
        local ys=self.lmk_src[i][2]
        local xd=self.lmk_dst[i][1]
        local yd=self.lmk_dst[i][2]
        gl.Vertex(xs,ys)
        gl.Vertex(xd,yd)
    end
    gl.End()
    gl.Color(1,0,1)
    if self.solved then
        local cq=self.data.cq
        local N=cq:depth()
        for i=1,N do
            local j
            gl.Begin('LINE_STRIP')
            for j=0,64 do
                local t=j/64
                local x=cubic.eval(cq:row(i-1,0),t)
                local y=cubic.eval(cq:row(i-1,1),t)
                gl.Vertex(x,y)
            end
            gl.End()
        end
    end
    if self.viewmode==0 then
        gl.Enable('TEXTURE_2D')
        self.texsrc:bind()
        gl.TexEnv('TEXTURE_ENV_MODE','REPLACE')
        gl.EnableClientState('VERTEX_ARRAY')
        gl.EnableClientState('TEXTURE_COORD_ARRAY')
        gl2.draw_quads(self.mesh_idx)
        gl.DisableClientState('VERTEX_ARRAY')
        gl.DisableClientState('TEXTURE_COORD_ARRAY')
        gl.Disable('TEXTURE_2D')
    elseif self.viewmode==1 then
        local i,j
        local gr=self.mesh_gr
        for i=0,gr do
            gl.Color(0,0,0)
            gl.LineWidth(1.0)
            gl.Begin('LINE_STRIP')
            for j=0,gr do
                local x=self.mesh_vtx:get(i,j,0)
                local y=self.mesh_vtx:get(i,j,1)
                gl.Vertex(x,y)
            end
            gl.End()
            gl.Begin('LINE_STRIP')
            for j=0,gr do
                local x=self.mesh_vtx:get(j,i,0)
                local y=self.mesh_vtx:get(j,i,1)
                gl.Vertex(x,y)
            end
            gl.End()
        end
        local k
        for k=1,#self.lmk_src do
            local r,g,b
            gl.LineWidth(2.0)
            gl.Begin('LINE_STRIP')
            i=math.floor(self.lmk_src[k][1]*gr/2+gr/2)
            r=self.colormap:get(i,0)
            g=self.colormap:get(i,1)
            b=self.colormap:get(i,2)
            gl.Color(r,g,b)
            for j=0,gr do
                local x=self.mesh_vtx:get(i,j,0)
                local y=self.mesh_vtx:get(i,j,1)
                gl.Vertex(x,y)
            end
            gl.End()
            gl.Begin('LINE_STRIP')
            i=math.floor(self.lmk_src[k][2]*gr/2+gr/2)
            r=self.colormap:get(i,0)
            g=self.colormap:get(i,1)
            b=self.colormap:get(i,2)
            gl.Color(r,g,b)
            for j=0,gr do
                local x=self.mesh_vtx:get(j,i,0)
                local y=self.mesh_vtx:get(j,i,1)
                gl.Vertex(x,y)
            end
            gl.End()
        end
    elseif self.viewmode==2 then
        local i,j
        local gr=self.mesh_gr
        for i=0,gr do
            --[[local r,g,b
            r=self.colormap:get(i,0)
            g=self.colormap:get(i,1)
            b=self.colormap:get(i,2)
            gl.Color(r,g,b)]]
            gl.Color(0,0,0)
            gl.LineWidth(1.0)
            gl.Begin('LINE_STRIP')
            for j=0,gr do
                local x=i/gr*2-1
                local y=j/gr*2-1
                gl.Vertex(x,y)
            end
            gl.End()
            gl.Begin('LINE_STRIP')
            for j=0,gr do
                local x=j/gr*2-1
                local y=i/gr*2-1
                gl.Vertex(x,y)
            end
            gl.End()
        end
    end
end

function test_win:new_line()
    self.lmk_src[#self.lmk_src+1]={self.origin_x,self.origin_y}
    self.lmk_dst[#self.lmk_dst+1]={self.target_x,self.target_y}
end

function test_win:find(x,y)
    local i
    for i=1,#self.lmk_src do
        local ctrl_x=self.lmk_src[i][1]
        local ctrl_y=self.lmk_src[i][2]
        if math.abs(ctrl_x-x)<3*self.px
            and math.abs(ctrl_y-y)<3*self.px then
            return self.lmk_src,i
        end
    end
    for i=1,#self.lmk_dst do
        local ctrl_x=self.lmk_dst[i][1]
        local ctrl_y=self.lmk_dst[i][2]
        if math.abs(ctrl_x-x)<3*self.px
            and math.abs(ctrl_y-y)<3*self.px then
            return self.lmk_dst,i
        end
    end
    return nil,0
end

function test_win:normalize(x,y)
    x=2*x/self.w-1
    y=1-2*y/self.h
    local norm=math.sqrt(x*x+y*y)
    if norm>0.95 then
        x=0.95*x/norm
        y=0.95*y/norm
    end
    local gr2=self.mesh_gr/2
    x=math.floor(x*gr2)/gr2
    y=math.floor(y*gr2)/gr2
    return x,y
end

function test_win:Mouse(button,state,x,y)
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
                local t,i=self:find(x,y)
                if i~=0 then
                    self.drag="ctrl"
                    self.ctrl_i=i
                    self.ctrl_t=t
                else
                    self.drag=nil
                end
            end
        elseif state==glut.UP then
            if self.drag=="new" and
                glut.GetModifiers()==glut.ACTIVE_CTRL then
                self:new_line()
            elseif self.drag=="ctrl" then
            end
            self.drag=nil
        end
    end
end

function test_win:Motion(x,y)
    x,y=self:normalize(x,y)
    if self.drag=="new" then
        self.target_x=x
        self.target_y=y
        self.solved=false
    elseif self.drag=="ctrl" then
        self.ctrl_t[self.ctrl_i][1]=x
        self.ctrl_t[self.ctrl_i][2]=y
        self.solved=false
    end
end

function test_win:PassiveMotion(x,y)
end

function test_win:solve()
    print("Solving")
    local m=self.pars.m
    local n=2
    local N=#self.lmk_src
    local tau=self.pars.tau
    local mu=self.pars.mu
    local beta=self.pars.beta
    print("m",m)
    print("n",n)
    print("N",N)
    print("tau",tau)
    print("mu",mu)
    print("beta",beta)
    local env=self.list_envs[self.pars.environment+1]
    print(env)
    self.data=alloc_data(n,N,m)
    init_data(self.data,self.lmk_src,self.lmk_dst)
    if env=="euclidean_heat_kernel" then
        self.env=euclidean_heat_kernel(tau,mu,n)
    elseif env=="euclidean_heat_kernel_lut" then
        self.env=euclidean_heat_kernel_lut(tau,mu,n,0.001,16536)
    elseif env=="shifted_laplacian" then
        self.env=shifted_laplacian(tau,mu)
    elseif env=="hyperbolic_gaussian" then
        self.env=hyperbolic_gaussian(tau,mu,n)
    elseif env=="hyperbolic_heat_kernel" then
        self.env=hyperbolic_heat_kernel(tau,mu,0.001,16536)
    elseif env=="hyperbolicBK_heat_kernel" then
        self.env=hyperbolicBK_heat_kernel(tau,mu,0.001,16536)
    elseif env=="hyperbolic_shifted_laplacian" then
        self.env=hyperbolic_shifted_laplacian(tau,mu)
    elseif env=="hyperbolic_inverse_multiquadrics" then
        self.env=hyperbolic_inverse_multiquadrics(tau,mu)
    elseif env=="euclidean_inverse_multiquadrics" then
        self.env=euclidean_inverse_multiquadrics(tau,mu)
    elseif env=="hyperbolic_radial_characteristics" then
        self.env=hyperbolic_radial_characteristics(tau,beta,mu)
    elseif env=="euclidean_radial_characteristics" then
        self.env=euclidean_radial_characteristics(tau,beta,mu)
    elseif env=="clamped_thin_plate_spline" then
        self.env=clamped_thin_plate_spline(mu)
    end

    self.ws=alloc_workspace(N,n)
    print("eval",S(self.data,self.env,self.ws))
    self.solver=alloc_solver(self.data,self.env,self.ws)
    self.solver.opt:pgtol_set(10^self.pars.pgtol)
    self.solver.opt:factr_set(10^self.pars.factr)
    repeat
        self.solver:iterate()
    until self.solver.task=="conv"
    solve_alpha(self.data,self.env,self.ws)
    self.solved=true
    self.t=0
    collectgarbage()
end

function test_win:Keyboard(key,x,y)
    if key==27 then
        os.exit()
    end
end

function test_win:Special(key,x,y)
    if key==glut.KEY_LEFT then
        self.viewmode=(self.viewmode-1)%3
    elseif key==glut.KEY_RIGHT then
        self.viewmode=(self.viewmode+1)%3
    end
    print(self.viewmode)
end

function test_win:euler_iterate()
    print("Iterate",self.t)
    if not self.solved then
        return
    end
    local iterations=10^self.pars.iterations
    local dt=10^self.pars.euler_step
    print("iterations",iterations)
    print("dt",dt)
    for i=1,iterations do
        if self.t<1 then
            self:euler_step(self.t,dt)
            self.t=self.t+dt
        else
            break
        end
    end
end

function test_win:euler_step(t,dt)
    local i,j
    local gr=self.mesh_gr
    local env=self.env
    local n=self.mesh_vtx:width()
    local vxt=array.double(n)
    for i=0,gr do
        for j=0,gr do
            local x=self.mesh_vtx:row(i,j)
            if env.in_domain(x) then
                v(x,t,vxt,self.data,self.env,self.ws)
                blas.axpy(dt,vxt,x)
            end
        end
    end
end

function test_win:reset_mesh()
    local i,j
    local gr=self.mesh_gr
    for i=0,gr do
        local x=i/gr*2-1
        for j=0,gr do
            local y=j/gr*2-1
            self.mesh_vtx:set(i,j,0,x)
            self.mesh_vtx:set(i,j,1,y)
        end
    end
    self.t=0
end

function test_win:build_mesh()
    local i,j
    local gr=self.mesh_gr
    self.mesh_vtx=array.double(gr+1,gr+1,2)
    self.mesh_tex=array.float(gr+1,gr+1,2)
    self.mesh_idx=array.uint(gr,gr,4)
    for i=0,gr do
        local x=i/gr*2-1
        for j=0,gr do
            local y=j/gr*2-1
            self.mesh_vtx:set(i,j,0,x)
            self.mesh_vtx:set(i,j,1,y)
            self.mesh_tex:set(i,j,0,i/gr)
            self.mesh_tex:set(i,j,1,1.0-j/gr)
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

-- chamada quando a janela OpenGL é criada
function test_win:Init()
    gl2.init()
    gl.ClearColor(1.0,1.0,1.0,0.5)                  -- cor de fundo preta
    gl.ClearDepth(1.0)                              -- valor do z-buffer
    gl.Enable('DEPTH_TEST')                         -- habilita teste z-buffer
    gl.Enable('CULL_FACE')
    gl.ShadeModel('FLAT')

    self.solved=false
    self.mesh_gr=64
    self.colormap=array.double(self.mesh_gr+1,3)
    colormap.rgbmap(self.colormap,{t={0,0.5,1},r={0,0.06,.71},g={.25,0.71,.18},b={.90,0.4,0.06}})
    self:build_mesh()
    gl.EnableClientState('VERTEX_ARRAY')
    gl2.vertex_array(self.mesh_vtx)
    gl.DisableClientState('VERTEX_ARRAY')
    gl.EnableClientState('TEXTURE_COORD_ARRAY')
    gl2.texcoord_array(self.mesh_tex)
    gl.DisableClientState('TEXTURE_COORD_ARRAY')
    self.image=array.byte(512,512,4)
    --self.image:read("tiling_3_5.512x512.rgba")
    self.image:read("grid.512x512.rgba")
    --self.image:read("brain.512x512.rgba")
    --self.image:read("mandril.512x512.rgba")
    self.texsrc=gl2.color_texture2d()
    self.texsrc:set(0,gl.RGBA,512,512,0,gl.RGBA,gl.UNSIGNED_BYTE,self.image:data())

    self.pars=bar.New("Parameters")
    self.pars:NewVar {name="m", type=tw.TYPE_DOUBLE, properties="min=8 max=100"}
    self.pars.m=10
    self.pars:NewVar {name="tau", type=tw.TYPE_DOUBLE, properties="min=0.01 max=2 step=0.01"}
    self.pars.tau=0.25
    self.pars:NewVar {name="mu", type=tw.TYPE_DOUBLE, properties="min=0.0 max=1 step=0.05"}
    self.pars.mu=0.0
    self.pars:NewVar {name="beta", type=tw.TYPE_DOUBLE, properties="min=1.5 max=4 step=0.1"}
    self.pars.beta=2
    self.list_envs={
                "euclidean_heat_kernel",
                "euclidean_heat_kernel_lut",
                "hyperbolic_heat_kernel",
                "hyperbolicBK_heat_kernel",
                "clamped_thin_plate_spline",
                "euclidean_inverse_multiquadrics",
                "euclidean_radial_characteristics",
                "hyperbolic_gaussian",
                "hyperbolic_inverse_multiquadrics",
                "hyperbolic_radial_characteristics",
                "hyperbolic_shifted_laplacian"
            }
    local envs_str=""
    local i
    for i=1,#self.list_envs-1 do envs_str=envs_str..self.list_envs[i].."," end
    envs_str=envs_str..self.list_envs[#self.list_envs]
    self.pars:NewVar {name="environment",
        type={name="Environments",
                enum=envs_str }
    }
    self.pars:AddSeparator("numeric")
    self.pars:NewVar {name="pgtol", type=tw.TYPE_DOUBLE, properties="min=-6 max=1 step=1"}
    self.pars.pgtol=-3

    self.pars:NewVar {name="factr", type=tw.TYPE_DOUBLE, properties="min=1 max=8 step=1"}
    self.pars.factr=5

    self.pars:AddButton( "Solve", function() self:solve() end)
    self.pars:AddSeparator("euler")
    
    self.pars:NewVar {name="euler_step", type=tw.TYPE_DOUBLE, properties="min=-5 max=-1 step=1"}
    self.pars.euler_step=-2

    self.pars:NewVar {name="iterations", type=tw.TYPE_DOUBLE, properties="min=0 max=3 step=1"}
    self.pars.iterations=1

    self.pars:AddButton( "Iterate", function() self:euler_iterate() end)

    self.pars:AddSeparator("mesh")
    self.pars:AddButton( "Reset Mesh", function() self:reset_mesh() end)
    
    self.pars:Define(" Parameters iconified=false")
    self.pars:Define(" GLOBAL help='help!'")
    self.pars:Define(" Parameters size='300 400'")
    self.pars:Define(" Parameters valueswidth=170")

    self.t=0
    self.viewmode=0
end

win.Loop()
