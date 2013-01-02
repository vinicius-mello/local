dofile("modules.lua")
require("ply")
require("eig")
require("vec")
require("triplets")

function to_sparse(self,t)
  local s
  if t and t.sym then
    local nz=0
		self:iter_reset()
		repeat
		  if self:iter_i()>=self:iter_j() then nz=nz+1 end
			self:iter_next()
		until self:iter_end()
    s=sparse.sparse(self:m(),self:n(),nz,t.sym)
    self:fill(s)
  else
    s=sparse.sparse(self:m(),self:n(),self:size())
    self:fill(s)
  end
  return s
end


eigensolver="arpack"
mass=false
print("Lendo header do arquivo ply")
filename=arg[1]
file_out=filename:match("(.*)%.ply").."_mht.ply"
mesh=ply.load(arg[1])
mesh:print_header()

deg=array.uint(mesh.vertex.size)
are=array.double(mesh.vertex.size)
vtx=array.float(mesh.vertex.size,3)
idx=array.uint(mesh.face.size,3)

A=triplets.triplets()
B=triplets.triplets()

function mesh.vertex_read_cb(i,reg) 
  vtx:set(i,0,reg.x)
  vtx:set(i,1,reg.y)
  vtx:set(i,2,reg.z)
  deg:set(i,0)
  are:set(i,0)
end

function mesh.face_read_cb(i,reg) 
  local v={}
	local ii={}
	for j=1,3 do -- recupera os vertices e acumula o grau de cada vertice 
    local k=idx:set(i,j-1,reg.vertex_indices[j])
		ii[j]=k
		deg:set(k,deg:get(k)+1)
		v[j]=vec.new { vtx:get(k,0), vtx:get(k,1), vtx:get(k,2) }
	end
  local a=v[2]-v[1]
  local b=v[3]-v[1]
	local n=a^b
	local area=0.5*math.sqrt(n%n)
	n=0.5/area*n
	for j=1,3 do 
    local k=reg.vertex_indices[j]
	  are:set(k,are:get(k)+area/3)
	end
	for j=0,2 do 
	  local i0,i1,i2=j+1,(j+1)%3+1,(j+2)%3+1
	  local a=v[i1]-v[i0]
	  local b=v[i2]-v[i0]
		local na=math.sqrt(a%a)
		local nb=math.sqrt(b%b)
		a, b = 1/na*a, 1/nb*b
		local cos=a%b
		local cot=cos/math.sqrt(1-cos*cos)/2
		A:add_to(ii[i1],ii[i2],-cot)
	  B:add_to(ii[i1],ii[i2],area/12)
		A:add_to(ii[i2],ii[i1],-cot)
	  B:add_to(ii[i2],ii[i1],area/12)
	  A:add_to(ii[i1],ii[i1],cot)
	  A:add_to(ii[i2],ii[i2],cot)
	  B:add_to(ii[i0],ii[i0],area/6)
	end
end

print("Processando arquivo ply")
mesh:read_data()
print("Criando matriz esparsa")

A=to_sparse(A,{sym=true})
B=to_sparse(B,{sym=true})

deg=nil

print("Coleta de lixo")
collectgarbage("collect")

local nev=arg[2]+0
local band_nev=arg[3] or 50
band_nev=band_nev+0
local t1=os.time()
local attrs,values
if mass then
  attrs,values=eig.sym {A=A, B=B, nev=nev, band_nev=band_nev, tol=0.000001, 
	solver="ma57", eigensolver=eigensolver}
else
  attrs,values=eig.sym {A=A, B=are, nev=nev, band_nev=band_nev, tol=0.000001,
	solver="ma57", eigensolver=eigensolver}
end 
local t2=os.time()
print(os.difftime(t2,t1))

print("Coleta de lixo")
collectgarbage("collect")

out_fmt={
          format="binary_little_endian",
          eigenvector={
					  size=nev,
					  eigenvalue="float",
						coords="list int float";
					  "eigenvalue","coords"
					} ;
          "eigenvector"
				}

out=ply.create(file_out,out_fmt)

function out.eigenvector_write_cb(i)
  local reg={}
	reg.eigenvalue=values[i+1]
	reg.coords={}
	for j=1,attrs[i+1]:size() do
	  reg.coords[#reg.coords+1]=attrs[i+1]:get(j-1)
	end
	return reg
end

out:write_data()

