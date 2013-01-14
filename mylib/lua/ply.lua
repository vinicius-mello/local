require("pack")

ply={}


function ply.print_header(self)
    print("ply")
    print("format "..self.format.." 1.0")
    --  if self.comments then
    --  end
    for i=1,#self do
        local element=self[i]
        print("element "..element.." "..self[element].size)
        for j=1,#self[element] do
            local property=self[element][j]
            print("property "..self[element][property].." "..property)
        end
    end
    print("end_header")
end

local function break_words(line)
    local words={}
    for word in line:gmatch("%S+") do
        words[#words+1]=word
    end
    return words
end

function ply.load(filename)
    local ply_o={}
    local file=io.open(filename,"rb")
    local element
    for line in file:lines() do
        local words=break_words(line)
        if words[1]=="end_header" then
            break
        elseif words[1]=="format" then
            ply_o.format=words[2]
        elseif words[1]=="element" then
            element=words[2]
            ply_o[#ply_o+1]=element
            ply_o[element]={}
            ply_o[element].size=words[3]
        elseif words[1]=="property" then
            local el=ply_o[element]
            local property=words[#words]
            local ptype=words[2]
            el[#el+1]=property
            if ptype=="list" then
                el[property]=ptype.." "..words[3].." "..words[4]
            else
                el[property]=ptype
            end
        end
    end
    ply_o.data_pos=file:seek()
    ply_o.file=file
    setmetatable(ply_o,{__index=ply})
    return ply_o
end

function ply.create(filename, ply_o)
    local file=io.open(filename,"wb")
    file:write("ply\n")
    file:write("format "..ply_o.format.." 1.0\n")
    --  if ply_o.comments then
    --  end
    for i=1,#ply_o do
        local element=ply_o[i]
        file:write("element "..element.." "..ply_o[element].size.."\n")
        for j=1,#ply_o[element] do
            local property=ply_o[element][j]
            file:write("property "..ply_o[element][property].." "..property.."\n")
        end
    end
    file:write("end_header\n")
    ply_o.data_pos=file:seek()
    ply_o.file=file
    setmetatable(ply_o,{__index=ply})
    return ply_o
end

local sizeof={
    char=1,
    int8=1,
    uchar=1,
    uint8=1,
    short=2,
    int16=2,
    ushort=2,
    uint16=2,
    int=4,
    int32=4,
    uint=4,
    uint32=4,
    float=4,
    float32=4,
    double=8,
    float64=8
}

local codeof={
    binary_little_endian={
        char="c",
        int8="c",
        uchar="b",
        uint8="b",
        short="<h",
        int16="<h",
        ushort="<H",
        uint16="<H",
        int="<i",
        int32="<i",
        uint="<I",
        uint32="<I",
        float="<f",
        float32="<f",
        double="<d",
        float64="<d"
    },
    binary_big_endian={
        char="c",
        int8="c",
        uchar="b",
        uint8="b",
        short=">h",
        int16=">h",
        ushort=">H",
        uint16=">H",
        int=">i",
        int32=">i",
        uint=">I",
        uint32=">I",
        float=">f",
        float32=">f",
        double=">d",
        float64=">d"
    },
    binary_native={
        char="c",
        int8="c",
        uchar="b",
        uint8="b",
        short="=h",
        int16="=h",
        ushort="=H",
        uint16="=H",
        int="=i",
        int32="=i",
        uint="=I",
        uint32="=I",
        float="=f",
        float32="=f",
        double="=d",
        float64="=d"
    }
}

local function process_element(element, format)
    local pack_data={}
    for i=1,#element do
        local property=element[i]
        pack_data[#pack_data+1]=property
        pack_data[property]={}
        local ptype=element[property]
        local words=break_words(ptype)
        if words[1]=="list" then
            pack_data[property].list=true
            pack_data[property].width_count=sizeof[words[2]]
            pack_data[property].code_count=codeof[format][words[2]]
            pack_data[property].width_data=sizeof[words[3]]
            pack_data[property].code_data=codeof[format][words[3]]
        else
            pack_data[property].list=false
            pack_data[property].width=sizeof[ptype]
            pack_data[property].code=codeof[format][ptype]
        end
    end
    return pack_data
end

local function process_element_ascii(element)
    local ascii_data={}
    for i=1,#element do
        local property=element[i]
        ascii_data[#ascii_data+1]=property
        ascii_data[property]={}
        local ptype=element[property]
        local words=break_words(ptype)
        if words[1]=="list" then
            ascii_data[property].list=true
        else
            ascii_data[property].list=false
        end
    end
    return ascii_data
end

function read_words(file)
    while true do
        local line=file:read("*l")
        if line==nil then break end
        local words=break_words(line)
        for i=1,#words do
            coroutine.yield(words[i])
        end
    end
end

function ply:read_data_ascii()
    local file=self.file
    file:seek("set",self.data_pos)
    for i=1,#self do
        local element=self[i]
        local size=self[element].size
        local ascii_data=process_element_ascii(self[element])
        local next_word=coroutine.create(read_words)
        local callback=self[element.."_read_cb"]
        for j=1,size do
            local register={}
            for k=1,#ascii_data do
                local property=ascii_data[k]
                if ascii_data[property].list then
                    local st,count=coroutine.resume(next_word,file)
                    count=tonumber(count)
                    local list={}
                    for l=1,count do
                        local st,val=coroutine.resume(next_word,file)
                        list[#list+1]=tonumber(val)
                    end
                    register[property]=list
                else
                    local st,val=coroutine.resume(next_word,file)
                    register[property]=tonumber(val)
                end
            end
            if callback then
                callback(j-1,register)
            end
        end
    end
end

function ply:write_data_ascii()
    local file=self.file
    file:seek("set",self.data_pos)
    for i=1,#self do
        local element=self[i]
        local size=self[element].size
        local ascii_data=process_element_ascii(self[element])
        local callback=self[element.."_write_cb"]
        for j=1,size do
            local register
            if callback then
                register=callback(j-1)
            end
            for k=1,#ascii_data do
                local property=ascii_data[k]
                if ascii_data[property].list then
                    local list=register[property]
                    local count=#list
                    file:write(count)
                    for l=1,count do
                        local val=list[l]
                        file:write(" "..val)
                    end
                    if k==#ascii_data then
                        file:write("\n")
                    else
                        file:write(" ")
                    end
                else
                    local val=register[property]
                    file:write(val)
                    if k==#ascii_data then
                        file:write("\n")
                    else
                        file:write(" ")
                    end
                end
            end
        end
    end
end


function ply:read_data_binary()
    local file=self.file
    file:seek("set",self.data_pos)
    for i=1,#self do
        local element=self[i]
        local size=self[element].size
        local pack_data=process_element(self[element],self.format)
        local callback=self[element.."_read_cb"]
        for j=1,size do
            local register={}
            for k=1,#pack_data do
                local property=pack_data[k]
                if pack_data[property].list then
                    local data1=file:read(pack_data[property].width_count)
                    local st,count=string.unpack(data1,pack_data[property].code_count)
                    local list={}
                    --[[          for l=1,count do
                    local data=file:read(pack_data[property].width_data)
                    local st, val=string.unpack(data,pack_data[property].code_data)
                    list[#list+1]=val
                    end ]]
                    local width_data=pack_data[property].width_data
                    local code_data=pack_data[property].code_data
                    local data=file:read(width_data*count)
                    for l=0,count-1 do
                        local st, val=string.unpack(data,code_data,l*width_data+1)
                        list[#list+1]=val
                    end
                    register[property]=list
                else
                    local data=file:read(pack_data[property].width)
                    local st, val=string.unpack(data,pack_data[property].code)
                    register[property]=val
                end
            end
            if callback then
                callback(j-1,register)
            end
        end
    end
end

function ply:write_data_binary()
    local file=self.file
    file:seek("set",self.data_pos)
    for i=1,#self do
        local element=self[i]
        local size=self[element].size
        local pack_data=process_element(self[element],self.format)
        local callback=self[element.."_write_cb"]
        for j=1,size do
            local register
            if callback then
                register=callback(j-1)
            end
            for k=1,#pack_data do
                local property=pack_data[k]
                if pack_data[property].list then
                    local list=register[property]
                    local count=#list
                    local pcount=string.pack(pack_data[property].code_count,count)
                    file:write(pcount)
                    for l=1,count do
                        local val=string.pack(pack_data[property].code_data,list[l])
                        file:write(val)
                    end
                else
                    local val=string.pack(pack_data[property].code,register[property])
                    file:write(val)
                end
            end
        end
    end
end

function ply:read_data()
    if self.format=="ascii" then
        self:read_data_ascii()
    else
        self:read_data_binary()
    end
end

function ply:write_data()
    if self.format=="ascii" then
        self:write_data_ascii()
    else
        self:write_data_binary()
    end
end


return ply
