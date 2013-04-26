bar={}
require("tw")

function bar.New(name)
    tw.NewBar(name)
    local nbar={}
    nbar.bar=name
    nbar._vars={}
    setmetatable(nbar,bar)
    return nbar
end

function bar.__index(table,key)
    if table._vars[key] then
        local type=tw.GetVarType(table.bar,key)
        if type==tw.TYPE_DOUBLE then
            return tw.GetDoubleVarByName(table.bar,key)
        elseif type==tw.TYPE_BOOL32 then
            return tw.GetBoolVarByName(table.bar,key)
        elseif type==tw.TYPE_DIR3F then
            return tw.GetArrayVarByName(table.bar,key)
        else
            return tw.GetIntVarByName(table.bar,key)
        end
    elseif type(bar[key]) ~= nil then
        return bar[key]
    else
        return rawget(table,key)
    end
end

function bar.__newindex(table,key,value)
    if table._vars[key] then
        local type=tw.GetVarType(table.bar,key)
        if type==tw.TYPE_DOUBLE then
            tw.SetDoubleVarByName(table.bar,key,value)
        elseif type==tw.TYPE_BOOL32 then
            tw.SetBoolVarByName(table.bar,key,value)
        elseif type==tw.TYPE_DIR3F then
            tw.SetArrayVarByName(table.bar,key,value)
        else
            tw.SetIntVarByName(table.bar,key,value)
        end
    else
        rawset(table,key,value)
    end
end

function bar:AddSeparator(name)
    tw.AddSeparatorByName(self.bar,name)
end

function bar:AddButton(name,cb)
    tw.AddButtonLua(self.bar,name,cb)
end

function bar:Define(prop)
    tw.Define(prop)
end

function bar:NewVar(value)
    if type(value.type)=="table" then
        local str=""
        for i=1,#value.type.enum-1 do str=str..value.type.enum[i].."," end
        str=str..value.type.enum[#value.type.enum]
        tw.NewEnum(self.bar,value.name,value.type.name,str,
        value.properties)
    else
        tw.NewVar(self.bar,value.name,value.type,value.properties)
    end
    self._vars[value.name]=true
end

return bar
