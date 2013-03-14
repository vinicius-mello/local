dofile("modules.lua")
require("iuplua")
require("iupluagl")
require("luagl")
require("luaglu")
require("ply")
require("gl2")
require("array")
require("vec")
require("matrix")

print("Lendo header do arquivo ply")
filename=arg[1]
mesh=ply.load(filename)
mesh:print_header()

deg=array.uint(mesh.vertex.size)
vtx=array.float(mesh.vertex.size,3)
nml=array.float(mesh.vertex.size,3)
idx=array.uint(mesh.face.size,3)
vtx_ori=array.float(mesh.vertex.size,3)
nml_ori=array.float(mesh.vertex.size,3)
fact=1.0

bb={
    xa=math.huge,
    xb=-math.huge,
    ya=math.huge,
    yb=-math.huge,
    za=math.huge,
    zb=-math.huge
}  --bounding box


    function mesh.vertex_read_cb(i,reg)
        vtx:set(i,0,reg.x)
        vtx:set(i,1,reg.y)
        vtx:set(i,2,reg.z)
        nml:set(i,0,0)
        nml:set(i,1,0)
        nml:set(i,2,0)
        deg:set(i,0)
        bb.xa=math.min(bb.xa, reg.x)
        bb.xb=math.max(bb.xb, reg.x)
        bb.ya=math.min(bb.ya, reg.y)
        bb.yb=math.max(bb.yb, reg.y)
        bb.za=math.min(bb.za, reg.z)
        bb.zb=math.max(bb.zb, reg.z)
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
        local norm=math.sqrt(n%n)
        n=1.0/norm*n
        for j=1,3 do
            local k=reg.vertex_indices[j]
            local ns=vec.new { nml:get(k,0), nml:get(k,1), nml:get(k,2) }
            ns=ns+n
            nml:set(k,0,ns[1])
            nml:set(k,1,ns[2])
            nml:set(k,2,ns[3])
        end
    end

    print("Processando arquivo ply")
    mesh:read_data()
    print("Bounding Box: ["..bb.xa..","..bb.xb.."]x["..bb.ya..","..bb.yb.."]x["..bb.za..","..bb.zb.."]")


    --normaliza normais
    for i=0,mesh.vertex.size-1 do
        local ns=vec.new { nml:get(i,0), nml:get(i,1), nml:get(i,2) }
        ns=1/deg:get(i)*ns
        nml:set(i,0,-ns[1])
        nml:set(i,1,-ns[2])
        nml:set(i,2,-ns[3])
    end
    vtx_ori:copy(vtx)
    nml_ori:copy(nml)
    deg=nil

    --centro da bounding box
    bb.xm=(bb.xa+bb.xb)/2
    bb.ym=(bb.ya+bb.yb)/2
    bb.zm=(bb.za+bb.zb)/2

    -- monta interface
    cnv = iup.glcanvas { buffer="DOUBLE", rastersize = "480x480" }

	--Axis Menu
	axis_label = iup.label{title = "Axis"}

	x_toggle = iup.toggle{title = "X", radio = "YES"}
	y_toggle = iup.toggle{title = "Y", radio = "YES"}
	z_toggle = iup.toggle{title = "Z", radio = "YES"}

	box_toggle = iup.vbox{x_toggle, y_toggle, z_toggle}

	radio_buttons = iup.radio{box_toggle; expand="YES"}

	axis_box = iup.vbox{ALIGNMENT = "ACENTER"; axis_label, radio_buttons}

	--Twist Menu
	twist_label = iup.label{title = "Twist Factor"}
	twist_val = iup.val {ORIENTATION="HORIZONTAL", EXPAND = "YES", max=180, min=-180}

	twist_box = iup.vbox{twist_label, twist_val}

	--Taper Menu
	taper_label = iup.label{title = "Taper Function"}
	taper_functions = iup.list{"1/(x^2+1)","x^2+1","(max_x - x)/(max_x - min_x)"; dropdown = "yes", EXPAND = "YES", SIZE = 100, ACTIVE = "YES"}

	taper_box = iup.vbox{taper_label, taper_functions}

	--Bend Menu
	bend_label = iup.label{title = "Bend Factor"}
	bend_rate = iup.val {ORIENTATION="HORIZONTAL", EXPAND = "YES", max=1, min=-1}
	bend_center = iup.val {ORIENTATION="HORIZONTAL", EXPAND = "YES", max=1, min=0}

	bend_box = iup.vbox{bend_label, bend_rate, bend_center}

	--Splits
	split1 = iup.split{ORIENTATION="HORIZONTAL", LAYOUTDRAG="NO", MINMAX="600:600"; axis_box, twist_box}
	split2 = iup.split{ORIENTATION="HORIZONTAL", LAYOUTDRAG="NO", MINMAX="450:450"; taper_box, bend_box}
	split3 = iup.split{ORIENTATION="HORIZONTAL", LAYOUTDRAG="NO", MINMAX="500:500"; split1, split2}

	dlg = iup.dialog { iup.hbox {cnv,split3 } ; title="mesh"}

	function twist_val:valuechanged_cb()
		twistDeformation(self.value)
		cnv:action(0,0)
	end

	function taper_functions:action()
		if v ~= 0 then
			taperDeformation(self.value)
			cnv:action(0,0)
		end
	end

	function bend_rate:valuechanged_cb()
		bendDeformation(bend_rate.value, bend_center.value)
		cnv:action(0,0)
	end

	function bend_center:valuechanged_cb()
		bendDeformation(bend_rate.value, bend_center.value)
		cnv:action(0,0)
	end

    -- chamada quando a janela OpenGL é redimensionada
    function cnv:resize_cb(width, height)
        iup.GLMakeCurrent(self)
        gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela

        gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
        gl.LoadIdentity()                -- carrega a matriz identidade
        glu.Perspective(60,width/height,0.01,1000)

        gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
        gl.LoadIdentity()                -- carrega a matriz identidade
        self.radius=math.max((bb.zb-bb.za)/2,(bb.yb-bb.ya)/2,(bb.xb-bb.xa)/2)
        glu.LookAt(0,0,4*self.radius,0,0,0,0,1,0)
        self.model_track:resize(self.radius)
        self.light_track:resize(self.radius)
    end

    function draw_ball(radius)
        gl.Disable('LIGHTING')
        gl.Begin('LINE_LOOP')
        for theta=0,2*math.pi,math.pi/30 do
            gl.Vertex(radius*math.cos(theta),0.0,radius*math.sin(theta))
        end
        gl.End()
        gl.Begin('LINE_LOOP')
        for theta=0,2*math.pi,math.pi/30 do
            gl.Vertex(0.0,radius*math.cos(theta),radius*math.sin(theta))
        end
        gl.End()
        gl.Begin('LINE_LOOP')
        for theta=0,2*math.pi,math.pi/30 do
            gl.Vertex(radius*math.cos(theta),radius*math.sin(theta),0.0)
        end
        gl.End()
        gl.Enable('LIGHTING')
    end

    function draw_rays()
        gl.Disable('LIGHTING')
        gl.Begin('LINES')
        for x=-cnv.radius,cnv.radius,cnv.radius/4 do
            for y=-cnv.radius,cnv.radius,cnv.radius/4 do
                gl.Vertex(x,y,0)
                gl.Vertex(x,y,1000)
            end
        end
        gl.End()
        gl.Enable('LIGHTING')
    end

    -- chamada quando a janela OpenGL necessita ser desenhada
    function cnv:action(x, y)
        iup.GLMakeCurrent(self)
        -- limpa a tela e o z-buffer
        gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
        gl.EnableClientState('VERTEX_ARRAY')
        gl.EnableClientState('NORMAL_ARRAY')
        gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
        gl.LoadIdentity()
        glu.LookAt(0,0,4*self.radius,0,0,0,0,1,0)

        if self.dragging then
            gl.PushMatrix()
            self.model_track:rotate()
            gl.Color(1,1,1)
            draw_ball(self.radius)
            gl.PopMatrix()
        end
        if self.light_dragging then
            gl.PushMatrix()
            self.light_track:rotate()
            gl.Color(1,1,0)
            draw_rays()
            gl.PopMatrix()
        end

        gl.PushMatrix()
        self.light_track:transform()
        gl.Light ('LIGHT0', 'POSITION',{0,0,1000,1})
        gl.PopMatrix()

        self.model_track:transform()
        gl.Translate(-bb.xm,-bb.ym,-bb.zm)
        self.prog:bind()
        gl2.draw_triangles(idx)
        self.prog:unbind()
        gl.DisableClientState('NORMAL_ARRAY')
        gl.DisableClientState('VERTEX_ARRAY')
        -- troca buffers
        iup.GLSwapBuffers(self)
    end

    -- chamada quando a janela OpenGL é criada
    function cnv:map_cb()
        iup.GLMakeCurrent(self)
        print("Iniciando GLEW")
        gl2.init()
        print("Habilitando arrays")
        gl.EnableClientState('VERTEX_ARRAY')
        gl2.vertex_array(vtx)
        gl.DisableClientState('VERTEX_ARRAY')
        gl.EnableClientState('NORMAL_ARRAY')
        gl2.normal_array(nml)
        gl.DisableClientState('NORMAL_ARRAY')

        print("Configurando OpenGL")
        gl.ClearColor(0.0,0.0,0.0,0.5)                  -- cor de fundo preta
        gl.ClearDepth(1.0)                              -- valor do z-buffer
        gl.Enable('DEPTH_TEST')                         -- habilita teste z-buffer
        gl.DepthFunc('LEQUAL')                          -- tipo do teste
        gl.Light ('LIGHT0', 'AMBIENT', {0,0,0,1})
        gl.Light ('LIGHT0', 'DIFFUSE', {1,1,1,1})
        gl.Light ('LIGHT0', 'SPECULAR', {1,1,1,1})

        gl.ShadeModel('SMOOTH')
        gl.Enable ('LIGHTING')
        gl.Enable ('LIGHT0')
        gl.LightModel('LIGHT_MODEL_TWO_SIDE',{1,1,1,1})
        gl.Enable ('CULL_FACE')
        gl.Enable ('DEPTH_TEST')
        gl.Enable ('NORMALIZE')
		gl.FrontFace('CW')

        print("Iniciando a trackball")
        self.model_track=gl2.trackball()
        self.light_track=gl2.trackball()
        self.pressed=false
        self.dragging=false
        self.light_dragging=false

        print("Configurando os shaders")
        self.fsh=gl2.fragment_shader()
        self.fsh:load_source("mesh.frag")
        self.vsh=gl2.vertex_shader()
        self.vsh:load_source("mesh.vert")
        self.prog=gl2.program()
        self.prog:attach(self.vsh)
        self.prog:attach(self.fsh)
        self.prog:link()
        self.vsh:print_log()
        self.fsh:print_log()
        self.prog:print_log()
    end

    -- chamada quando uma tecla é pressionada
    function cnv:k_any(c)
        if c == iup.K_ESC then
            -- sai da aplicação
            iup.ExitLoop()
       --[[ elseif c == iup.K_t then
			print("t")
            fact=fact*0.9
            transform()]]
        end
        cnv:action(0,0)
    end

    function cnv:button_cb(but,pressed,x,y,status)
        iup.GLMakeCurrent(self)
        if pressed==1 then
            self.model_track:start_motion(x,y)
            self.light_track:start_motion(x,y)
            self.pressed=true
        else
            self.pressed=false
        end
        self.dragging=false
        self.light_dragging=false
        cnv:action(0,0)
    end

    function cnv:motion_cb(x,y,status)
        iup.GLMakeCurrent(self)
        if self.pressed then
            if iup.isshift(status) and iup.iscontrol(status) then
                self.light_track:move_rotation(x,y)
                self.light_dragging=true
            elseif iup.isshift(status) then
                self.model_track:move_scaling(x,y)
                self.dragging=true
            elseif iup.iscontrol(status) then
                self.model_track:move_pan(x,y)
                self.dragging=true
            elseif iup.isalt(status) then
                self.model_track:move_zoom(x,y)
                self.dragging=true
            else
                self.model_track:move_rotation(x,y)
                self.dragging=true
            end
            cnv:action(0,0)
        end
    end

--[[    function transform()
		for i=1,mesh.vertex.size do
            for j=1,3 do
                vtx:set(i-1,j-1,vtx_ori:get(i-1,j-1)*fact)
            end
        end
    end]]

	function twistDeformation(w)
		w = math.rad(w)--twist factor
		local x, y, z, cos_factor, sin_factor, X, Y, Z, der_f, transf_matrix, normal_matrix, result

		if(x_toggle.value == "ON")then
			for i = 0, mesh.vertex.size-1 do
				x = vtx_ori:get(i,0)
				y = vtx_ori:get(i,1)
				z = vtx_ori:get(i,2)

				cos_factor = math.cos(w * x)
				sin_factor = math.sin(w * x)

				Y = ((y * cos_factor) - (z * sin_factor))
				Z = ((y * sin_factor) + (z * cos_factor))

				vtx:set(i,0,x)
				vtx:set(i,1,Y)
				vtx:set(i,2,Z)

				--Calculando a normal
				der_f = w * 1

				transf_matrix = matrix.new{{1, z * der_f, -y * der_f},
										   {0, cos_factor, -sin_factor},
										   {0, sin_factor, cos_factor}
										  }

				normal_matrix = matrix.new{{nml_ori:get(i,0)},
										   {nml_ori:get(i,1)},
										   {nml_ori:get(i,2)}
										  }

				result = transf_matrix * normal_matrix

				nml:set(i, 0, result:get(0,0))
				nml:set(i, 1, result:get(1,0))
				nml:set(i, 2, result:get(2,0))
			end
		elseif(y_toggle.value == "ON")then
			for i = 0, mesh.vertex.size-1 do
				x = vtx_ori:get(i,0)
				y = vtx_ori:get(i,1)
				z = vtx_ori:get(i,2)

				cos_factor = math.cos(w * x)
				sin_factor = math.sin(w * x)

				X = ((x * cos_factor) - (z * sin_factor))
				Z = ((x * sin_factor) + (z * cos_factor))

				vtx:set(i,0,X)
				vtx:set(i,1,y)
				vtx:set(i,2,Z)

				--Calculando a normal
				der_f = w * 1

				transf_matrix = matrix.new{{cos_factor, 0, -sin_factor},
										   {z * der_f, 1, -x * der_f},
										   {sin_factor, 0, cos_factor}
										  }

				normal_matrix = matrix.new{{nml_ori:get(i,0)},
										   {nml_ori:get(i,1)},
										   {nml_ori:get(i,2)}
										  }

				result = transf_matrix * normal_matrix

				nml:set(i, 0, result:get(0,0))
				nml:set(i, 1, result:get(1,0))
				nml:set(i, 2, result:get(2,0))
			end
		elseif(z_toggle.value == "ON")then
			for i = 0, mesh.vertex.size-1 do
				x = vtx_ori:get(i,0)
				y = vtx_ori:get(i,1)
				z = vtx_ori:get(i,2)

				cos_factor = math.cos(w * z)
				sin_factor = math.sin(w * z)

				X = ((x * cos_factor) - (y * sin_factor))
				Y = ((x * sin_factor) + (y * cos_factor))
				--vtx:set(i,2,z)

				vtx:set(i,0,X)
				vtx:set(i,1,Y)
				vtx:set(i,2,z)

				--Calculando a normal
				der_f = w * 1

				transf_matrix = matrix.new{{cos_factor, -sin_factor, 0},
										   {sin_factor, cos_factor, 0},
										   {y * der_f, -x * der_f, 1}
										  }

				normal_matrix = matrix.new{{nml_ori:get(i,0)},
				                           {nml_ori:get(i,1)},
										   {nml_ori:get(i,2)}
										  }

				result = transf_matrix * normal_matrix

				nml:set(i, 0, result:get(0,0))
				nml:set(i, 1, result:get(1,0))
				nml:set(i, 2, result:get(2,0))
			end
		end
	end

	function taperDeformation(f)
		local x, y, z, X, Y, Z, r, der_f, transf_matrix, normal_matrix, result

		if(x_toggle.value == "ON")then
			for i = 0, mesh.vertex.size-1 do
				x = vtx_ori:get(i, 0)
				y = vtx_ori:get(i, 1)
				z = vtx_ori:get(i, 2)

				r = taperFunction(x, f)

				Y = r * y
				Z = r * z

				vtx:set(i, 0, x)
				vtx:set(i, 1, Y)
				vtx:set(i, 2, Z)

				--Calculando a normal
				der_f = taperDerFunction(x, f)

				transf_matrix = matrix.new{{r * r, -r * der_f * y, -r * der_f * z},
										   {0, r, 0},
										   {0, 0, r}
										  }

				normal_matrix = matrix.new{{nml_ori:get(i, 0)},
				                           {nml_ori:get(i, 1)},
										   {nml_ori:get(i, 2)}
										  }

				result = transf_matrix * normal_matrix

				nml:set(i, 0, result:get(0, 0))
				nml:set(i, 1, result:get(1, 0))
				nml:set(i, 2, result:get(2, 0))
			end
		elseif(y_toggle.value == "ON")then
			for i = 0, mesh.vertex.size-1 do
				x = vtx_ori:get(i, 0)
				y = vtx_ori:get(i, 1)
				z = vtx_ori:get(i, 2)

				r = taperFunction(y, f)

				X = r * x
				Z = r * z

				vtx:set(i, 0, X)
				vtx:set(i, 1, y)
				vtx:set(i, 2, Z)

				--Calculando a normal
				der_f = taperDerFunction(y, f)

				transf_matrix = matrix.new{{r, 0, 0},
										   {-r * der_f * x, r * r, -r * der_f * z},
										   {0, 0, r}
										  }

				normal_matrix = matrix.new{{nml_ori:get(i, 0)},
				                           {nml_ori:get(i, 1)},
										   {nml_ori:get(i, 2)}
										  }

				result = transf_matrix * normal_matrix

				nml:set(i, 0, result:get(0, 0))
				nml:set(i, 1, result:get(1, 0))
				nml:set(i, 2, result:get(2, 0))
			end
		elseif(z_toggle.value == "ON")then
			for i = 0, mesh.vertex.size-1 do
				x = vtx_ori:get(i, 0)
				y = vtx_ori:get(i, 1)
				z = vtx_ori:get(i, 2)

				r = taperFunction(z,f)

				X = r * x
				Y = r * y
				--x = (w * z) * x
				--y = (w * z) * y

				vtx:set(i, 0, X)
				vtx:set(i, 1, Y)
				vtx:set(i, 2, z)

				--Calculando a normal
				der_f = taperDerFunction(z, f)

				transf_matrix = matrix.new{{r, 0, 0},
										   {0, r, 0},
										   {-r * der_f * x, -r * der_f * y, r * r}
										  }

				normal_matrix = matrix.new{{nml_ori:get(i, 0)},
				                           {nml_ori:get(i, 1)},
										   {nml_ori:get(i, 2)}
										  }

				result = transf_matrix * normal_matrix

				nml:set(i, 0, result:get(0, 0))
				nml:set(i, 1, result:get(1, 0))
				nml:set(i, 2, result:get(2, 0))
			end
		end
	end

	function taperFunction(x, v)
		local min_, max_
		if(x_toggle.value == "ON")then
			min_ = bb.xa
			max_ = bb.xb
		elseif(y_toggle.value == "ON")then
			min_ = bb.ya
			max_ = bb.yb
		elseif(z_toggle.value == "ON")then
			min_ = bb.za
			max_ = bb.zb
		end

		if(v == '1')then
			return (1/((x * x) + 1)) --1/(x^2+1)
		elseif(v == '2')then
			return ((x * x) + 1) --x^2+1
		elseif(v == '3')then
			return (max_ - x)/(max_ - min_)
		end
	end

	function taperDerFunction(x, v)
		local min_, max_
		if(x_toggle.value == "ON")then
			min_ = bb.xa
			max_ = bb.xb
		elseif(y_toggle.value == "ON")then
			min_ = bb.ya
			max_ = bb.yb
		elseif(z_toggle.value == "ON")then
			min_ = bb.za
			max_ = bb.zb
		end

		if(v == '1')then
			d = (x * x) + 1
			return -((2 * x)/(d * d))
		elseif(v == '2')then
			return 2 * x
		elseif(v == '3')then
			return 1/(min_ - max_)
		end
	end

	function bendDeformation(k,y0)
		--k = math.rad(k)
		--1/k = radius of curvature of the bend
		--yo = ?
		local min_, max_, teta, y_, k_, x, y, z, X, Y, Z
		local bend_angle, cos_factor, sin_factor
		local transf_matrix, normal_matrix, result

		--if(y_toggle.value == "ON")then
			min_ = bb.ya/10
		    max_ = bb.yb/10

			for i = 0, mesh.vertex.size-1 do
				x = vtx_ori:get(i, 2)
				y = vtx_ori:get(i, 0)
				z = vtx_ori:get(i, 1)

				if(y <= min_)then
					y_ = min_
				elseif(min_ < y and y < max_)then
					y_ = y
				elseif(y >= max_)then
					y_ = max_
				end

				bend_angle = k * (y_ - y0)
				cos_factor = math.cos(bend_angle)
				sin_factor = math.sin(bend_angle)

				if(min_ <= y and y <= max_)then
					Y = -sin_factor * (z - (1.0/k)) + y0
					Z = cos_factor * (z - (1.0/k)) + 1.0/k
				elseif(y < min_)then
					Y = -sin_factor * (z - (1.0/k)) + y0 + cos_factor * (y - min_)
					Z = cos_factor * (z - (1.0/k)) + 1.0/k + sin_factor * (y - min_)
				elseif(y > max_)then
					Y = -sin_factor * (z - (1.0/k)) + y0 + cos_factor * (y - max_)
					Z = cos_factor * (z - (1.0/k)) + 1.0/k + sin_factor * (y - max_)
				end

				vtx:set(i, 2, x)
				vtx:set(i, 0, Y)
				vtx:set(i, 1, Z)

				--Calculando a normal
				k_ = (y_ == y) and k or 0

				transf_matrix = matrix.new{{1 - k_ * z, 0, 0},
										   {0, cos_factor, -sin_factor * (1 - k_ * z)},
										   {0, sin_factor, cos_factor * (1 - k_ * z)}
										  }

				normal_matrix = matrix.new{{nml_ori:get(i,2)},
										   {nml_ori:get(i,0)},
										   {nml_ori:get(i,1)}
										  }

				result = transf_matrix * normal_matrix

				nml:set(i, 2, result:get(0,0))
				nml:set(i, 0, result:get(1,0))
				nml:set(i, 1, result:get(2,0))
			end
	--	end
	end

    -- exibe a janela
    dlg:show()
    --filter_dlg:show()
    -- entra no loop de eventos
    iup.MainLoop()
