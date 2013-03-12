twbar={}
require("tw")

local mt={}

function twbar.new(name)
    tw.NewBar(name)
    local bar={}
    bar.bar=name
    setmetatable(bar,mt)
    return bar
end

function mt.__index(table,key)
    local type=tw.GetVarType(table.bar,key)
    if type==tw.TYPE_DOUBLE then
        return tw.GetDoubleVarByName(table.bar,key)
    elseif type==tw.TYPE_DIR3F then
        return tw.GetArrayVarByName(table.bar,key)
    end
end

function mt.__newindex(table,key,value)
    if type(value)=="table" then
        if type(value.type)=="table" then
            tw.NewEnum(table.bar,key,value.type.name,value.type.enum,
            value.properties)
        else
            tw.NewVar(table.bar,key,value.type,value.properties)
        end
    else
        local type=tw.GetVarType(table.bar,key)
        if type==tw.TYPE_DOUBLE then
            tw.SetDoubleVarByName(table.bar,key,value)
        elseif type==tw.TYPE_DIR3F then
            tw.SetArrayVarByName(table.bar,key,value)
        end
    end
end

return twbar
