
functions2d={}


function functions2d.cubic1(x,y)
  --x=4*x
  --y=4*y
  return y^3-x^2+2*x*y
end

function functions2d.cubic2(x,y)
  --x=4*x
  --y=4*y
  return y^3-x^2+2*x*y-x
end

function functions2d.quartic(x,y)
  local xx=x^2
  local yy=y^2
  return xx*xx-3*xx*yy+3*yy*yy-0.1
end

function functions2d.clown(x,y)
  local xx=x^2
  local yy=y^2
  return (y-xx+1)^4+(xx+yy)^4-1
end

function functions2d.taubin(x,y)
  x=2*x
  y=2*y
  local xx=x*x
  local yy=y*y
  local xy=x*y
  return 0.004+0.110*x-0.177*y-0.174*xx+0.224*xy-0.303*yy-0.168*xx*x
         +0.327*xx*y-0.087*x*yy-0.013*y*yy+0.235*xx*xx-0.667*xx*xy
         +0.745*xx*yy-0.029*xy*yy+0.072*yy*yy
end

function functions2d.circle(x,y)
  return x*x+y*y-1
end

functions2d.names={
    "circle",
    "clown",
    "taubin"
}

return functions2d