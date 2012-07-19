package require tcl3d 
package require control 
namespace import control::*

load ../mylib/tcl/lpt.so lpt
load ../mylib/tcl/array.so array

lpt2d_tree tree
array_double vert 6
set x [array_double 10]

# Font to be used in the Tk listbox.
set gApp(listFont) {-family {Courier} -size 10}

# Display mode.
set gApp(fullScreen) false

# Window size.
set gApp(winWidth)  480
set gApp(winHeight) 480

proc DrawTriangle { c } {
	$c simplex [vert data]
  glBegin $::GL_TRIANGLES
  glVertex2d [vert get 0] [vert get 1]
	if { [$c orientation] > 0 } then {
    glVertex2d [vert get 2] [vert get 3]
    glVertex2d [vert get 4] [vert get 5]
  } else {
    glVertex2d [vert get 4] [vert get 5]
    glVertex2d [vert get 2] [vert get 3]
  }
	glEnd
	glColor3f 1 1 1
	glBegin $::GL_LINE_LOOP
  glVertex2d [vert get 0] [vert get 1]
  glVertex2d [vert get 2] [vert get 3]
  glVertex2d [vert get 4] [vert get 5]
	glEnd
}

proc DrawTree { } {
  tree node_reset
  do { 
    if {[tree node_is_leaf]} then {
      glColor3f 1 0 0
			DrawTriangle [tree node_code]
  	}
  } while {[tree node_next]}
}

# Show errors occuring in the Togl callbacks.
proc bgerror { msg } {
    tk_messageBox -icon error -type ok -message "Error: $msg\n\n$::errorInfo"
    ExitProg
}

# Print info message into widget a the bottom of the window.
proc PrintInfo { msg } {
    if { [winfo exists .fr.info] } {
        .fr.info configure -text $msg
    }
}

proc SetFullScreenMode { win } {
    set sh [winfo screenheight $win]
    set sw [winfo screenwidth  $win]

    wm minsize $win $sw $sh
    wm maxsize $win $sw $sh
    set fmtStr [format "%dx%d+0+0" $sw $sh]
    wm geometry $win $fmtStr
    wm overrideredirect $win 1
    focus -force $win
}

proc SetWindowMode { win w h } {
    set sh [winfo screenheight $win]
    set sw [winfo screenwidth  $win]

    wm minsize $win 10 10
    wm maxsize $win $sw $sh
    set fmtStr [format "%dx%d+0+25" $w $h]
    wm geometry $win $fmtStr
    wm overrideredirect $win 0
    focus -force $win
}

# Toggle between windowing and fullscreen mode.
proc ToggleWindowMode {} {
		global gApp
    if { $gApp(fullScreen) } {
        SetFullScreenMode .
        set gApp(fullScreen) false
    } else {
        SetWindowMode . $gApp(winWidth) $gApp(winHeight)
        set gApp(fullScreen) true
    }
}

# Resize And Initialize The GL Window
proc ReshapeCallback { toglwin { w -1 } { h -1 } } {
		global gApp
    set w [$toglwin width]
    set h [$toglwin height]

    glViewport 0 0 $w $h        ; # Reset The Current Viewport
    glMatrixMode GL_PROJECTION  ; # Select The Projection Matrix
    glLoadIdentity              ; # Reset The Projection Matrix

    glMatrixMode GL_MODELVIEW   ; # Select The Modelview Matrix
    glLoadIdentity              ; # Reset The Modelview Matrix
    set gApp(winWidth)  $w
    set gApp(winHeight) $h
}

# All Setup For OpenGL Goes Here
proc CreateCallback { toglwin } {
    glShadeModel GL_FLAT 
    glClearColor 0.0 0.0 0.0 0.5            ; # Black Background
    glClearDepth 1.0                        ; # Depth Buffer Setup
    glEnable GL_DEPTH_TEST                  ; # Enables Depth Testing
    glDepthFunc GL_LEQUAL                   ; # The Type Of Depth Testing To Do
}

# Here's Where We Do All The Drawing
proc DisplayCallback { toglwin } {
    # Clear Screen And Depth Buffer
    glClear [expr $::GL_COLOR_BUFFER_BIT | $::GL_DEPTH_BUFFER_BIT] 

    # Viewport command is not really needed, but has been inserted for
    # Mac OSX. Presentation framework (Tk) does not send a reshape event,
    # when switching from one demo to another.
    glViewport 0 0 [$toglwin width] [$toglwin height]

    glLoadIdentity              ; # Reset The Current Modelview Matrix
		DrawTree
    $toglwin swapbuffers
}

proc Cleanup {} {
    uplevel #0 unset gApp
}

# Put all exit related code here.
proc ExitProg {} {
    exit
}

# Create the OpenGL window and some Tk helper widgets.
proc CreateWindow {} {
    global gApp
    frame .fr
    pack .fr -expand 1 -fill both
    # Create Our OpenGL Window
    togl .fr.toglwin -width $gApp(winWidth) -height $gApp(winHeight) \
                     -double true -depth true \
                     -createproc CreateCallback \
                     -reshapeproc ReshapeCallback \
                     -displayproc DisplayCallback 
    listbox .fr.usage -font $gApp(listFont) -height 2
    label   .fr.info
    grid .fr.toglwin -row 0 -column 0 -sticky news
    grid .fr.usage   -row 1 -column 0 -sticky news
    grid .fr.info    -row 2 -column 0 -sticky news
    grid rowconfigure .fr 0 -weight 1
    grid columnconfigure .fr 0 -weight 1
    wm title . "lpt2d.tcl"

    # Watch For ESC Key And Quit Messages
    wm protocol . WM_DELETE_WINDOW "ExitProg"
    bind . <Key-Escape> "ExitProg"
    bind . <Key-F1>     "ToggleWindowMode"

    .fr.usage insert end "Key-Escape Exit"
    .fr.usage insert end "Key-F1     Toggle window mode"
    .fr.usage configure -state disabled
}

CreateWindow
PrintInfo [format "Running on %s with a %s (OpenGL %s, Tcl %s)" \
           $tcl_platform(os) [glGetString GL_RENDERER] \
           [glGetString GL_VERSION] [info patchlevel]]
