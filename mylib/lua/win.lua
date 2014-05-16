require("luagl")
require("luaglu")
require("glut")
require("bar")

glut.Init()
glut.InitDisplayMode(glut.RGBA+glut.DEPTH+glut.DOUBLE)
tw.Init(tw.OPENGL)
tw.ModifiersFunc()

glut.InitWindowSize(512,512)

win={}

function win:PostRedisplay()
    local id=glut.GetWindow()
    glut.SetWindow(self.glutwin.id)
    glut.PostRedisplay()
    glut.SetWindow(id)
end

function win:PostRedisplayOthers()
    glut.PostRedisplayOthers()
end

function win:MakeCurrent()
    glut.SetWindow(self.glutwin.id)
end

function win:GetModifiers()
    glut.SetWindow(self.glutwin.id)
    return glut.GetModifiers()
end

function win:ActiveCtrl(status)
    glut.SetWindow(self.glutwin.id)
    return glut.ActiveCtrl(status)
end

function win:ActiveShift(status)
    glut.SetWindow(self.glutwin.id)
    return glut.ActiveShift(status)
end

function win:ActiveAlt(status)
    glut.SetWindow(self.glutwin.id)
    return glut.ActiveAlt(status)
end

win.__index=win

function win.New(title)
    local t={}
    t.glutwin=glut.NewWindow(title)

    function t.glutwin:Init()
        tw.SetCurrentWindow(t.glutwin.id)
        if t.Init then
            t:Init()
        end
    end

    function t.glutwin:Display()
        tw.SetCurrentWindow(t.glutwin.id)
        if t.Display then
            t:Display()
        end
        tw.Draw()
        glut.SwapBuffers()
    end

    function t.glutwin:Reshape(w,h)
        tw.SetCurrentWindow(t.glutwin.id)
        if t.Reshape then
            t:Reshape(w,h)
        end
        tw.WindowSize(w,h)
    end

    function t.glutwin:Keyboard(key,x,y)
        tw.SetCurrentWindow(t.glutwin.id)
        t.handled=(tw.EventKeyboardGLUT(key,x,y)==1)
        if not t.handled then
            if t.Keyboard then
                t:Keyboard(key,x,y)
            end
        end
        glut.PostRedisplay()
    end

    function t.glutwin:Special(key,x,y)
        tw.SetCurrentWindow(t.glutwin.id)
        t.handled=(tw.EventSpecialGLUT(key,x,y)==1)
        if not t.handled then
            if t.Special then
                t:Special(key,x,y)
            end
        end
        glut.PostRedisplay()
    end

    function t.glutwin:Mouse(button,state,x,y)
        tw.SetCurrentWindow(t.glutwin.id)
        t.handled=(tw.EventMouseButtonGLUT(button,state,x,y)==1)
        if not t.handled then
            if t.Mouse then
                t:Mouse(button,state,x,y)
            end
        end
        glut.PostRedisplay()
    end

    function t.glutwin:Motion(x,y)
        tw.SetCurrentWindow(t.glutwin.id)
        t.handled=(tw.EventMouseMotionGLUT(x,y)==1)
        if not t.handled then
            if t.Motion then
                t:Motion(x,y)
            end
        end
        glut.PostRedisplay()
    end

    function t.glutwin:PassiveMotion(x,y)
        tw.SetCurrentWindow(t.glutwin.id)
        t.handled=(tw.EventMouseMotionGLUT(x,y)==1)
        if not t.handled then
            if t.PassiveMotion then
                t:PassiveMotion(x,y)
            end
        end
        glut.PostRedisplay()
    end

    setmetatable(t,win)
    return t
end

function win.InitWindowSize(w,h)
    glut.InitWindowSize(w,h)
end

function win.Loop()
    glut.MainLoop()
end

return win
