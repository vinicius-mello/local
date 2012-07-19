
function cubic1(x,y)
  --x=4*x
  --y=4*y
  return y^3-x^2+2*x*y
end

function cubic2(x,y)
  --x=4*x
  --y=4*y
  return y^3-x^2+2*x*y-x
end

function quartic(x,y)
  local xx=x^2
  local yy=y^2
  return xx*xx-3*xx*yy+3*yy*yy-0.1
end
