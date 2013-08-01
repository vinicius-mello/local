transfer = {}

require("win")
require("array")
require("colormap")

function transfer.New(name,callback)
    transfer_win = win.New(name)
    transfer_win.x = {}
    transfer_win.y = {}
    transfer_win.r = {}
    transfer_win.g = {}
    transfer_win.b = {}
    transfer_win.callback=callback

    --Ponto Inicial
    transfer_win.x[1] = -0.9 -- x
    transfer_win.y[1] = 0    -- y
    transfer_win.r[1] = 0    -- r
    transfer_win.g[1] = 0    -- g
    transfer_win.b[1] = 1    -- b

    --Ponto Final
    transfer_win.x[2] = 0.9  -- x
    transfer_win.y[2] = 0    -- y
    transfer_win.r[2] = 0    -- r
    transfer_win.g[2] = 1    -- g
    transfer_win.b[2] = 0    -- b

    function transfer_win:Init()
        gl.ClearColor(0.0, 0.0, 0.0, 0.5)                  -- cor de fundo preta
        gl.ClearDepth(1.0)                              -- valor do z-buffer
        gl.Disable('DEPTH_TEST')                         -- habilita teste z-buffer
        gl.Enable('CULL_FACE')
        gl.ShadeModel('FLAT')

        self.pars = bar.New("Parameters")
        self.pars:NewVar{name = "color", type = tw.TYPE_COLOR3F, properties = "label = 'Color 1'"}

        self.pars:Define(" Parameters iconified = false")
        self.pars:Define(" GLOBAL help = 'help!'")
        self.pars:Define(" Parameters size = '300 10'")
        self.pars:Define(" Parameters valueswidth = 170")
    end

    function transfer_win:Reshape(width, height)
        gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela
        gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
        gl.LoadIdentity()                -- carrega a matriz identidade
        gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
        gl.LoadIdentity()                -- carrega a matriz identidade
        self.w = width
        self.h = height
        self.px = math.max(2/width, 2/height)
    end

    function transfer_win:Display()
        -- limpa a tela e o z-buffer
        local i
        gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')

        gl.Color(0, 1, 1)
        gl.Begin('LINE_LOOP')
        gl.Vertex(-0.9, -0.9)
        gl.Vertex(-0.9, 0.9)	
        gl.Vertex(0.9, 0.9)
        gl.Vertex(0.9, -0.9)
        gl.End()

        if self.drag == "ctrl" or self.drag == "ctrl_x" then
            self.r[self.p_i] = self.pars.color:get(0)
            self.g[self.p_i] = self.pars.color:get(1)
            self.b[self.p_i] = self.pars.color:get(2)
        end

        self:drawPoints()

        gl.Color(1, 1, 1)
        for i = 1, #self.x-1 do
            local j
            gl.Begin('LINE_STRIP')
            gl.Vertex(self.x[i], self.y[i])
            gl.Vertex(self.x[i+1], self.y[i+1])
            gl.End()
        end
        --self:PostRedisplayOthers()
        if self.callback then
            self.callback()
        end
    end

    function transfer_win:Mouse(button, state, x, y)
        x,y = self:Normalize(x, y)
        if x~= nil then	
            if button == glut.LEFT_BUTTON then
                if state == glut.DOWN then
                    if glut.GetModifiers() == glut.ACTIVE_CTRL then
                        self.drag = "new"
                        self:AddPoint(x, y)
                    else
                        local i = self:find(x, y)
                        if i ~= 0 then
                            if i == 1 or i == #self.x then
                                self.drag = "ctrl_x"
                            else
                                self.drag = "ctrl"
                            end

                            self.p_i = i
                            self.pars.color:set(0, self.r[self.p_i])
                            self.pars.color:set(1, self.g[self.p_i])
                            self.pars.color:set(2, self.b[self.p_i])
                        end
                    end
                end
            elseif button == glut.RIGHT_BUTTON then
                if state == glut.DOWN then
                    local i = self:find(x, y)
                    if i ~= 0 and i ~=1 and i~= #self.x then
                        self.drag = "remove"
                        self:RemPoint(i)
                    end
                end
            end
        end
    end

    function transfer_win:Motion(x, y)
        x,y = self:Normalize(x, y)
        if x ~= nil then
            if self.drag == "ctrl" then
                if self:IsLimitX(x, self.p_i) then
                    self.x[self.p_i] = x
                    self.y[self.p_i] = y
                end
            elseif self.drag == "ctrl_x" then
                self.y[self.p_i] = y
            end
        end
    end

    function transfer_win:Normalize(x, y)
        x = 2 * x / self.w - 1
        y = 1 - 2 * y / self.h

        if self:IsLimit(x, y) then
            return x,y
        end	

        return nil
    end

    function transfer_win:IsLimitX(x, i)
        local x_1
        local x_2
        if i > 1 and i < #self.x then	
            x_1 = self.x[i - 1]
            x_2 = self.x[i + 1]
            if x_1 <= x and x_2 >= x then
                return true
            end	
        elseif i == 1 then
            x_2 = self.x[i + 1]
            if x_2 >= x then
                return true
            end	
        elseif i == #self.x then
            x_1 = self.x[i - 1]
            if x_1 <= x then
                return true
            end	
        end

        return false
    end

    function transfer_win:IsLimit(x, y)
        if x >= -0.9 and x <= 0.9 and y >= -0.9 and y <= 0.9 then
            return true
        end	

        return false
    end

    function transfer_win:find(x, y)
        local i
        for i = 1, #self.x do
            local p_x = self.x[i]
            local p_y = self.y[i]
            if math.abs(p_x - x) < 5 * self.px and math.abs(p_y - y) < 5 * self.px then
                return i
            end
        end

        return 0
    end

    function transfer_win:drawPoints()
        for i = 1, #self.x do
            self:PrintPoint(i)
        end
    end

    function transfer_win:PrintPoint(i)
        gl.PointSize(10.0)
        gl.Color(self.r[i], self.g[i], self.b[i])
        gl.Begin('POINTS')
        gl.Vertex(self.x[i], self.y[i])
        gl.End()
    end

    function transfer_win:AddPoint(x, y)
        local p_x = self.x[1]
        local p = 0

        if x > p_x then
            p_x = self.x[#self.x]
            if x < p_x then
                for i = 2, #self.x do
                    p_x = self.x[i]
                    if x < p_x then
                        p = i
                        break
                    end
                end
            else
                p = #self.x + 1
            end
        else
            p = 1
        end

        self.x[#self.x + 1] = {}
        self.y[#self.y + 1] = {}
        self.r[#self.r + 1] = {}
        self.g[#self.g + 1] = {}
        self.b[#self.b + 1] = {}

        for j = #self.x-1, p, -1 do 
            self.x[j+1] = self.x[j]
            self.y[j+1] = self.y[j]
            self.r[j+1] = self.r[j]
            self.g[j+1] = self.g[j]
            self.b[j+1] = self.b[j]
        end

        if p == 1 or p == #self.x then
            r = 1
            g = 0
            b = 0
        else
            x1 = self.x[p-1]
            x2 = self.x[p+1]

            r1 = self.r[p-1]
            r2 = self.r[p+1]

            g1 = self.g[p-1]
            g2 = self.g[p+1]

            b1 = self.b[p-1]
            b2 = self.b[p+1]

            r = r1 * ((x - x1)/(x2 - x1)) + r2 * ((x2 - x)/(x2 - x1))
            g = g1 * ((x - x1)/(x2 - x1)) + g2 * ((x2 - x)/(x2 - x1))
            b = b1 * ((x - x1)/(x2 - x1)) + b2 * ((x2 - x)/(x2 - x1))
        end

        self.x[p] = x
        self.y[p] = y
        self.r[p] = r
        self.g[p] = g
        self.b[p] = b
    end

    function transfer_win:RemPoint(i)
        if #self.x > 2 then
            for j = i, #self.x-1 do
                self.x[j] = self.x[j+1]
                self.y[j] = self.y[j+1]
                self.r[j] = self.r[j+1]
                self.g[j] = self.g[j+1]
                self.b[j] = self.b[j+1]
            end

            self.x[#self.x] = nil
            self.y[#self.y] = nil
            self.r[#self.r] = nil
            self.g[#self.g] = nil
            self.b[#self.b] = nil
        end
    end

    function transfer_win:buildColorMap(transfer_array)
        local m={}
        m.t = {}
        m.r = {}
        m.g = {}
        m.b = {}
        m.a = {}
        for l = 1, #self.x do
            m.t[l] = (self.x[l] + 0.9)/1.8
            m.r[l] = self.r[l]
            m.g[l] = self.g[l]
            m.b[l] = self.b[l]
            m.a[l] = (self.y[l] + 0.9)/1.8
        end
        colormap.rgbamap(transfer_array, m)
    end

    return transfer_win
end

return transfer
