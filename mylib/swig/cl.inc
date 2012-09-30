/* Error Codes */
#define SUCCESS                                  0
#define DEVICE_NOT_FOUND                         -1
#define DEVICE_NOT_AVAILABLE                     -2
#define COMPILER_NOT_AVAILABLE                   -3
#define MEM_OBJECT_ALLOCATION_FAILURE            -4
#define OUT_OF_RESOURCES                         -5
#define OUT_OF_HOST_MEMORY                       -6
#define PROFILING_INFO_NOT_AVAILABLE             -7
#define MEM_COPY_OVERLAP                         -8
#define IMAGE_FORMAT_MISMATCH                    -9
#define IMAGE_FORMAT_NOT_SUPPORTED               -10
#define BUILD_PROGRAM_FAILURE                    -11
#define MAP_FAILURE                              -12
#define MISALIGNED_SUB_BUFFER_OFFSET             -13
#define EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST -14
#define COMPILE_PROGRAM_FAILURE                  -15
#define LINKER_NOT_AVAILABLE                     -16
#define LINK_PROGRAM_FAILURE                     -17
#define DEVICE_PARTITION_FAILED                  -18
#define KERNEL_ARG_INFO_NOT_AVAILABLE            -19

#define INVALID_VALUE                            -30
#define INVALID_DEVICE_TYPE                      -31
#define INVALID_PLATFORM                         -32
#define INVALID_DEVICE                           -33
#define INVALID_CONTEXT                          -34
#define INVALID_QUEUE_PROPERTIES                 -35
#define INVALID_COMMAND_QUEUE                    -36
#define INVALID_HOST_PTR                         -37
#define INVALID_MEM_OBJECT                       -38
#define INVALID_IMAGE_FORMAT_DESCRIPTOR          -39
#define INVALID_IMAGE_SIZE                       -40
#define INVALID_SAMPLER                          -41
#define INVALID_BINARY                           -42
#define INVALID_BUILD_OPTIONS                    -43
#define INVALID_PROGRAM                          -44
#define INVALID_PROGRAM_EXECUTABLE               -45
#define INVALID_KERNEL_NAME                      -46
#define INVALID_KERNEL_DEFINITION                -47
#define INVALID_KERNEL                           -48
#define INVALID_ARG_INDEX                        -49
#define INVALID_ARG_VALUE                        -50
#define INVALID_ARG_SIZE                         -51
#define INVALID_KERNEL_ARGS                      -52
#define INVALID_WORK_DIMENSION                   -53
#define INVALID_WORK_GROUP_SIZE                  -54
#define INVALID_WORK_ITEM_SIZE                   -55
#define INVALID_GLOBAL_OFFSET                    -56
#define INVALID_EVENT_WAIT_LIST                  -57
#define INVALID_EVENT                            -58
#define INVALID_OPERATION                        -59
#define INVALID_GL_OBJECT                        -60
#define INVALID_BUFFER_SIZE                      -61
#define INVALID_MIP_LEVEL                        -62
#define INVALID_GLOBAL_WORK_SIZE                 -63
#define INVALID_PROPERTY                         -64
#define INVALID_IMAGE_DESCRIPTOR                 -65
#define INVALID_COMPILER_OPTIONS                 -66
#define INVALID_LINKER_OPTIONS                   -67
#define INVALID_DEVICE_PARTITION_COUNT           -68

/* OpenCL Version */
#define VERSION_1_0                              1
#define VERSION_1_1                              1
#define VERSION_1_2                              1

/* cl_bool */
#define FALSE                                    0
#define TRUE                                     1
#define BLOCKING                                 CL_TRUE
#define NON_BLOCKING                             CL_FALSE

/* cl_platform_info */
#define PLATFORM_PROFILE                         0x0900
#define PLATFORM_VERSION                         0x0901
#define PLATFORM_NAME                            0x0902
#define PLATFORM_VENDOR                          0x0903
#define PLATFORM_EXTENSIONS                      0x0904

/* cl_device_type - bitfield */
#define DEVICE_TYPE_DEFAULT                      (1 << 0)
#define DEVICE_TYPE_CPU                          (1 << 1)
#define DEVICE_TYPE_GPU                          (1 << 2)
#define DEVICE_TYPE_ACCELERATOR                  (1 << 3)
#define DEVICE_TYPE_CUSTOM                       (1 << 4)
#define DEVICE_TYPE_ALL                          0xFFFFFFFF

/* cl_device_info */
#define DEVICE_TYPE                              0x1000
#define DEVICE_VENDOR_ID                         0x1001
#define DEVICE_MAX_COMPUTE_UNITS                 0x1002
#define DEVICE_MAX_WORK_ITEM_DIMENSIONS          0x1003
#define DEVICE_MAX_WORK_GROUP_SIZE               0x1004
#define DEVICE_MAX_WORK_ITEM_SIZES               0x1005
#define DEVICE_PREFERRED_VECTOR_WIDTH_CHAR       0x1006
#define DEVICE_PREFERRED_VECTOR_WIDTH_SHORT      0x1007
#define DEVICE_PREFERRED_VECTOR_WIDTH_INT        0x1008
#define DEVICE_PREFERRED_VECTOR_WIDTH_LONG       0x1009
#define DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT      0x100A
#define DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE     0x100B
#define DEVICE_MAX_CLOCK_FREQUENCY               0x100C
#define DEVICE_ADDRESS_BITS                      0x100D
#define DEVICE_MAX_READ_IMAGE_ARGS               0x100E
#define DEVICE_MAX_WRITE_IMAGE_ARGS              0x100F
#define DEVICE_MAX_MEM_ALLOC_SIZE                0x1010
#define DEVICE_IMAGE2D_MAX_WIDTH                 0x1011
#define DEVICE_IMAGE2D_MAX_HEIGHT                0x1012
#define DEVICE_IMAGE3D_MAX_WIDTH                 0x1013
#define DEVICE_IMAGE3D_MAX_HEIGHT                0x1014
#define DEVICE_IMAGE3D_MAX_DEPTH                 0x1015
#define DEVICE_IMAGE_SUPPORT                     0x1016
#define DEVICE_MAX_PARAMETER_SIZE                0x1017
#define DEVICE_MAX_SAMPLERS                      0x1018
#define DEVICE_MEM_BASE_ADDR_ALIGN               0x1019
#define DEVICE_MIN_DATA_TYPE_ALIGN_SIZE          0x101A
#define DEVICE_SINGLE_FP_CONFIG                  0x101B
#define DEVICE_GLOBAL_MEM_CACHE_TYPE             0x101C
#define DEVICE_GLOBAL_MEM_CACHELINE_SIZE         0x101D
#define DEVICE_GLOBAL_MEM_CACHE_SIZE             0x101E
#define DEVICE_GLOBAL_MEM_SIZE                   0x101F
#define DEVICE_MAX_CONSTANT_BUFFER_SIZE          0x1020
#define DEVICE_MAX_CONSTANT_ARGS                 0x1021
#define DEVICE_LOCAL_MEM_TYPE                    0x1022
#define DEVICE_LOCAL_MEM_SIZE                    0x1023
#define DEVICE_ERROR_CORRECTION_SUPPORT          0x1024
#define DEVICE_PROFILING_TIMER_RESOLUTION        0x1025
#define DEVICE_ENDIAN_LITTLE                     0x1026
#define DEVICE_AVAILABLE                         0x1027
#define DEVICE_COMPILER_AVAILABLE                0x1028
#define DEVICE_EXECUTION_CAPABILITIES            0x1029
#define DEVICE_QUEUE_PROPERTIES                  0x102A
#define DEVICE_NAME                              0x102B
#define DEVICE_VENDOR                            0x102C
#define DRIVER_VERSION                           0x102D
#define DEVICE_PROFILE                           0x102E
#define DEVICE_VERSION                           0x102F
#define DEVICE_EXTENSIONS                        0x1030
#define DEVICE_PLATFORM                          0x1031
#define DEVICE_DOUBLE_FP_CONFIG                  0x1032
/* 0x1033 reserved for DEVICE_HALF_FP_CONFIG */
#define DEVICE_PREFERRED_VECTOR_WIDTH_HALF       0x1034
#define DEVICE_HOST_UNIFIED_MEMORY               0x1035
#define DEVICE_NATIVE_VECTOR_WIDTH_CHAR          0x1036
#define DEVICE_NATIVE_VECTOR_WIDTH_SHORT         0x1037
#define DEVICE_NATIVE_VECTOR_WIDTH_INT           0x1038
#define DEVICE_NATIVE_VECTOR_WIDTH_LONG          0x1039
#define DEVICE_NATIVE_VECTOR_WIDTH_FLOAT         0x103A
#define DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE        0x103B
#define DEVICE_NATIVE_VECTOR_WIDTH_HALF          0x103C
#define DEVICE_OPENCL_C_VERSION                  0x103D
#define DEVICE_LINKER_AVAILABLE                  0x103E
#define DEVICE_BUILT_IN_KERNELS                  0x103F
#define DEVICE_IMAGE_MAX_BUFFER_SIZE             0x1040
#define DEVICE_IMAGE_MAX_ARRAY_SIZE              0x1041
#define DEVICE_PARENT_DEVICE                     0x1042
#define DEVICE_PARTITION_MAX_SUB_DEVICES         0x1043
#define DEVICE_PARTITION_PROPERTIES              0x1044
#define DEVICE_PARTITION_AFFINITY_DOMAIN         0x1045
#define DEVICE_PARTITION_TYPE                    0x1046
#define DEVICE_REFERENCE_COUNT                   0x1047
#define DEVICE_PREFERRED_INTEROP_USER_SYNC       0x1048
#define DEVICE_PRINTF_BUFFER_SIZE                0x1049

/* cl_device_fp_config - bitfield */
#define FP_DENORM                                (1 << 0)
#define FP_INF_NAN                               (1 << 1)
#define FP_ROUND_TO_NEAREST                      (1 << 2)
#define FP_ROUND_TO_ZERO                         (1 << 3)
#define FP_ROUND_TO_INF                          (1 << 4)
#define FP_FMA                                   (1 << 5)
#define FP_SOFT_FLOAT                            (1 << 6)
#define FP_CORRECTLY_ROUNDED_DIVIDE_SQRT         (1 << 7)

/* cl_device_mem_cache_type */
#define NONE                                     0x0
#define READ_ONLY_CACHE                          0x1
#define READ_WRITE_CACHE                         0x2

/* cl_device_local_mem_type */
#define LOCAL                                    0x1
#define GLOBAL                                   0x2

/* cl_device_exec_capabilities - bitfield */
#define EXEC_KERNEL                              (1 << 0)
#define EXEC_NATIVE_KERNEL                       (1 << 1)

/* cl_command_queue_properties - bitfield */
#define QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE      (1 << 0)
#define QUEUE_PROFILING_ENABLE                   (1 << 1)

/* cl_context_info  */
#define CONTEXT_REFERENCE_COUNT                  0x1080
#define CONTEXT_DEVICES                          0x1081
#define CONTEXT_PROPERTIES                       0x1082
#define CONTEXT_NUM_DEVICES                      0x1083

/* cl_context_properties */
#define CONTEXT_PLATFORM                         0x1084
#define CONTEXT_INTEROP_USER_SYNC                0x1085
    
/* cl_device_partition_property */
#define DEVICE_PARTITION_EQUALLY                 0x1086
#define DEVICE_PARTITION_BY_COUNTS               0x1087
#define DEVICE_PARTITION_BY_COUNTS_LIST_END      0x0
#define DEVICE_PARTITION_BY_AFFINITY_DOMAIN      0x1088
    
/* cl_device_affinity_domain */
#define DEVICE_AFFINITY_DOMAIN_NUMA                     (1 << 0)
#define DEVICE_AFFINITY_DOMAIN_L4_CACHE                 (1 << 1)
#define DEVICE_AFFINITY_DOMAIN_L3_CACHE                 (1 << 2)
#define DEVICE_AFFINITY_DOMAIN_L2_CACHE                 (1 << 3)
#define DEVICE_AFFINITY_DOMAIN_L1_CACHE                 (1 << 4)
#define DEVICE_AFFINITY_DOMAIN_NEXT_PARTITIONABLE       (1 << 5)

/* cl_command_queue_info */
#define QUEUE_CONTEXT                            0x1090
#define QUEUE_DEVICE                             0x1091
#define QUEUE_REFERENCE_COUNT                    0x1092
#define QUEUE_PROPERTIES                         0x1093

/* cl_mem_flags - bitfield */
#define MEM_READ_WRITE                           (1 << 0)
#define MEM_WRITE_ONLY                           (1 << 1)
#define MEM_READ_ONLY                            (1 << 2)
#define MEM_USE_HOST_PTR                         (1 << 3)
#define MEM_ALLOC_HOST_PTR                       (1 << 4)
#define MEM_COPY_HOST_PTR                        (1 << 5)
// reserved                                         (1 << 6)    
#define MEM_HOST_WRITE_ONLY                      (1 << 7)
#define MEM_HOST_READ_ONLY                       (1 << 8)
#define MEM_HOST_NO_ACCESS                       (1 << 9)

/* cl_mem_migration_flags - bitfield */
#define MIGRATE_MEM_OBJECT_HOST                  (1 << 0)
#define MIGRATE_MEM_OBJECT_CONTENT_UNDEFINED     (1 << 1)

/* cl_channel_order */
#define R                                        0x10B0
#define A                                        0x10B1
#define RG                                       0x10B2
#define RA                                       0x10B3
#define RGB                                      0x10B4
#define RGBA                                     0x10B5
#define BGRA                                     0x10B6
#define ARGB                                     0x10B7
#define INTENSITY                                0x10B8
#define LUMINANCE                                0x10B9
#define Rx                                       0x10BA
#define RGx                                      0x10BB
#define RGBx                                     0x10BC

/* cl_channel_type */
#define SNORM_INT8                               0x10D0
#define SNORM_INT16                              0x10D1
#define UNORM_INT8                               0x10D2
#define UNORM_INT16                              0x10D3
#define UNORM_SHORT_565                          0x10D4
#define UNORM_SHORT_555                          0x10D5
#define UNORM_INT_101010                         0x10D6
#define SIGNED_INT8                              0x10D7
#define SIGNED_INT16                             0x10D8
#define SIGNED_INT32                             0x10D9
#define UNSIGNED_INT8                            0x10DA
#define UNSIGNED_INT16                           0x10DB
#define UNSIGNED_INT32                           0x10DC
#define HALF_FLOAT                               0x10DD
#define FLOAT                                    0x10DE

/* cl_mem_object_type */
#define MEM_OBJECT_BUFFER                        0x10F0
#define MEM_OBJECT_IMAGE2D                       0x10F1
#define MEM_OBJECT_IMAGE3D                       0x10F2
#define MEM_OBJECT_IMAGE2D_ARRAY                 0x10F3
#define MEM_OBJECT_IMAGE1D                       0x10F4
#define MEM_OBJECT_IMAGE1D_ARRAY                 0x10F5
#define MEM_OBJECT_IMAGE1D_BUFFER                0x10F6

/* cl_mem_info */
#define MEM_TYPE                                 0x1100
#define MEM_FLAGS                                0x1101
#define MEM_SIZE                                 0x1102
#define MEM_HOST_PTR                             0x1103
#define MEM_MAP_COUNT                            0x1104
#define MEM_REFERENCE_COUNT                      0x1105
#define MEM_CONTEXT                              0x1106
#define MEM_ASSOCIATED_MEMOBJECT                 0x1107
#define MEM_OFFSET                               0x1108

/* cl_image_info */
#define IMAGE_FORMAT                             0x1110
#define IMAGE_ELEMENT_SIZE                       0x1111
#define IMAGE_ROW_PITCH                          0x1112
#define IMAGE_SLICE_PITCH                        0x1113
#define IMAGE_WIDTH                              0x1114
#define IMAGE_HEIGHT                             0x1115
#define IMAGE_DEPTH                              0x1116
#define IMAGE_ARRAY_SIZE                         0x1117
#define IMAGE_BUFFER                             0x1118
#define IMAGE_NUM_MIP_LEVELS                     0x1119
#define IMAGE_NUM_SAMPLES                        0x111A

/* cl_addressing_mode */
#define ADDRESS_NONE                             0x1130
#define ADDRESS_CLAMP_TO_EDGE                    0x1131
#define ADDRESS_CLAMP                            0x1132
#define ADDRESS_REPEAT                           0x1133
#define ADDRESS_MIRRORED_REPEAT                  0x1134

/* cl_filter_mode */
#define FILTER_NEAREST                           0x1140
#define FILTER_LINEAR                            0x1141

/* cl_sampler_info */
#define SAMPLER_REFERENCE_COUNT                  0x1150
#define SAMPLER_CONTEXT                          0x1151
#define SAMPLER_NORMALIZED_COORDS                0x1152
#define SAMPLER_ADDRESSING_MODE                  0x1153
#define SAMPLER_FILTER_MODE                      0x1154

/* cl_map_flags - bitfield */
#define MAP_READ                                 (1 << 0)
#define MAP_WRITE                                (1 << 1)
#define MAP_WRITE_INVALIDATE_REGION              (1 << 2)

/* cl_program_info */
#define PROGRAM_REFERENCE_COUNT                  0x1160
#define PROGRAM_CONTEXT                          0x1161
#define PROGRAM_NUM_DEVICES                      0x1162
#define PROGRAM_DEVICES                          0x1163
#define PROGRAM_SOURCE                           0x1164
#define PROGRAM_BINARY_SIZES                     0x1165
#define PROGRAM_BINARIES                         0x1166
#define PROGRAM_NUM_KERNELS                      0x1167
#define PROGRAM_KERNEL_NAMES                     0x1168

/* cl_program_build_info */
#define PROGRAM_BUILD_STATUS                     0x1181
#define PROGRAM_BUILD_OPTIONS                    0x1182
#define PROGRAM_BUILD_LOG                        0x1183
#define PROGRAM_BINARY_TYPE                      0x1184
    
/* cl_program_binary_type */
#define PROGRAM_BINARY_TYPE_NONE                 0x0
#define PROGRAM_BINARY_TYPE_COMPILED_OBJECT      0x1
#define PROGRAM_BINARY_TYPE_LIBRARY              0x2
#define PROGRAM_BINARY_TYPE_EXECUTABLE           0x4

/* cl_build_status */
#define BUILD_SUCCESS                            0
#define BUILD_NONE                               -1
#define BUILD_ERROR                              -2
#define BUILD_IN_PROGRESS                        -3

/* cl_kernel_info */
#define KERNEL_FUNCTION_NAME                     0x1190
#define KERNEL_NUM_ARGS                          0x1191
#define KERNEL_REFERENCE_COUNT                   0x1192
#define KERNEL_CONTEXT                           0x1193
#define KERNEL_PROGRAM                           0x1194
#define KERNEL_ATTRIBUTES                        0x1195

/* cl_kernel_arg_info */
#define KERNEL_ARG_ADDRESS_QUALIFIER             0x1196
#define KERNEL_ARG_ACCESS_QUALIFIER              0x1197
#define KERNEL_ARG_TYPE_NAME                     0x1198
#define KERNEL_ARG_TYPE_QUALIFIER                0x1199
#define KERNEL_ARG_NAME                          0x119A

/* cl_kernel_arg_address_qualifier */
#define KERNEL_ARG_ADDRESS_GLOBAL                0x119B
#define KERNEL_ARG_ADDRESS_LOCAL                 0x119C
#define KERNEL_ARG_ADDRESS_CONSTANT              0x119D
#define KERNEL_ARG_ADDRESS_PRIVATE               0x119E

/* cl_kernel_arg_access_qualifier */
#define KERNEL_ARG_ACCESS_READ_ONLY              0x11A0
#define KERNEL_ARG_ACCESS_WRITE_ONLY             0x11A1
#define KERNEL_ARG_ACCESS_READ_WRITE             0x11A2
#define KERNEL_ARG_ACCESS_NONE                   0x11A3
    
/* cl_kernel_arg_type_qualifer */
#define KERNEL_ARG_TYPE_NONE                     0
#define KERNEL_ARG_TYPE_CONST                    (1 << 0)
#define KERNEL_ARG_TYPE_RESTRICT                 (1 << 1)
#define KERNEL_ARG_TYPE_VOLATILE                 (1 << 2)

/* cl_kernel_work_group_info */
#define KERNEL_WORK_GROUP_SIZE                   0x11B0
#define KERNEL_COMPILE_WORK_GROUP_SIZE           0x11B1
#define KERNEL_LOCAL_MEM_SIZE                    0x11B2
#define KERNEL_PREFERRED_WORK_GROUP_SIZE_MULTIPLE 0x11B3
#define KERNEL_PRIVATE_MEM_SIZE                  0x11B4
#define KERNEL_GLOBAL_WORK_SIZE                  0x11B5

/* cl_event_info  */
#define EVENT_COMMAND_QUEUE                      0x11D0
#define EVENT_COMMAND_TYPE                       0x11D1
#define EVENT_REFERENCE_COUNT                    0x11D2
#define EVENT_COMMAND_EXECUTION_STATUS           0x11D3
#define EVENT_CONTEXT                            0x11D4

/* cl_command_type */
#define COMMAND_NDRANGE_KERNEL                   0x11F0
#define COMMAND_TASK                             0x11F1
#define COMMAND_NATIVE_KERNEL                    0x11F2
#define COMMAND_READ_BUFFER                      0x11F3
#define COMMAND_WRITE_BUFFER                     0x11F4
#define COMMAND_COPY_BUFFER                      0x11F5
#define COMMAND_READ_IMAGE                       0x11F6
#define COMMAND_WRITE_IMAGE                      0x11F7
#define COMMAND_COPY_IMAGE                       0x11F8
#define COMMAND_COPY_IMAGE_TO_BUFFER             0x11F9
#define COMMAND_COPY_BUFFER_TO_IMAGE             0x11FA
#define COMMAND_MAP_BUFFER                       0x11FB
#define COMMAND_MAP_IMAGE                        0x11FC
#define COMMAND_UNMAP_MEM_OBJECT                 0x11FD
#define COMMAND_MARKER                           0x11FE
#define COMMAND_ACQUIRE_GL_OBJECTS               0x11FF
#define COMMAND_RELEASE_GL_OBJECTS               0x1200
#define COMMAND_READ_BUFFER_RECT                 0x1201
#define COMMAND_WRITE_BUFFER_RECT                0x1202
#define COMMAND_COPY_BUFFER_RECT                 0x1203
#define COMMAND_USER                             0x1204
#define COMMAND_BARRIER                          0x1205
#define COMMAND_MIGRATE_MEM_OBJECTS              0x1206
#define COMMAND_FILL_BUFFER                      0x1207
#define COMMAND_FILL_IMAGE                       0x1208

/* command execution status */
#define COMPLETE                                 0x0
#define RUNNING                                  0x1
#define SUBMITTED                                0x2
#define QUEUED                                   0x3

/* cl_buffer_create_type  */
#define BUFFER_CREATE_TYPE_REGION                0x1220

/* cl_profiling_info  */
#define PROFILING_COMMAND_QUEUED                 0x1280
#define PROFILING_COMMAND_SUBMIT                 0x1281
#define PROFILING_COMMAND_START                  0x1282
#define PROFILING_COMMAND_END                    0x1283

