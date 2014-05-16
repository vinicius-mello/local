adia={}

require("interval")
require("ad")

adia.sin=ad.func(interval.sin,interval.cos)
adia.cos=ad.func(interval.cos,function(a) return -interval.sin(a) end)
adia.tan=ad.func(interval.tan,function(a) return 1/(interval.cos(a)*interval.cos(a)) end)
adia.exp=ad.func(interval.exp,interval.exp)
adia.log=ad.func(interval.log,function(a) return 1/a end)
adia.sqrt=ad.func(interval.sqrt,function(a) return 1/(2*interval.sqrt(a)) end)
adia.asin=ad.func(interval.asin,function(a) return 1/interval.sqrt(1-a*a) end)
adia.acos=ad.func(interval.acos,function(a) return -1/interval.sqrt(1-a*a) end)
adia.atan=ad.func(interval.atan,function(a) return 1/(1+a*a) end)
adia.sinh=ad.func(interval.sinh,interval.cosh)
adia.cosh=ad.func(interval.cosh,interval.sinh)
adia.tanh=ad.func(interval.tanh,function(a) return 1-interval.tanh(a)*interval.tanh(a) end)
adia.asinh=ad.func(interval.asinh,function(a) return 1/interval.sqrt(1+a*a) end)
adia.acosh=ad.func(interval.acosh,function(a) return 1/(interval.sqrt(a-1)*interval.sqrt(a+1)) end)
adia.atanh=ad.func(interval.atanh,function(a) return 1/(1-a*a) end)

return adia
