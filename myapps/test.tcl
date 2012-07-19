
load ../mylib/tcl/array.so array

proc a {} {
  set x [new_array_double 10]
  $x set 0 1
  puts [$x get 0]
}

a 

puts [$x get 0]
