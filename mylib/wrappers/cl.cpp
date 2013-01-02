#include "cl.hpp"

cl_int host::code_=0;
cl_uint host::nplatforms_=0;
cl_uint * host::ndevices_=0;
cl_device_id** host::devices_=0;
cl_platform_id* host::platforms_=0;
char host::buffer[1024];


string host::get_device_info(int i, int j, unsigned param) {
    stringstream ss;
    switch(param) {
        /*aff            CL_DEVICE_PARTITION_AFFINITY_DOMAIN         */
        /*bool*/
        case             CL_DEVICE_AVAILABLE:
        case             CL_DEVICE_COMPILER_AVAILABLE:
        case             CL_DEVICE_ENDIAN_LITTLE:
        case             CL_DEVICE_ERROR_CORRECTION_SUPPORT:
        case             CL_DEVICE_HOST_UNIFIED_MEMORY:
        case             CL_DEVICE_IMAGE_SUPPORT:
#ifdef CL_VERSION_1_2
        case             CL_DEVICE_LINKER_AVAILABLE:
        case             CL_DEVICE_PREFERRED_INTEROP_USER_SYNC:
#endif
            cl_bool b;
            clGetDeviceInfo(device(i,j),param,sizeof(cl_bool),&b,0);
            ss<<b;
            break;
            /*char[]*/
#ifdef CL_VERSION_1_2
        case             CL_DEVICE_BUILT_IN_KERNELS:
#endif
        case             CL_DEVICE_EXTENSIONS:
        case             CL_DEVICE_NAME:
        case             CL_DEVICE_OPENCL_C_VERSION:
        case             CL_DEVICE_PROFILE:
        case             CL_DEVICE_VENDOR:
        case             CL_DEVICE_VERSION:
        case             CL_DRIVER_VERSION:
            clGetDeviceInfo(device(i,j),param,1024,buffer,0);
            ss<<buffer;
            break;
            /* bitfield*/
        case             CL_DEVICE_TYPE:
            cl_device_type devt;
            clGetDeviceInfo(device(i,j),param,sizeof(cl_device_type),&devt,0);
            if(devt&CL_DEVICE_TYPE_DEFAULT) ss<<"device_type_default ";
            if(devt&CL_DEVICE_TYPE_CPU) ss<<"device_type_cpu ";
            if(devt&CL_DEVICE_TYPE_GPU) ss<<"device_type_gpu ";
            if(devt&CL_DEVICE_TYPE_ACCELERATOR) ss<<"device_type_accelerator ";
            break;
        case             CL_DEVICE_EXECUTION_CAPABILITIES:
            cl_device_exec_capabilities devcap;
            clGetDeviceInfo(device(i,j),param,sizeof(cl_device_exec_capabilities),&devcap,0);
            if(devcap&CL_EXEC_KERNEL) ss<<"exec_kernel ";
            if(devcap&CL_EXEC_NATIVE_KERNEL) ss<<"exec_native_kernel ";
            break;
#ifdef CL_VERSION_1_2
        case             CL_DEVICE_DOUBLE_FP_CONFIG:
            cl_device_fp_config fpd;
            clGetDeviceInfo(device(i,j),param,sizeof(cl_device_fp_config),&fpd,0);
            if(fpd&CL_FP_DENORM) ss<<"fp_denorm ";
            if(fpd&CL_FP_INF_NAN) ss<<"fp_inf_nan ";
            if(fpd&CL_FP_ROUND_TO_NEAREST) ss<<"fp_round_to_nearest ";
            if(fpd&CL_FP_ROUND_TO_ZERO) ss<<"fp_round_to_zero ";
            if(fpd&CL_FP_ROUND_TO_INF) ss<<"fp_round_to_inf ";
            if(fpd&CL_FP_FMA) ss<<"fp_fma ";
            if(fpd&CL_FP_SOFT_FLOAT) ss<<"fp_soft_float ";
            break;
#endif
        case             CL_DEVICE_SINGLE_FP_CONFIG:
            cl_device_fp_config fps;
            clGetDeviceInfo(device(i,j),param,sizeof(cl_device_fp_config),&fps,0);
            if(fps&CL_FP_DENORM) ss<<"fp_denorm ";
            if(fps&CL_FP_INF_NAN) ss<<"fp_inf_nan ";
            if(fps&CL_FP_ROUND_TO_NEAREST) ss<<"fp_round_to_nearest ";
            if(fps&CL_FP_ROUND_TO_ZERO) ss<<"fp_round_to_zero ";
            if(fps&CL_FP_ROUND_TO_INF) ss<<"fp_round_to_inf ";
            if(fps&CL_FP_FMA) ss<<"fp_fma ";
#ifdef CL_VERSION_1_2
            if(fps&CL_FP_CORRECTLY_ROUNDED_DIVIDE_SQRT) ss<<"fp_correctly_rounded_divide_sqrt ";
#endif
            if(fps&CL_FP_SOFT_FLOAT) ss<<"fp_soft_float ";
            break;
        case             CL_DEVICE_QUEUE_PROPERTIES:
            cl_command_queue_properties cqpr;
            clGetDeviceInfo(device(i,j),param,sizeof(cl_command_queue_properties),&cqpr,0);
            if(cqpr&CL_QUEUE_PROFILING_ENABLE) ss<<"queue_profiling_enable ";
            if(cqpr&CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE) ss<<"queue_out_of_order_exec_mode_enable ";
            break;
            /*
               mem_cache             CL_DEVICE_GLOBAL_MEM_CACHE_TYPE
               mem_type          CL_DEVICE_LOCAL_MEM_TYPE
               part_pr           CL_DEVICE_PARTITION_PROPERTIES
               part_pr           CL_DEVICE_PARTITION_TYPE
               */
            /*size_t*/
        case             CL_DEVICE_IMAGE2D_MAX_HEIGHT:
        case             CL_DEVICE_IMAGE2D_MAX_WIDTH:
        case             CL_DEVICE_IMAGE3D_MAX_DEPTH:
        case             CL_DEVICE_IMAGE3D_MAX_HEIGHT:
        case             CL_DEVICE_IMAGE3D_MAX_WIDTH:
#ifdef CL_VERSION_1_2
        case             CL_DEVICE_IMAGE_MAX_ARRAY_SIZE:
        case             CL_DEVICE_IMAGE_MAX_BUFFER_SIZE:
        case             CL_DEVICE_PRINTF_BUFFER_SIZE:
#endif
        case             CL_DEVICE_MAX_PARAMETER_SIZE:
        case             CL_DEVICE_MAX_WORK_GROUP_SIZE:
        case             CL_DEVICE_PROFILING_TIMER_RESOLUTION:
            size_t st;
            clGetDeviceInfo(device(i,j),param,sizeof(size_t),&st,0);
            ss<<st;
            break;
            /*size_t[]*/
        case             CL_DEVICE_MAX_WORK_ITEM_SIZES:
            size_t sts[8];
            cl_uint n;
            clGetDeviceInfo(device(i,j),CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS,sizeof(cl_uint),&n,0);
            clGetDeviceInfo(device(i,j),param,n*sizeof(size_t),sts,0);
            for(int d=0;d<n-1;++d) ss<<sts[d]<<" ";
            break;
            /*uint*/
        case             CL_DEVICE_ADDRESS_BITS:
        case             CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE:
        case             CL_DEVICE_MAX_CLOCK_FREQUENCY:
        case             CL_DEVICE_MAX_COMPUTE_UNITS:
        case             CL_DEVICE_MAX_CONSTANT_ARGS:
        case             CL_DEVICE_MAX_READ_IMAGE_ARGS:
        case             CL_DEVICE_MAX_SAMPLERS:
        case             CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS:
        case             CL_DEVICE_MAX_WRITE_IMAGE_ARGS:
        case             CL_DEVICE_MEM_BASE_ADDR_ALIGN:
        case             CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE:
        case             CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR:
        case             CL_DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE:
        case             CL_DEVICE_NATIVE_VECTOR_WIDTH_FLOAT:
        case             CL_DEVICE_NATIVE_VECTOR_WIDTH_HALF:
        case             CL_DEVICE_NATIVE_VECTOR_WIDTH_INT:
        case             CL_DEVICE_NATIVE_VECTOR_WIDTH_LONG:
        case             CL_DEVICE_NATIVE_VECTOR_WIDTH_SHORT:
#ifdef CL_VERSION_1_2
        case             CL_DEVICE_PARTITION_MAX_SUB_DEVICES:
        case             CL_DEVICE_REFERENCE_COUNT:
#endif
        case             CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR:
        case             CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE:
        case             CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT:
        case             CL_DEVICE_PREFERRED_VECTOR_WIDTH_HALF:
        case             CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT:
        case             CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG:
        case             CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT:
        case             CL_DEVICE_VENDOR_ID:
            cl_uint u;
            clGetDeviceInfo(device(i,j),param,sizeof(cl_uint),&u,0);
            ss<<u;
            break;
            /*ulong*/
        case             CL_DEVICE_GLOBAL_MEM_CACHE_SIZE:
        case             CL_DEVICE_GLOBAL_MEM_SIZE:
        case             CL_DEVICE_LOCAL_MEM_SIZE:
        case             CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE:
        case             CL_DEVICE_MAX_MEM_ALLOC_SIZE:
            cl_ulong ul;
            clGetDeviceInfo(device(i,j),param,sizeof(cl_ulong),&ul,0);
            ss<<ul;
            break;
        default:
            break;
    }
    return ss.str();
}

string host::get_error() {
    static const char * error[]={
        "success",
        "device_not_found",
        "device_not_available",
        "compiler_not_available",
        "mem_object_allocation_failure",
        "out_of_resources",
        "out_of_host_memory",
        "profiling_info_not_available",
        "mem_copy_overlap",
        "image_format_mismatch",
        "image_format_not_supported",
        "build_program_failure",
        "map_failure",
        "misaligned_sub_buffer_offset",
        "exec_status_error_for_events_in_wait_list",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "invalid_value",
        "invalid_device_type",
        "invalid_platform",
        "invalid_device",
        "invalid_context",
        "invalid_queue_properties",
        "invalid_command_queue",
        "invalid_host_ptr",
        "invalid_mem_object",
        "invalid_image_format_descriptor",
        "invalid_image_size",
        "invalid_sampler",
        "invalid_binary",
        "invalid_build_options",
        "invalid_program",
        "invalid_program_executable",
        "invalid_kernel_name",
        "invalid_kernel_definition",
        "invalid_kernel",
        "invalid_arg_index",
        "invalid_arg_value",
        "invalid_arg_size",
        "invalid_kernel_args",
        "invalid_work_dimension",
        "invalid_work_group_size",
        "invalid_work_item_size",
        "invalid_global_offset",
        "invalid_event_wait_list",
        "invalid_event",
        "invalid_operation",
        "invalid_gl_object",
        "invalid_buffer_size",
        "invalid_mip_level",
        "invalid_global_work_size",
        "invalid_property",
    };
    string s(error[-code_]);
    code_=0;
    return s;
}

