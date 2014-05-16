require("csg")

--csg.defaults {density=400}

obj=
	csg.difference {
		csg.box { length=2, height=2, depth=2},
		csg.cylinder { from={0,0,-1}, to={0,0,1}, radius=0.5 }
	}

stats=csg.stats(obj)

obj= csg.scale {
	csg.translate {
		obj,
		dir=-stats.center
	},
	ratio=1/stats.size	
}

for p in obj.points() do 
	print(p[1],p[2],p[3])
end

