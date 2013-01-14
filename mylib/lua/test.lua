require("array")
require("blas")

function matrix(t)
    local m=#t
    local n=#t[1]
    local a=array.array_double(m,n)
    for i=1,m do
        for j=1,n do
            a:set(i-1,j-1,t[i][j])
        end
    end
    return a
end

function print_matrix(a)
    local m=a:rows()
    local n=a:columns()
    for i=1,m do
        local line=""
        for j=1,n do
            line=line..a:get(i-1,j-1).." "
        end
        print(line)
    end
end

a=matrix {{1,2,3,4,5},{6,7,8,9,10},{11,12,13,14,15}}
b=matrix {{1,2},{1,2},{1,2},{1,2},{1,2}}
c=array.array_double(3,2)
blas.gemm(1.0,a,b,0.0,c)
print_matrix(c)
