require "varint"

function lagrangian(q,dq) 
  local n=#q0
  return dq[1]^2+(q[1]^2)*(dq[2]^2)+4*(q[1]^2)*(dq[1]^2)-20*q[1]^2
end

q0,q1=discrete_configuration(2)

Ld=left_rule(lagrangian,q0,q1,0.1)

print(Ld[2](1,2,3,4))
