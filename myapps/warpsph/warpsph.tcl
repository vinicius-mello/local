package require Img
package require tcl3d 0.2
catch { load ./app[info sharedlibextension] app}

# Font to be used in the Tk listbox.
set gApp(listFont) {-family {Courier} -size 10}

# Obtain the name of this script file.
set gApp(scriptFile) [info script]
# Determine the directory of this script.
set gApp(scriptDir) [file dirname [info script]]

# Display mode.
set gApp(fullScreen) false

set gApp(draggingLandmark) false
set gApp(drawWarped) false

set gApp(texture) [tcl3dVector GLuint 1] ; # Storage For One Texture ( NEW )

# Window size.
set gApp(winWidth)  640
set gApp(winHeight) 480

App app

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

proc LoadGLTextures {} {
    # Load texture image.
    set texName [file join $::gApp(scriptDir) "mundi1k.bmp"]
    set retVal [catch {set phImg [image create photo -file $texName]} err1]
    if { $retVal != 0 } {
        error "Error reading image $texName ($err1)"
    } else {
        set w [image width  $phImg]
        set h [image height $phImg]
        set n [tcl3dPhotoChans $phImg]
        set TextureImage [tcl3dVectorFromPhoto $phImg]
        image delete $phImg
    }

    glGenTextures 1 $::gApp(texture)          ; # Create The Texture

    # Typical Texture Generation Using Data From The Bitmap
    glBindTexture GL_TEXTURE_2D [$::gApp(texture) get 0]
    if { $n == 3 } {
        set type $::GL_RGB
    } else {
       set type $::GL_RGBA
    }
    glTexImage2D GL_TEXTURE_2D 0 $n $w $h 0 $type GL_UNSIGNED_BYTE $TextureImage

    glTexParameteri GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER $::GL_LINEAR
    glTexParameteri GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER $::GL_LINEAR

    $TextureImage delete       ; # Free The Texture Image Memory
}


# Toggle between windowing and fullscreen mode.
proc ToggleWindowMode {} {
    if { $::gApp(fullScreen) } {
        SetFullScreenMode .
        set ::gApp(fullScreen) false
    } else {
        SetWindowMode . $::gApp(winWidth) $::gApp(winHeight)
        set ::gApp(fullScreen) true
    }
}

# Resize And Initialize The GL Window
proc tclReshapeFunc { toglwin  {w 640} {h 480} } {
    glViewport 0 0 $w $h        ; # Reset The Current Viewport
    glMatrixMode GL_PROJECTION  ; # Select The Projection Matrix
    glLoadIdentity              ; # Reset The Projection Matrix

    # Calculate The Aspect Ratio Of The Window
    gluPerspective 45.0 [expr double($w)/double($h)] 0.1 100.0

    glMatrixMode GL_MODELVIEW   ; # Select The Modelview Matrix
    glLoadIdentity              ; # Reset The Modelview Matrix
    set ::gApp(winWidth)  $w
    set ::gApp(winHeight) $h
		tcl3dTbReshape $toglwin $w $h
}

# All Setup For OpenGL Goes Here
proc tclCreateFunc { toglwin } {
    LoadGLTextures                          ; # Jump To Texture Loading Routine ( NEW )
    glEnable GL_TEXTURE_2D                  ; # Enable Texture Mapping ( NEW )
    glShadeModel GL_SMOOTH                  ; # Enable Smooth Shading
    glClearColor 1.0 1.0 1.0 0.5            ; # Black Background
    glClearDepth 1.0                        ; # Depth Buffer Setup
    glEnable GL_DEPTH_TEST                  ; # Enables Depth Testing
    glDepthFunc GL_LEQUAL                   ; # The Type Of Depth Testing To Do
    glHint GL_PERSPECTIVE_CORRECTION_HINT GL_NICEST ; # Really Nice Perspective Calculations
		glEnable GL_LIGHT0
		tcl3dTbInit $toglwin 
		tcl3dTbAnimate $toglwin 0
}

# Here's Where We Do All The Drawing
proc tclDisplayFunc { toglwin } {
    # Clear Screen And Depth Buffer
    glClear [expr $::GL_COLOR_BUFFER_BIT | $::GL_DEPTH_BUFFER_BIT] 

    # Viewport command is not really needed, but has been inserted for
    # Mac OSX. Presentation framework (Tk) does not send a reshape event,
    # when switching from one demo to another.
    glViewport 0 0 $::gApp(winWidth) $::gApp(winHeight)

    glLoadIdentity                              ; # Reset The Current Modelview Matrix
		gluLookAt 0 0 3 0 0 0 0 1 0
    glBindTexture GL_TEXTURE_2D [$::gApp(texture) get 0]
		glEnable GL_LIGHTING
		tcl3dTbMatrix $toglwin
    set mat_diffuse_white { 1.0 1.0 1.0 1.0 }
    set mat_diffuse_red { 1.0 0.0 0.0 1.0 }
    set mat_diffuse_blue { 0.0 0.0 1.0 1.0 }
    glMaterialfv GL_FRONT GL_DIFFUSE $mat_diffuse_white
		if {$::gApp(drawWarped)} {
			app draw_warped_sphere
    	glMaterialfv GL_FRONT GL_DIFFUSE $mat_diffuse_blue
			app draw_destination_landmarks
		} else {
			app draw_sphere
    	glMaterialfv GL_FRONT GL_DIFFUSE $mat_diffuse_red
			app draw_source_landmarks
    	glMaterialfv GL_FRONT GL_DIFFUSE $mat_diffuse_blue
			app draw_destination_landmarks
			glDisable GL_LIGHTING
			glLineWidth 3.0
			glColor3f 1.0 1.0 0.0
			app draw_arcs
		}
    $toglwin swapbuffers
}

proc Cleanup {} {
    uplevel #0 unset gApp
}

# Put all exit related code here.
proc ExitProg {} {
    exit
}

# Create a PDF file of the window contents.
proc CreatePdf { toglwin } {
    if { ([info procs tcl3dHaveGl2ps] eq "tcl3dHaveGl2ps") && \
          [tcl3dHaveGl2ps] } {
        set fileName [format "%s.%s" [file rootname $::gApp(scriptFile)] "pdf"]
        # Create a name on the file system, if running from within a Starpack.
        set fileName [tcl3dGenExtName $fileName]
        tcl3dGl2psCreatePdf $toglwin $fileName "[wm title .]"
    } else {
        tk_messageBox -icon info -type ok -title "Info" \
                      -message "PDF creation needs the gl2ps extension.\n\
                                Available in Tcl3D versions greater than 0.3."
    }
    $toglwin postredisplay
}

# Create the OpenGL window and some Tk helper widgets.
proc CreateWindow {} {
    frame .fr
    pack .fr -expand 1 -fill both
    # Create Our OpenGL Window
    togl .fr.toglwin -width $::gApp(winWidth) -height $::gApp(winHeight)  -double true -depth true -createproc tclCreateFunc -displayproc tclDisplayFunc -reshapeproc tclReshapeFunc 
    #togl .fr.toglwin -width $::gApp(winWidth) -height $::gApp(winHeight) \
    #                 -double true -depth true \
    #                 -createproc tclCreateFunc \
    #                 -reshapeproc tclReshapeFunc \
    #                 -displayproc tclDisplayFunc 
    listbox .fr.usage -font $::gApp(listFont) -height 5
    label   .fr.info
    grid .fr.toglwin -row 0 -column 0 -sticky news
    grid .fr.usage   -row 1 -column 0 -sticky news
    grid .fr.info    -row 2 -column 0 -sticky news
    grid rowconfigure .fr 0 -weight 1
    grid columnconfigure .fr 0 -weight 1
    wm title . "Tcl3D demo: NeHe's First Polygon Tutorial (Lesson 2)"

    # Watch For ESC Key And Quit Messages
    wm protocol . WM_DELETE_WINDOW "ExitProg"
    bind . <Key-t> {
			set ::gApp(drawWarped) [expr !$::gApp(drawWarped)]
			.fr.toglwin postredisplay
		}
    bind . <Key-w> {
			app compute_warping
			set ::gApp(drawWarped) true
			.fr.toglwin postredisplay
		}
    bind . <Key-Escape> "ExitProg"
    bind . <Key-F1>     "ToggleWindowMode"
    bind . <Key-F12>    "CreatePdf .fr.toglwin"
		bind . <Control-ButtonPress-1> {
			if {[app select_landmark %x %y]} {
				app delete_landmark
			} else { 
				app add_landmark %x %y
			}
			.fr.toglwin postredisplay
		}
		bind . <ButtonPress-1> {
			if {[app select_landmark %x %y]} {
				set ::gApp(draggingLandmark) true
			} else {
				tcl3dTbStartMotion .fr.toglwin %x %y
			}
		}
		bind . <ButtonRelease-1> {
			if {$::gApp(draggingLandmark)} {
				app release_landmark %x %y
				.fr.toglwin postredisplay
				set ::gApp(draggingLandmark) false
			} else {
				tcl3dTbStopMotion .fr.toglwin
			}
		}
		bind . <B1-Motion> { 
			if {$::gApp(draggingLandmark)} {
				app drag_landmark %x %y
				.fr.toglwin postredisplay
			} else {
				tcl3dTbMotion .fr.toglwin %x %y
			}
		}

    .fr.usage insert end "Key-Escape    Exit"
    .fr.usage insert end "Key-F1        Toggle window mode"
    .fr.usage insert end "Key-w         Sphere Warp"
    .fr.usage insert end "Key-t         Togle Normal/Warped"
    .fr.usage insert end "Control-click Insert/Delete Control Point"
    .fr.usage configure -state disabled
		
}

CreateWindow
PrintInfo [format "Running on %s with a %s (OpenGL %s, Tcl %s)" \
           $tcl_platform(os) [glGetString GL_RENDERER] \
           [glGetString GL_VERSION] [info patchlevel]]
