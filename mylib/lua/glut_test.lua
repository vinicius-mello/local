package.cpath=package.cpath..";/usr/lib/lib?51.so;../mylib/lua/?.dll;../mylib/lua/?.so"
require("luagl")
require("luaglu")
require("glut")
require("bar")

glut.Init()
glut.InitDisplayMode(glut.RGBA+glut.DEPTH+glut.DOUBLE)
tw.Init(tw.OPENGL)
tw.ModifiersFunc()
teste=bar.New("teste")
teste:NewVar {name="a", type=tw.TYPE_DOUBLE, properties=""}
teste:AddSeparator("sep")
teste:NewVar {name="b", type={name="B", enum={ "B1","B2","B3"} }, properties=""}
teste.a=5
teste:AddButton( "Ok", function() print("Ok") end)
teste:Define(" teste iconified=true")
teste:Define(" GLOBAL help='help!'")

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
    print(teste.a)
    gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
    tw.Draw()
    glut.SwapBuffers()
end

function cb:Keyboard(key,x,y)
  print("Keyboard",tw.EventKeyboardGLUT(key,x,y))
  --[[  if tw.EventKeyboardGLUT(key,x,y)==0 then
        print("Keyboard",self.id,key)
    end
    ]]
    glut.PostRedisplay()
end

function cb:Mouse(button,state,x,y)
    --print("Mouse",self.id,x,y)
    print("Mouse",tw.EventMouseButtonGLUT(button,state,x,y)==0)
    glut.PostRedisplay()
end

function cb:Motion(x,y)
    print("Motion",self.id,x,y)
    tw.EventMouseMotionGLUT(x,y)
    glut.PostRedisplay()
end

function cb:PassiveMotion(x,y)
    print("PassiveMotion",self.id,x,y)
    tw.EventMouseMotionGLUT(x,y)
    glut.PostRedisplay()
end

function cb:Special(key,x,y)
  print("Special",key,tw.EventSpecialGLUT(key,x,y))
  --  print("Special",self.id,key)
    glut.PostRedisplay()
end


-- chamada quando a janela OpenGL é criada
function cb:Init()
    print("Init")
    gl.ClearColor(0.0,0.0,0.0,0.5)                  -- cor de fundo preta
    gl.ClearDepth(1.0)                              -- valor do z-buffer
    gl.Disable('DEPTH_TEST')                         -- habilita teste z-buffer
    gl.Enable('CULL_FACE')
    gl.ShadeModel('FLAT')
end

-- glut.IdleFunc(function() print("Hello!") end)
glut.MainLoop()
