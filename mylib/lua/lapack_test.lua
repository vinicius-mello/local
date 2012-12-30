require("array")
require("lapack")

a=array.array_double(6)
b=array.array_double(3)

a:sym_set(0,0,25)
a:sym_set(0,1,15)
a:sym_set(0,2,-5)
a:sym_set(1,1,18)
a:sym_set(1,2,0)
a:sym_set(2,2,11)

for i=0,2 do
	local row=""
  for j=0,2 do
		row=row..a:sym_get(i,j).." "
	end
	print(row)
end 
    
lapack.pptrf(3,a)
for i=0,5 do print(a:get(i)) end

b:set(0,35)
b:set(1,33)
b:set(2, 6)

lapack.pptrs(3,a,b)
for i=0,2 do print(b:get(i)) end

a:sym_set(0,0,25)
a:sym_set(0,1,15)
a:sym_set(0,2,-5)
a:sym_set(1,1,18)
a:sym_set(1,2,0)
a:sym_set(2,2,11)

z=array.array_double(3,3)
	
lapack.spev(3,a,b,z)
for i=0,2 do print(b:get(i)) end

for i=0,2 do
	local row=""
  for j=0,2 do
		row=row..z:get(i,j).." "
	end
	print(row)
end 
    
