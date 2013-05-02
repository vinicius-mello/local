require("ps")

test=ps.new("test.eps")

test:BoundingBox(0,0,512,512)

test:setrgb(1,0,0)
test:setlinewidth(4)
test:moveto(-1,-1)
test:lineto(1,-1)
test:lineto(1,1)
test:lineto(-1,1)
test:closepath()
test:stroke()
