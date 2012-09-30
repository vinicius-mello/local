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

print(cl.host:nplatforms())
print(cl.host:ndevices(0))
print(cl.host:get_platform_info(0,cl.PLATFORM_NAME))
print(cl.host:get_device_info(0,0,cl.DEVICE_NAME))
print(cl.host:get_device_info(0,0,cl.DEVICE_VERSION))
print(cl.host:get_device_info(0,0,cl.DEVICE_MAX_COMPUTE_UNITS))
ctx=cl.context(0)
ctx:add_device(0)
ctx:init()


inputdata=array.array_float(data_size)
for i=1,data_size do inputdata:set(i-1,i) end
results=array.array_float(data_size)
for i=1,data_size do results:set(i-1,11-i) end

cmd=cl.command_queue(ctx,0,0)
input=cl.mem(ctx,cl.MEM_READ_ONLY, 4*data_size)
output=cl.mem(ctx,cl.MEM_WRITE_ONLY, 4*data_size)
--testimg=cl.image2d(ctx,cl.MEM_WRITE_ONLY, cl.RGB, cl.SNORM_INT8, 200, 200)
ev=cl.event()
cmd:event(ev)
cmd:write_buffer(input, true, 0, 4*data_size, inputdata:data())
cmd:write_buffer(output, true, 0, 4*data_size, results:data())
prg=cl.program(ctx,kernel_source)
krn=cl.kernel(prg, "hello")
krn:arg(0,input)
krn:arg(1,output)
cmd:range_kernel1d(krn,0,data_size,data_size)
cmd:finish()
for i=1,data_size do results:set(i-1,0) end
cmd:read_buffer(output, true, 0, 4*data_size, results:data())
print("output: ")
for i=1,data_size do print(results:get(i-1)) end

