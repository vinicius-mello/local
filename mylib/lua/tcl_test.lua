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
	gl.Flush()
	print(win)
	tcl(win.." swapbuffers")
end

function TimerCallback()
	print("Timer")
end

tcl [[

  package require Togl 2.1
	lua_proc DisplayCallback
	lua_proc ReshapeCallback
	lua_proc CreateCallback
	lua_proc TimerCallback
  togl .hello -time 1 -width 500 -height 500 \
                     -double true -depth true \
                     -createproc CreateCallback \
                     -reshapeproc ReshapeCallback \
                     -timercommand TimerCallback \
                     -displayproc DisplayCallback 
  pack .hello

]]

TkMainLoop()
