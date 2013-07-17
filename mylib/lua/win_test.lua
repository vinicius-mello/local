package.cpath=package.cpath..";/usr/lib/lib?51.so;../mylib/lua/?.dll;../mylib/lua/?.so"
require("array")
require("win")
require("cubic")

test_win=win.New("test")

test_win.lines={}
test_win.lines.x={}
test_win.lines.y={}
test_win.splines={}
test_win.splines.x={}
test_win.splines.y={}
test_win.max_ctrl=6

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
end

function test_win:new_line()
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

function test_win:find(x,y)
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

function test_win:Mouse(button,state,x,y)
    x=2*x/self.w-1
    y=1-2*y/self.h
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

function test_win:Motion(x,y)
    x=2*x/self.w-1
    y=1-2*y/self.h
    if self.drag=="new" then
        self.target_x=x
        self.target_y=y
    elseif self.drag=="ctrl" then
        self.lines.x[self.ctrl_i]:set(self.ctrl_j,x)
        self.lines.y[self.ctrl_i]:set(self.ctrl_j,y)
    end
end

function test_win:PassiveMotion(x,y)
end

function test_win:Keyboard(key,x,y)
    if key==27 then
        os.exit()
    end
end

function test_win:Special(key,x,y)
    print(key)
end


-- chamada quando a janela OpenGL é criada
function test_win:Init()
    gl.ClearColor(0.0,0.0,0.0,0.5)                  -- cor de fundo preta
    gl.ClearDepth(1.0)                              -- valor do z-buffer
    gl.Disable('DEPTH_TEST')                         -- habilita teste z-buffer
    gl.Enable('CULL_FACE')
    gl.ShadeModel('FLAT')
    self.pars=bar.New("Parameters")
    self.pars:NewVar {name="a", type=tw.TYPE_COLOR3F, properties=""}
    self.pars.a:set(0,0.8)
    self.pars.a:set(1,0.1)
    self.pars.a:set(2,0.6)
end

win.Loop()
