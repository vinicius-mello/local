adap={}

require "mapm"
require "ad"

adap.sin=ad.func(mapm.sin,mapm.cos)
adap.cos=ad.func(mapm.cos,function(a) return -mapm.sin(a) end)
adap.tan=ad.func(mapm.tan,function(a) return 1/(mapm.cos(a)*mapm.cos(a)) end)
adap.exp=ad.func(mapm.exp,mapm.exp)
adap.log=ad.func(mapm.log,function(a) return 1/a end)
adap.abs=ad.func(mapm.abs,function(a) if a<0 then return -1 else return 1 end end)
adap.sqrt=ad.func(mapm.sqrt,function(a) return 1/(2*mapm.sqrt(a)) end)
adap.asin=ad.func(mapm.asin,function(a) return 1/mapm.sqrt(1-a*a) end)
adap.acos=ad.func(mapm.acos,function(a) return -1/mapm.sqrt(1-a*a) end)
adap.atan=ad.func(mapm.atan,function(a) return 1/(1+a*a) end)
adap.sinh=ad.func(mapm.sinh,mapm.cosh)
adap.cosh=ad.func(mapm.cosh,mapm.sinh)
adap.tanh=ad.func(mapm.tanh,function(a) return 1-mapm.tanh(a)*mapm.tanh(a) end)
adap.asinh=ad.func(mapm.asinh,function(a) return 1/mapm.sqrt(1+a*a) end)
adap.acosh=ad.func(mapm.acosh,function(a) return 1/(mapm.sqrt(a-1)*mapm.sqrt(a+1)) end)
adap.atanh=ad.func(mapm.atanh,function(a) return 1/(1-a*a) end)

return adap
