require("array")
require("gsl")
matrix={}

local mt={}

function matrix.new(m,n)
    local t={}
    if type(m)=="table" then
        t.m=#m
        t.n=#m[1]
        t.array=array.double(t.m,t.n)
        for i=1,t.m do
            for j=1,t.n do
                t.array:set(i-1,j-1,m[i][j])
            end
        end
    else
        t.m=m
        t.n=n
        t.array=array.double(t.m,t.n)
    end
    setmetatable(t,mt)
    return t
end

function matrix.identity(m)
    local c=matrix.new(m,m)
    gsl.matrix_set_identity(c.array)
    return c
end

function matrix:size()
    return self.m,self.n
end

function matrix.add(a,b)
    if type(b)=="number" then
        a,b=b,a
    end
    local m,n=b.m,b.n
    local c=matrix.new(m,n)
    if type(a)=="number" then
        c.array:copy(b.array)
        gsl.matrix_add_constant(c.array,a)
    else
        c.array:copy(a.array)
        gsl.matrix_add(c.array,b.array)
    end
    return c
end

function matrix.sub(a,b)
    local c
    if type(a)=="number" then
        local m,n=b.m,b.n
        c=matrix.new(m,n)
        c.array:copy(b.array)
        gsl.matrix_add_constant(c.array,-a)
        gsl.matrix_scale(c.array,-1)
    elseif type(b)=="number" then
        local m,n=a.m,a.n
        c=matrix.new(m,n)
        c.array:copy(a.array)
        gsl.matrix_add_constant(c.array,-b)
    else
        local m,n=b.m,b.n
        c=matrix.new(m,n)
        c.array:copy(a.array)
        gsl.matrix_sub(c.array,b.array)
    end
    return c
end


function matrix.unm(a)
    local m,n=a.m,a.n
    local c=matrix.new(m,n)
    c.array:copy(a.array)
    gsl.matrix_scale(c.array,-1)
    return c
end

function matrix.mul(a,b)
    local c
    if type(b)=="number" then
        a,b=b,a
    end
    if type(a)=="number" then
        local m,n=b.m,b.n
        c=matrix.new(m,n)
        c.array:copy(b.array)
        gsl.matrix_scale(c.array,a)
    else
        local m,n=a.m,a.n
        local n1,p=b.m,b.n
        if n~=n1 then
            error("wrong dimensions")
        end
        c=matrix.new(m,p)
        gsl.matrix_mul(a.array,b.array,c.array)
    end
    return c
end

function matrix:tostring()
    local s=""
    s=s.."{"
    for i=1,self.m do
        s=s.."{"
        for j=1,self.n do
            if j~=1 then
                s=s..","
            end
            s=s..self.array:get(i-1,j-1)
        end
        s=s.."}"
    end
    s=s.."}"
    return s
end

function matrix:transpose()
    local m,n=self.m,self.n
    local c=matrix.new(n,m)
    gsl.matrix_transpose(c.array,self.array)
    return c
end

function matrix:get(i,j)
    return self.array:get(i,j)
end

function matrix:set(i,j,v)
    return self.array:set(i,j,v)
end

function matrix:lu_decomp()
    local m,n=self.m,self.n
    if m~=n then
        error("not a square matrix")
    end
    self.lu=array.double(m,n)
    self.lu:copy(self.array)
    self.p=array.size_t(m)
    local signum=gsl.LU_decomp(self.lu,self.p)
    self.det=gsl.LU_det(self.lu,signum)
    self.residual=array.double(m)
end

function matrix:solve(b)
    if self.lu==nil then
        self:lu_decomp()
    end
    local x=matrix.new(self.m,1)
    gsl.LU_solve(self.lu,self.p,b.array,x.array)
    gsl.LU_refine(self.array,self.lu,self.p,b.array,x.array,self.residual)
    return x
end

function matrix:det()
    if self.lu==nil then
        self:lu_decomp()
    end
    return self.det
end

function matrix:inverse()
    if self.lu==nil then
        self:lu_decomp()
    end
    local inv=matrix.new(self.m,self.n)
    gsl.LU_invert(self.lu,self.p,inv.array)
    return inv
end


mt.__add=matrix.add
mt.__sub=matrix.sub
mt.__unm=matrix.unm
mt.__mul=matrix.mul
mt.__tostring=matrix.tostring
mt.__index=matrix

return matrix
