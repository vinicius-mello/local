dofile("modules.lua")
require("win")
require("gl2")
require("array")
require("gsl")

ctrl_win=win.New("dct")

function ctrl_win:Reshape(width, height)
    gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela

    self.width=width
    self.height=height

    gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
    gl.LoadIdentity()                -- carrega a matriz identidade
end

function ctrl_win:Display()
    gl.ClearColor(0.0,0.0,0.0,0.0)                  -- cor de fundo preta
    -- limpa a tela e o z-buffer
    gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
    gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
    gl.LoadIdentity()                -- carrega a matriz identidade
    gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
    gl.LoadIdentity()


    gl.TexEnv('TEXTURE_ENV_MODE','REPLACE')
    gl.Disable('LIGHTING')
    gl.MatrixMode('PROJECTION')
    gl.LoadIdentity()
    gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
    gl.LoadIdentity()
    gl.Enable('TEXTURE_2D')
    self.tex:bind()
    gl.TexParameter('TEXTURE_2D','TEXTURE_MAG_FILTER','NEAREST')
    gl.TexParameter('TEXTURE_2D','TEXTURE_MIN_FILTER','NEAREST')
    gl.Begin('QUADS')
    gl.TexCoord(0,0)
    gl.Vertex(-1,1)
    gl.TexCoord(1,0)
    gl.Vertex(1,1)
    gl.TexCoord(1,1)
    gl.Vertex(1,-1)
    gl.TexCoord(0,1)
    gl.Vertex(-1,-1)
    gl.End()
    self.tex:unbind()
    gl.Disable('TEXTURE_2D')
    gl.Color(1,0,0)
    local x=self.j/8-1
    local y=1-self.i/8
    local delta=2/self.tile
    gl.Begin('LINE_LOOP')
    gl.Vertex(x,y)
    gl.Vertex(x+delta,y)
    gl.Vertex(x+delta,y-delta)
    gl.Vertex(x,y-delta)
    gl.End()
    gl.Enable('LIGHTING')
end

-- chamada quando a janela OpenGL é criada
function ctrl_win:Init()
    print("Iniciando GLEW")
    gl2.init()

    print("Configurando OpenGL")
    gl.ClearDepth(1.0)                              -- valor do z-buffer
    gl.Enable('DEPTH_TEST')                         -- habilita teste z-buffer
    gl.DepthFunc('LEQUAL')                          -- tipo do teste

    gl.ShadeModel('SMOOTH')
    gl.Disable ('CULL_FACE')
    gl.Enable ('DEPTH_TEST')
    gl.Enable ('NORMALIZE')

    local null=array.uint()

    self.tex=gl2.color_texture2d()
    self.tile=16
    self.i=0
    self.j=0
    self.dct16=gsl.dct(self.tile)
    self.haar=gsl.dwt(gsl.haar,2)
    self.daubechies4=gsl.dwt(gsl.daubechies,4)
    self.bspline33=gsl.dwt(gsl.bspline,303)
    self.basis=array.double(self.tile,self.tile)
    self.basisrgb=array.float(self.tile,self.tile,4)
    self.pars=bar.New("Parameters")
    self.pars:NewVar {
        name="transform",
        type={
            name="Transform",
            enum={
                "identity",
                "dct",
                "haar",
                "daubechies4",
                "bspline (3.3)"
            }
        },
        update=function() print("up") self:settex() end
    }
    self.pars.transform=1
end

function ctrl_win:settex()
    local temp=array.double(self.tile,self.tile)
    temp:zero()
    temp:set(self.i,self.j,1)
    if self.pars.transform==1 then
        self.dct16:inverse2d(temp,self.basis)
    elseif self.pars.transform==2 then
        self.haar:inverse2d(temp)
        self.basis:copy(temp)
    elseif self.pars.transform==3 then
        self.daubechies4:inverse2d(temp)
        self.basis:copy(temp)
    elseif self.pars.transform==4 then
        self.bspline33:inverse2d(temp)
        self.basis:copy(temp)
    elseif self.pars.transform==0 then
        self.basis:copy(temp)
    end

    local min=math.huge
    local max=-math.huge
    for i=0,self.tile-1 do
        for j=0,self.tile-1 do
            local v=self.basis:get(i,j)
            if v<min then min=v end
            if v>max then max=v end
        end
    end
    for i=0,self.tile-1 do
        for j=0,self.tile-1 do
            local v=self.basis:get(i,j)
            v=(v-min)/(max-min)
            self.basisrgb:set(i,j,0,v)
            self.basisrgb:set(i,j,1,v)
            self.basisrgb:set(i,j,2,v)
        end
    end
    self.tex:set(0,gl.RGBA,self.tile,self.tile,0,gl.RGBA,
        gl.FLOAT,self.basisrgb:data())
end

-- chamada quando uma tecla é pressionada
function ctrl_win:Keyboard(key,x,y)
    if key==27 then
        os.exit()
    end
    if key==65 then
        self.j=self.j-1
    elseif key==66 then
        self.j=self.j+1
    end
    if self.j<0 then self.j=self.tile-1 end
    if self.j>=self.tile then self.j=0 end
    print(self.i,self.j)
    self:settex()
end

function ctrl_win:Mouse(button,state,x,y)
    if button==glut.LEFT_BUTTON and
        state==glut.DOWN then
    else
    end
end

function ctrl_win:Motion(x,y)
end

function ctrl_win:Special(key,x,y)
    if key==glut.KEY_LEFT then
        self.j=self.j-1
    elseif key==glut.KEY_RIGHT then
        self.j=self.j+1
    elseif key==glut.KEY_UP then
        self.i=self.i-1
    elseif key==glut.KEY_DOWN then
        self.i=self.i+1
    end
    if self.j<0 then self.j=self.tile-1 end
    if self.j>=self.tile then self.j=0 end
    if self.i<0 then self.i=self.tile-1 end
    if self.i>=self.tile then self.i=0 end
    self:settex()
end

win.Loop()
