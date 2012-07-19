require "ad"

function discrete_configuration(n) 
  local q0={}
  local q1={} 
  for i=1,n do
    q0[#q0+1]=ad.var(2*n,i)
    q1[#q1+1]=ad.var(2*n,i+n)
  end
  return q0,q1
end

function diff(q0,q1,h) 
  local n=#q0
  local dq={}
  for i=1,n do
    dq[#dq+1]=(q1[i]-q0[i])/h
  end
  return dq
end

function interp(q0,q1,alpha) 
  local n=#q0
  local q={}
  for i=1,n do
    q[#q+1]=(1-alpha)*q0[i]+alpha*q1[i]
  end
  return q
end

function left_rule(L,q0,q1,h)
  local dq=diff(q0,q1,h)
  return h*L(q0,dq)
end

function trapezoidal_rule(L,q0,q1,h)
  local dq=diff(q0,q1,h)
  return (h/2)*L(q0,dq)+(h/2)*L(q1,dq)
end

function midpoint_rule(L,q0,q1,h)
  local dq=diff(q0,q1,h)
  return h*L(interp(q0,q1,0.5),dq)
end


