ProxyCube={}
ProxyCube.__index=ProxyCube

function ProxyCube.new() 
    local obj={}
    obj.backTex=engine:tex2d(gl.RGBA,512,512,gl.RGBA,gl.FLOAT)
    obj.frontTex=engine:tex2d(gl.RGBA,512,512,gl.RGBA,gl.FLOAT)
    obj.backTexDepth=engine:tex2d(gl.DEPTH_COMPONENT,512,512,gl.DEPTH_COMPONENT,gl.UNSIGNED_SHORT)
    obj.frontTexDepth=engine:tex2d(gl.DEPTH_COMPONENT,512,512,gl.DEPTH_COMPONENT,gl.UNSIGNED_SHORT)
    
    setmetatable(obj,ProxyCube)
    return obj
end

function ProxyCube:render()
    gl.MatrixMode('MODELVIEW') 
    gl.PushMatrix()
    engine.model_track:transform()
    
    gl.ClearColor(0.0,0.0,0.0,0.0)
    
    engine:bind_fb1(self.backTex,self.backTexDepth)
    gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
    gl.FrontFace('CW')
    self:draw_cube()
    gl.Flush()
    engine:unbind_fb1()

    engine:bind_fb1(self.frontTex,self.frontTexDepth)
    gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
    gl.FrontFace('CCW')
    self:draw_cube()
    gl.Flush()
    engine:unbind_fb1()
    
    gl.PopMatrix()
    return self.backTex, self.frontTex, self.backTexDepth, self.frontTexDepth 
end


function ProxyCube:draw_cube()
    gl.Disable('LIGHTING')
    gl.Enable('DEPTH_TEST')                         -- habilita teste z-buffer
    gl.DepthFunc('LEQUAL')
    gl.Begin('QUADS')
    gl.Color(0,0,0)
    gl.Vertex(-1,-1,-1)
    gl.Color(0,1,0)
    gl.Vertex(-1,1,-1)
    gl.Color(1,1,0)
    gl.Vertex(1,1,-1)
    gl.Color(1,0,0)
    gl.Vertex(1,-1,-1)
    gl.Color(0,0,1)
    gl.Vertex(-1,-1,1)
    gl.Color(1,0,1)
    gl.Vertex(1,-1,1)
    gl.Color(1,1,1)
    gl.Vertex(1,1,1)
    gl.Color(0,1,1)
    gl.Vertex(-1,1,1)
    gl.Color(1,0,0)
    gl.Vertex(1,-1,-1)
    gl.Color(1,1,0)
    gl.Vertex(1,1,-1)
    gl.Color(1,1,1)
    gl.Vertex(1,1,1)
    gl.Color(1,0,1)
    gl.Vertex(1,-1,1)
    gl.Color(0,0,0)
    gl.Vertex(-1,-1,-1)
    gl.Color(0,0,1)
    gl.Vertex(-1,-1,1)
    gl.Color(0,1,1)
    gl.Vertex(-1,1,1)
    gl.Color(0,1,0)
    gl.Vertex(-1,1,-1)
    gl.Color(0,1,0)
    gl.Vertex(-1,1,-1)
    gl.Color(0,1,1)
    gl.Vertex(-1,1,1)
    gl.Color(1,1,1)
    gl.Vertex(1,1,1)
    gl.Color(1,1,0)
    gl.Vertex(1,1,-1)
    gl.Color(0,0,0)
    gl.Vertex(-1,-1,-1)
    gl.Color(1,0,0)
    gl.Vertex(1,-1,-1)
    gl.Color(1,0,1)
    gl.Vertex(1,-1,1)
    gl.Color(0,0,1)
    gl.Vertex(-1,-1,1)
    gl.End()
end

Background={}
Background.__index=Background

function Background.new()
    local obj={}
    obj.dirty=true
    obj.bar=bar.New("Background")
    obj.bar:NewVar {name="colortop", type=tw.TYPE_COLOR3F, properties="label='color 1'", update=function() obj.dirty=true end}
    obj.bar:NewVar {name="colorbottom", type=tw.TYPE_COLOR3F, properties="label='color 1'", update=function() obj.dirty=true end}
    obj.backTex=engine:tex2d(gl.RGBA,128,128,gl.RGBA,gl.UNSIGNED_BYTE)
    obj.prog=engine:load_shaders("shaders/default_quad.glsl","shaders/background.glsl")
    obj.bar.colortop:set(0,0.8)
    obj.bar.colortop:set(1,0.8)
    obj.bar.colortop:set(2,0.8)
    obj.bar.colorbottom:set(0,0.3)
    obj.bar.colorbottom:set(1,0.3)
    obj.bar.colorbottom:set(2,0.3)  
    setmetatable(obj,Background)
    return obj
end

function Background:render()
    local tex=self.backTex
    if not self.dirty then
        return tex
    end
    engine:bind_fb1(tex)
    self.prog:bind()
    local colortop=self.bar.colortop
    local colorbottom=self.bar.colorbottom
    self.prog:uniform("colortop",colortop:get(0),colortop:get(1),colortop:get(2))
    self.prog:uniform("colorbottom",colorbottom:get(0),colorbottom:get(1),colorbottom:get(2))
    gl.Viewport(0, 0, tex:width(), tex:height())
    gl.MatrixMode('PROJECTION')
    gl.PushMatrix()
    gl.LoadIdentity()
    gl.MatrixMode('MODELVIEW')
    gl.PushMatrix()
    gl.LoadIdentity()
    gl.ClearColor(0,0,0,0)
    gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
    gl.Begin('QUADS')
    gl.Vertex(-1,-1)
    gl.Vertex(1,-1)
    gl.Vertex(1,1)
    gl.Vertex(-1,1)
    gl.End()
    gl.Flush()
    gl.MatrixMode('PROJECTION')
    gl.PopMatrix()
    gl.MatrixMode('MODELVIEW')
    gl.PopMatrix()
    self.prog:unbind()  
    engine:unbind_fb1()
    self.dirty=false
    return tex  
end

Canvas={}
Canvas.__index=Canvas

function Canvas.new(pro,background)
    local obj={}
    obj.pro=pro
    obj.background=background
    obj.prog=engine:load_shaders("shaders/default_quad.glsl","shaders/colordepth.glsl")
    setmetatable(obj,Canvas)
    return obj
end

function Canvas:render()
    local tex,texDepth=self.pro:render()
    local texBack=self.background:render()
    gl.Viewport(0, 0, engine.win.width, engine.win.height)
    gl.MatrixMode('PROJECTION')
    gl.PushMatrix()
    gl.LoadIdentity()
    gl.MatrixMode('MODELVIEW')
    gl.PushMatrix()
    gl.LoadIdentity()
    gl.ClearColor(0,0,0,0)
    gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')

    gl2.active_texture(2)
    texBack:bind()
    gl2.active_texture(1)
    texDepth:bind()
    gl2.active_texture(0)
    tex:bind()
    self.prog:bind()
    self.prog:uniformi("color",0)
    self.prog:uniformi("depth",1)
    self.prog:uniformi("background",2)
    gl.Begin('QUADS')
    gl.Vertex(-1,-1)
    gl.Vertex(1,-1)
    gl.Vertex(1,1)
    gl.Vertex(-1,1)
    gl.End()
    gl.Flush()
    self.prog:unbind()
    gl.MatrixMode('PROJECTION')
    gl.PopMatrix()
    gl.MatrixMode('MODELVIEW')
    gl.PopMatrix()
end

TransferFunction={}
TransferFunction.__index=TransferFunction

function TransferFunction.new()
    local obj={}
    obj.dirty=true
    local dirtyFunc=function() obj.dirty=true end
    obj.temp=array.float(4)
    obj.bar=bar.New("Transfer Function")
    obj.bar:NewVar {name="peak1", type=tw.TYPE_DOUBLE, properties="min=0 max=1 step=0.01", update=dirtyFunc}
    obj.bar:NewVar {name="intensity1", type=tw.TYPE_DOUBLE, properties="min=0 max=1 step=0.01", update=dirtyFunc}
    obj.bar:NewVar {name="color1", type=tw.TYPE_COLOR3F, properties="label='color 1'", update=dirtyFunc}
    obj.bar:NewVar {name="peak2", type=tw.TYPE_DOUBLE, properties="min=0 max=1 step=0.01", update=dirtyFunc}
    obj.bar:NewVar {name="intensity2", type=tw.TYPE_DOUBLE, properties="min=0 max=1 step=0.01", update=dirtyFunc}
    obj.bar:NewVar {name="color2", type=tw.TYPE_COLOR3F, properties="label='color 1'", update=dirtyFunc}
    obj.bar:NewVar {name="peak3", type=tw.TYPE_DOUBLE, properties="min=0 max=1 step=0.01", update=dirtyFunc}
    obj.bar:NewVar {name="intensity3", type=tw.TYPE_DOUBLE, properties="min=0 max=1 step=0.01", update=dirtyFunc}   
    obj.bar:NewVar {name="color3", type=tw.TYPE_COLOR3F, properties="label='color 1'", update=dirtyFunc}
    obj.bar.peak1=0.4
    obj.bar.peak2=0.6
    obj.bar.peak3=0.8
    obj.bar.intensity1=0.0
    obj.bar.intensity2=1.0
    obj.bar.intensity3=0.0
    obj.bar.color1:set(0,0.8)
    obj.bar.color1:set(1,0.5)
    obj.bar.color1:set(2,0.1)
    obj.bar.color2:set(0,0.5)
    obj.bar.color2:set(1,0.8)
    obj.bar.color2:set(2,0.1)
    obj.bar.color3:set(0,0.1)
    obj.bar.color3:set(1,0.5)
    obj.bar.color3:set(2,0.8)
    local len=4096
    obj.data=array.float(len,4)
    obj.tex=engine:tex1d(gl.RGBA,len,gl.RGBA,gl.FLOAT,obj.data)
    setmetatable(obj,TransferFunction)
    return obj
end

function TransferFunction:render()
    if not self.dirty then
        return self.tex,false
    end
    local p={}
    p[1]=self.bar.peak1
    p[2]=self.bar.peak2
    p[3]=self.bar.peak3
    local w={}
    w[1]=self.bar.intensity1
    w[2]=self.bar.intensity2
    w[3]=self.bar.intensity3
    local c={}
    c[1]=self.bar.color1
    c[2]=self.bar.color2
    c[3]=self.bar.color3
    local sp=0.01
    local len=self.data:height()
    local temp=self.temp
    
    for i=0,len-1 do 
        local x=i/(len-1)
        temp:zero()
        for j=1,3 do
            local v=w[j]*math.exp(-(x-p[j])^2/sp)
            temp:add_to(0,c[j]:get(0)*v)
            temp:add_to(1,c[j]:get(1)*v)
            temp:add_to(2,c[j]:get(2)*v)
            temp:add_to(3,v)
        end
        for j=0,3 do 
            self.data:set(i,j,temp:get(j))
        end
    end
    self.tex:set(0,gl.RGBA,len,0,gl.RGBA,gl.FLOAT,self.data:data())
    self.dirty=false
    return self.tex,true
end

DVRShader={}
DVRShader.__index=DVRShader

function DVRShader.new(proxy,vol,transfer)
    local obj={}
    obj.dirty=true
    obj.proxy=proxy
    obj.tex={}
    obj.vol=vol
    obj.tex[2]=engine:tex2d(gl.RGBA,512,512,gl.RGBA,gl.UNSIGNED_BYTE)
    obj.tex[1]=engine:tex2d(gl.RGBA,256,256,gl.RGBA,gl.UNSIGNED_BYTE)
    obj.tex[0]=engine:tex2d(gl.RGBA,128,128,gl.RGBA,gl.UNSIGNED_BYTE)
    obj.texDepth={}
    obj.texDepth[2]=engine:tex2d(gl.DEPTH_COMPONENT,512,512,gl.DEPTH_COMPONENT,gl.UNSIGNED_SHORT)
    obj.texDepth[1]=engine:tex2d(gl.DEPTH_COMPONENT,256,256,gl.DEPTH_COMPONENT,gl.UNSIGNED_SHORT)
    obj.texDepth[0]=engine:tex2d(gl.DEPTH_COMPONENT,128,128,gl.DEPTH_COMPONENT,gl.UNSIGNED_SHORT)   
    obj.prog=engine:load_shaders("shaders/default_quad.glsl","shaders/dvr.glsl")
    obj.transfer=transfer
    obj.bar=bar.New("DVRShader")
    obj.bar:NewVar {name="resolution", type={name="Resolutions",enum={"128","256","512"}},update=function() obj.dirty=true end}
 
    setmetatable(obj,DVRShader)
    return obj
end

function DVRShader:render()
    local back,front,backDepth,frontDepth=self.proxy:render()
    local volTex=self.vol:render()
    local tf,dirtyTransfer=self.transfer:render()
    local tex
    local texDepth
    local resolution=self.bar.resolution
    print(self.dirty,dirtyTransfer,engine.dragging)
    if not (self.dirty or dirtyTransfer or engine.dragging) then
        return self.tex[resolution],self.texDepth[resolution],false
    end
    if dirtyTransfer or engine.dragging then
        tex=self.tex[0]
        texDepth=self.texDepth[0]
    else
        tex=self.tex[resolution]
        texDepth=self.texDepth[resolution]
    end 
    gl2.active_texture(5)
    volTex:bind()
    gl2.active_texture(4)
    tf:bind()
    gl2.active_texture(3)
    backDepth:bind()
    gl2.active_texture(2)
    frontDepth:bind()
    gl2.active_texture(1)
    back:bind()
    gl2.active_texture(0)
    front:bind()

    engine:bind_fb1(tex,texDepth)
    gl.ClearColor(0,0,0,0)
    gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
    self.prog:bind()
    self.prog:uniform("Step",2.0/tex:width())  
    self.prog:uniformi("front",0)
    self.prog:uniformi("back",1)
    self.prog:uniformi("frontDepth",2)
    self.prog:uniformi("backDepth",3)
    self.prog:uniformi("transfer",4) 
    self.prog:uniformi("volume",5) 
    gl.Viewport(0, 0, tex:width(), tex:height())
    gl.MatrixMode('PROJECTION')
    gl.PushMatrix()
    gl.LoadIdentity()
    gl.MatrixMode('MODELVIEW')
    gl.PushMatrix()
    gl.LoadIdentity()
    gl.Begin('QUADS')
    gl.Vertex(-1,-1)
    gl.Vertex(1,-1)
    gl.Vertex(1,1)
    gl.Vertex(-1,1)
    gl.End()
    gl.Flush()
    gl.MatrixMode('PROJECTION')
    gl.PopMatrix()
    gl.MatrixMode('MODELVIEW')
    gl.PopMatrix()
    self.prog:unbind()
    engine:unbind_fb1()
    if not engine.dragging then
        self.dirty=false 
    else
        self.dirty=true 
    end
    return tex,texDepth,true
end

VolumeFunction={}
VolumeFunction.__index=VolumeFunction

function VolumeFunction.new(func,res)
    local obj={}
    obj.data=array.float(res,res,res)
    for i=0,res-1 do
        local x=2*i/(res-1)-1
        for j=0,res-1 do
            local y=2*j/(res-1)-1
            for k=0,res-1 do
                local z=2*k/(res-1)-1
                obj.data:set(i,j,k,func(x,y,z))
            end
        end
    end
    obj.volTex=engine:tex3d(gl2.R16F,res,res,res,gl.RED,gl.FLOAT,obj.data)
    setmetatable(obj,VolumeFunction)
    return obj
end

function VolumeFunction:render()
    return self.volTex
end

