package.cpath=package.cpath..";/usr/lib/lib?51.so;../mylib/lua/?.dll;../mylib/lua/?.so"
require("luagl")
require("luaglu")
require("glut")
require("tw")

glut.Init()
glut.InitDisplayMode(glut.RGBA+glut.DEPTH+glut.DOUBLE)
tw.Init(tw.OPENGL)
tw.NewBar("teste")
tw.NewVar("teste","a",tw.TYPE_DOUBLE)

cb=glut.NewWindow("teste")

function cb:Reshape(width, height)
    print("Reshape",self.id,width,height)
    gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela
    gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
    gl.LoadIdentity()                -- carrega a matriz identidade
    gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
    gl.LoadIdentity()                -- carrega a matriz identidade
    tw.WindowSize(width,height)
end

-- chamada quando a janela OpenGL necessita ser desenhada
function cb:Display()
    -- limpa a tela e o z-buffer
    print("Display",self.id)
    print(tw.GetDoubleVarByName("teste","a"))
    gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
    tw.Draw()
    glut.SwapBuffers()
end

function cb:Keyboard(key,x,y)
    print("Keyboard",self.id,key)
    tw.EventKeyboardGLUT(key,x,y)
    glut.PostRedisplay()
end

function cb:Mouse(button,state,x,y)
    print("Mouse",self.id,x,y)
    tw.EventMouseButtonGLUT(button,state,x,y)
    glut.PostRedisplay()
end

function cb:Motion(x,y)
    print("Motion",self.id,x,y)
    tw.EventMouseMotionGLUT(x,y)
    glut.PostRedisplay()
end

function cb:Special(key,x,y)
    print("Special",self.id,key)
end


-- chamada quando a janela OpenGL é criada
function cb:init()
    gl.ClearColor(1.0,0.0,0.0,0.5)                  -- cor de fundo preta
    gl.ClearDepth(1.0)                              -- valor do z-buffer
    gl.Disable('DEPTH_TEST')                         -- habilita teste z-buffer
    gl.Enable('CULL_FACE')
    gl.ShadeModel('FLAT')
end

cb:init()

-- glut.IdleFunc(function() print("Hello!") end)
glut.MainLoop()
