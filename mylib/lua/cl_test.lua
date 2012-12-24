require("cl")
require("array")

kernel_source = [[
__kernel void hello(__global float *input, __global float *output)
{
	size_t id = get_global_id(0);
	output[id] = input[id] * input[id];
};
]]

data_size=10
cl.host_init()
print(cl.host_nplatforms())
print(cl.host_ndevices(0))
print(cl.host_get_platform_info(0,cl.PLATFORM_NAME))
print(cl.host_get_device_info(0,1,cl.DEVICE_NAME))
ctx=cl.context(0)
ctx:add_device(1)
ctx:init()


inputdata=array.array_float(data_size)
for i=1,data_size do inputdata:set(i-1,i) end
results=array.array_float(data_size)
for i=1,data_size do results:set(i-1,11-i) end

cmd=cl.command_queue(ctx,0,0)
input=cl.mem(ctx,cl.MEM_READ_ONLY, 4*data_size)
output=cl.mem(ctx,cl.MEM_WRITE_ONLY, 4*data_size)
--ev=cl.event()
--cmd:set_event(ev)
cmd:write_buffer(input, true, 0, 4*data_size, inputdata:data())
cmd:write_buffer(output, true, 0, 4*data_size, results:data())
prg=cl.program(ctx,kernel_source)
krn=cl.kernel(prg, "hello")
krn:arg(0,input)
krn:arg(1,output)
cmd:range_kernel1d(krn,0,data_size,data_size)
cmd:finish()
cmd:read_buffer(output, true, 0, 4*data_size, results:data())
print("output: ")
for i=1,data_size do print(results:get(i-1)) end

