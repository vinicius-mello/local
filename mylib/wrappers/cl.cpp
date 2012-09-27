#include "cl.hpp"

cl_uint host_singleton::nplatforms_=0;
cl_uint * host_singleton::ndevices_=0;
cl_device_id** host_singleton::devices_=0;
cl_platform_id* host_singleton::platforms_=0;

host_singleton host;

