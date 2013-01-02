#include <iostream>
#include "cl.hpp"

using namespace std;

const char *KernelSource =
"__kernel void hello(__global float *input, __global float *output)\n"\
        "{\n"\
        " size_t id = get_global_id(0);\n"\
        " output[id] = input[id] * input[id];\n"\
        "}\n"\
        "\n";

const size_t DATA_SIZE=10;

int main() {
    host::init();
    cout<<host::nplatforms()<<endl;
    cout<<host::ndevices(0)<<endl;
    cout<<host::get_device_info(0,0,CL_DEVICE_NAME)<<endl;
    context ctx(0);
    ctx.add_device(0);
    ctx.init();
    float inputData[DATA_SIZE]={1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    float results[DATA_SIZE]={1, 1, 2, 2, 3, 3, 4, 4, 5, 5};
    command_queue cmd(ctx,0,0);
    mem input(ctx, CL_MEM_READ_ONLY, sizeof(float) * DATA_SIZE, 0);
    mem output(ctx, CL_MEM_WRITE_ONLY, sizeof(float) * DATA_SIZE, 0);
    cmd.write_buffer(input, true, 0, sizeof(float) * DATA_SIZE, inputData);
    cmd.write_buffer(output, true, 0, sizeof(float) * DATA_SIZE, results);
    program prg(ctx,KernelSource);
    kernel krn(prg, "hello");
    krn.arg(0,input);
    krn.arg(1,output);
    cmd.range_kernel1d(krn,0,DATA_SIZE,DATA_SIZE);
    cmd.finish();
    cmd.read_buffer(output, true, 0, sizeof(float) * DATA_SIZE, results);
    cout<<"output: "<<endl;
    for(int i=0;i<DATA_SIZE; i++)
    {
        cout<<results[i]<<endl;
    }
}
