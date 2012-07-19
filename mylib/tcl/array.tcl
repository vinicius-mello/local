#package provide array 1.0

foreach type {double float int uint char byte} {
  set code "proc trace_delete_$type {var args} {
    upvar _local_\$var d
    delete_array_$type \$d
  }"
  eval $code
}


proc Array {type var args} {
  set code "
    set $var [new_array_$type $args]
    variable _local_$var \$$var
    trace add variable $var {unset write} trace_delete_$type"
   uplevel eval $code
}
  

