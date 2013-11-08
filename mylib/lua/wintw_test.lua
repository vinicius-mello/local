package.cpath=package.cpath..";/usr/lib/lib?51.so;../mylib/lua/?.dll;../mylib/lua/?.so"
require("array")
require("win")

win1=win.New("win1")
win2=win.New("win2")

function win1:Reshape(width, height)
    gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela
    gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
    gl.LoadIdentity()                -- carrega a matriz identidade
    gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
    gl.LoadIdentity()                -- carrega a matriz identidade
    self.w=width
    self.h=height
end

-- chamada quando a janela OpenGL necessita ser desenhada
function win1:Display()
    print("win1:Display()")
    -- limpa a tela e o z-buffer
    gl.ClearColor(self.pars.a:get(0),self.pars.a:get(1),self.pars.a:get(2),0)
    gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
end

function win1:Mouse(button,state,x,y)
    print(x,y)
    win2:PostRedisplay()
end

function win1:Init()
    self.pars=bar.New("Parameters")
    self.pars:NewVar {name="a", type=tw.TYPE_COLOR3F, properties=""}
    self.pars.a:set(0,0.8)
    self.pars.a:set(1,0.1)
    self.pars.a:set(2,0.6)
end


function win2:Reshape(width, height)
    gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela
    gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
    gl.LoadIdentity()                -- carrega a matriz identidade
    gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
    gl.LoadIdentity()                -- carrega a matriz identidade
    self.w=width
    self.h=height
end

-- chamada quando a janela OpenGL necessita ser desenhada
function win2:Display()
    print("win2:Display()")
    -- limpa a tela e o z-buffer
    gl.ClearColor(self.pars.a:get(0),self.pars.a:get(1),self.pars.a:get(2),0)
    gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
end

function win2:Mouse(button,state,x,y)
    print(x,y)
end

function win2:Init()
    self.pars=bar.New("Pars")
    self.pars:NewVar {name="a", type=tw.TYPE_COLOR3F, properties=""}
    self.pars.a:set(0,0.8)
    self.pars.a:set(1,0.1)
    self.pars.a:set(2,0.6)
end

win.Loop()
