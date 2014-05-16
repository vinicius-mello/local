
print("criando proxy")
prx=ProxyCube.new()
print("criando TF")
tr=TransferFunction.new()
print("criando Volume")
vol=VolumeFunction.new(
	function(x,y,z)
		local x2=x^2
		local y2=y^2
		local z2=z^2
		return x2*(1-x2)+y2*(1-y2)+z2*(1-z2)/0.749173
	end,32)
print("criando DVRShader")
dvr=DVRShader.new(prx,vol,tr)
print("criando Background")
back=Background.new()
print("criando Canvas")
canvas=Canvas.new(dvr,back)
print("OK")