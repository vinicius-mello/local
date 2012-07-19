# Lesson01.tcl
#
# NeHe's OpenGL Framework
#
# This Code Was Created By Jeff Molofee 2000
# A HUGE Thanks To Fredric Echols For Cleaning Up
# And Optimizing This Code, Making It More Flexible!
# If You've Found This Code Useful, Please Let Me Know.
# Visit My Site At nehe.gamedev.net
#
# Modified for Tcl3D by Paul Obermeier 2006/01/25
# See www.tcl3d.org for the Tcl3D extension.

package require tcl3d 0.2

# Font to be used in the Tk listbox.
set gDemo(listFont) {-family {Courier} -size 10}

# Display mode.
set gDemo(fullScreen) false

# Window size.
set gDemo(winWidth)  640
set gDemo(winHeight) 480

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
    if { $::gDemo(fullScreen) } {
        SetFullScreenMode .
        set ::gDemo(fullScreen) false
    } else {
        SetWindowMode . $::gDemo(winWidth) $::gDemo(winHeight)
        set ::gDemo(fullScreen) true
    }
}

# Resize And Initialize The GL Window
proc ReshapeCallback { toglwin { w -1 } { h -1 } } {
    set w [$toglwin width]
    set h [$toglwin height]

    glViewport 0 0 $w $h        ; # Reset The Current Viewport
    glMatrixMode GL_PROJECTION  ; # Select The Projection Matrix
    glLoadIdentity              ; # Reset The Projection Matrix

    # Calculate The Aspect Ratio Of The Window
    gluPerspective 45.0 [expr double($w)/double($h)] 0.1 100.0

    glMatrixMode GL_MODELVIEW   ; # Select The Modelview Matrix
    glLoadIdentity              ; # Reset The Modelview Matrix
    set ::gDemo(winWidth)  $w
    set ::gDemo(winHeight) $h
}

# All Setup For OpenGL Goes Here
proc CreateCallback { toglwin } {
    glShadeModel GL_SMOOTH                  ; # Enable Smooth Shading
    glClearColor 0.0 0.0 0.0 0.5            ; # Black Background
    glClearDepth 1.0                        ; # Depth Buffer Setup
    glEnable GL_DEPTH_TEST                  ; # Enables Depth Testing
    glDepthFunc GL_LEQUAL                   ; # The Type Of Depth Testing To Do
    glHint GL_PERSPECTIVE_CORRECTION_HINT GL_NICEST ; # Really Nice Perspective Calculations
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
    $toglwin swapbuffers
}

proc Cleanup {} {
    uplevel #0 unset gDemo
}

# Put all exit related code here.
proc ExitProg {} {
    exit
}

# Create the OpenGL window and some Tk helper widgets.
proc CreateWindow {} {
    frame .fr
    pack .fr -expand 1 -fill both
    # Create Our OpenGL Window
    togl .fr.toglwin -width $::gDemo(winWidth) -height $::gDemo(winHeight) \
                     -double true -depth true \
                     -createproc CreateCallback \
                     -reshapeproc ReshapeCallback \
                     -displayproc DisplayCallback 
    listbox .fr.usage -font $::gDemo(listFont) -height 2
    label   .fr.info
    grid .fr.toglwin -row 0 -column 0 -sticky news
    grid .fr.usage   -row 1 -column 0 -sticky news
    grid .fr.info    -row 2 -column 0 -sticky news
    grid rowconfigure .fr 0 -weight 1
    grid columnconfigure .fr 0 -weight 1
    wm title . "Tcl3D demo: NeHe's OpenGL Framework (Lesson 1)"

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
