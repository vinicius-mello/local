require "tcl"
require "luagl"

function CreateCallback()
    print("Create")
end


function ReshapeCallback()
    print("Reshape")
end

function DisplayCallback(win)
    print("Display")
    gl.Viewport(0,0,300,300)
    gl.ClearColor(0,0,0,0)
    gl.Clear(gl.COLOR_BUFFER_BIT)
    gl.Color(1,0,0,0)
    gl.Begin('TRIANGLES')
    gl.Vertex(1.0,0.0)
    gl.Vertex(-0.3,0.7)
    gl.Vertex(-0.3,-0.7)
    gl.End()
    gl.Flush()
    tcl(win.." swapbuffers")
end

function MotionCallback(x,y)
    print(x,y)
end

tcl [[

package require Togl 2.1
lua_proc DisplayCallback ReshapeCallback CreateCallback
lua_proc MotionCallback
togl .hello -width 500 -height 500 \
-double true -depth true \
-createproc CreateCallback \
-reshapeproc ReshapeCallback \
-displayproc DisplayCallback
pack .hello
bind . <Motion> {
    MotionCallback %x %y
}
bind . <Enter> {
    puts Enter
}
bind . <Leave> {
    puts Leave
}
grab .
]]

TkMainLoop()
