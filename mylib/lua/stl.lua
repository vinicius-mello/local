require("pack")

stl={}


function stl.create(filename,name)
    local file=io.open(filename,"wb")
    file:write(string.sub("solid "..name.."                                                                        ",1,80))
    file:write("0000")
    stl_o={}
    stl_o.file=file
    stl_o.nfacets=0
    setmetatable(stl_o,{__index=stl})
    return stl_o
end

function stl:write_facet(n,a,b,c)
    local file=self.file
    file:write(string.pack("fff",n[1],n[2],n[3]))
    file:write(string.pack("fff",a[1],a[2],a[3]))
    file:write(string.pack("fff",b[1],b[2],b[3]))
    file:write(string.pack("fff",c[1],c[2],c[3]))
    file:write(string.pack("h",0))
    self.nfacets=self.nfacets+1
end

function stl:close()
    local file=self.file
    file:seek('set',80)
    file:write(string.pack('I',self.nfacets))
    file:close()
end

return stl
