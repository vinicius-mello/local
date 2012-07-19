package ifneeded array 1.0 " 
  load [file join $dir array[info sharedlibextension]]
  source [file join $dir array.tcl]
"

package ifneeded blas 1.0 " 
  load [file join $dir blas[info sharedlibextension]]
"
