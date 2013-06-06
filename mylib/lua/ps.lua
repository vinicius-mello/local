ps={}

function ps:close()
    self.file:close()
end

function ps:transform(x,y)  --(x,y)\in [-1,1]^2
    local xa=self.xa
    local ya=self.ya
    local xb=self.xb
    local yb=self.yb
    x=math.floor(((xb-xa)/2*(x+1)+xa)*100)/100
    y=math.floor(((yb-ya)/2*(y+1)+ya)*100)/100
    return x,y
end

function ps:moveto(x,y)
    x,y=self:transform(x,y)
    self.file:write(x.." "..y.." m ")
end

function ps:lineto(x,y)
    x,y=self:transform(x,y)
    self.file:write(x.." "..y.." l ")
end

function ps:dot(x,y,r)
    x,y=self:transform(x,y)
    self.file:write(x.." "..y.." "..r.." dot ")
end

function ps:stroke()
    self.file:write("s\n")
end

function ps:fill()
    self.file:write("f\n")
end

function ps:newpath()
    self.file:write("np ")
end

function ps:closepath()
    self.file:write("cp ")
end

function ps:showpage()
    self.file:write("\nshowpage")
end

function ps:setrgb(r,g,b)
    self.file:write(r.." "..g.." "..b.." ".."sc ")
end

function ps:setgray(g)
    self.file:write(g.." ".."sg ")
end

function ps:setlinewidth(w)
    self.file:write(w.." ".."setlinewidth ")
end

function ps:write(str)
    self.file:write(str)
end

ps.__index=ps

function ps:BoundingBox(xa,ya,xb,yb)
    self.xa=xa
    self.ya=ya
    self.xb=xb
    self.yb=yb
    local bb="%!PS-Adobe-3.0 EPSF-3.0\n%%BoundingBox: "..xa.." "..ya.." "..xb.." "..yb.."\n"
    local preamble=[[
/np {newpath} bind def
/m {moveto} bind def
/l {lineto} bind def
/cp {closepath} bind def
/s {stroke} bind def
/f {fill} bind def
/sg {setgray} bind def
/sc {setrgbcolor} bind def
/dot {0 360 arc closepath} def
matrix currentmatrix /originmat exch def
%/umatrix {originmat matrix concatmatrix setmatrix} def
%[28.3465 0 0 28.3465 10.5 100.0] umatrix
    ]]
    self.file:write(bb..preamble)
end

function ps.new(filename)
    local t={}
    t.file = io.open(filename, "w")
    setmetatable(t,ps)
    return t
end

return ps
