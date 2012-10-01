#ifndef WRAP_CL_HPP
#define WRAP_CL_HPP

#include <list>
#include <vector>
#include <iostream>
#include <string>
#include <sstream>
#include "debug.h"

using namespace std;

#include <CL/cl.h>
#include <CL/cl_gl.h>
#if defined(_WIN32) 
#include <windows.h>
#else
#include <GL/glx.h>
#endif

class host_singleton {
	static cl_uint nplatforms_;
	static cl_uint * ndevices_;
	static cl_device_id** devices_;
	static cl_platform_id* platforms_;
	static char buffer[1024];
	public:
	host_singleton() {
		if(platforms_==0) {
			cl_int status;
			status=clGetPlatformIDs(0, 0, &nplatforms_);
			platforms_=new cl_platform_id[nplatforms_];
			ndevices_=new cl_uint[nplatforms_];
			devices_=new cl_device_id *[nplatforms_];
			status=clGetPlatformIDs(nplatforms_, platforms_, 0);
			for(int i=0;i<nplatforms_;++i) {
				status=clGetDeviceIDs(platforms_[i],CL_DEVICE_TYPE_ALL,0,0,&ndevices_[i]);
				devices_[i]=new cl_device_id[ndevices_[i]];
				status=clGetDeviceIDs(platforms_[i],CL_DEVICE_TYPE_ALL,ndevices_[i],devices_[i],0);
			}
	  	debug_print("host_singleton new(%p)\n",this);
		}
	}
	cl_device_id device(int i, int j) const {
		return devices_[i][j];
	}
	cl_platform_id platform(int i) const {
		return platforms_[i];
	}
	~host_singleton() {
		if(platforms_!=0) {
			for(int i=0;i<nplatforms_;++i) {
				delete [] devices_[i];
			}
			delete [] devices_;
			delete [] ndevices_;
			delete [] platforms_;
			platforms_=0;
	  	debug_print("~host_singleton(%p)\n",this);
		}
	}
	int nplatforms() const {
		return nplatforms_;
	}
	int ndevices(int i) const {
		return ndevices_[i];
	}
	string get_platform_info(int i, unsigned param) const {
		clGetPlatformInfo(platform(i),param,1024,buffer,0);
		string ret(buffer);
		return ret;
	}
	string get_device_info(int i, int j, unsigned param) const {
		stringstream ss;
		switch(param) {
/*aff			 CL_DEVICE_PARTITION_AFFINITY_DOMAIN         */
/*bool*/
case			 CL_DEVICE_AVAILABLE:                         
case			 CL_DEVICE_COMPILER_AVAILABLE:                
case			 CL_DEVICE_ENDIAN_LITTLE:                     
case			 CL_DEVICE_ERROR_CORRECTION_SUPPORT:          
case			 CL_DEVICE_HOST_UNIFIED_MEMORY:               
case			 CL_DEVICE_IMAGE_SUPPORT:                     
#ifdef CL_VERSION_1_2
case			 CL_DEVICE_LINKER_AVAILABLE:                  
case			 CL_DEVICE_PREFERRED_INTEROP_USER_SYNC:       
#endif
			cl_bool b;
			clGetDeviceInfo(device(i,j),param,sizeof(cl_bool),&b,0);
			ss<<b;
			break;
/*char[]*/
#ifdef CL_VERSION_1_2
case			 CL_DEVICE_BUILT_IN_KERNELS:                  
#endif
case			 CL_DEVICE_EXTENSIONS:                        
case			 CL_DEVICE_NAME:                              
case			 CL_DEVICE_OPENCL_C_VERSION:                  
case			 CL_DEVICE_PROFILE:                           
case			 CL_DEVICE_VENDOR:                            
case			 CL_DEVICE_VERSION:                           
case			 CL_DRIVER_VERSION:                           
			clGetDeviceInfo(device(i,j),param,1024,buffer,0);
			ss<<buffer;
			break;
/*
enum			 CL_DEVICE_TYPE                              
exec_cap			 CL_DEVICE_EXECUTION_CAPABILITIES            
fp_config			 CL_DEVICE_SINGLE_FP_CONFIG                  
fp_config		 CL_DEVICE_DOUBLE_FP_CONFIG                  
mem_cache			 CL_DEVICE_GLOBAL_MEM_CACHE_TYPE             
mem_type			 CL_DEVICE_LOCAL_MEM_TYPE                    
part_pr			 CL_DEVICE_PARTITION_PROPERTIES              
part_pr			 CL_DEVICE_PARTITION_TYPE                    
queue_pr			 CL_DEVICE_QUEUE_PROPERTIES  
*/                
/*size_t*/
case			 CL_DEVICE_IMAGE2D_MAX_HEIGHT:                
case			 CL_DEVICE_IMAGE2D_MAX_WIDTH:                 
case			 CL_DEVICE_IMAGE3D_MAX_DEPTH:                 
case			 CL_DEVICE_IMAGE3D_MAX_HEIGHT:                
case			 CL_DEVICE_IMAGE3D_MAX_WIDTH:                 
#ifdef CL_VERSION_1_2
case			 CL_DEVICE_IMAGE_MAX_ARRAY_SIZE:              
case			 CL_DEVICE_IMAGE_MAX_BUFFER_SIZE:             
case			 CL_DEVICE_PRINTF_BUFFER_SIZE:                
#endif
case			 CL_DEVICE_MAX_PARAMETER_SIZE:                
case			 CL_DEVICE_MAX_WORK_GROUP_SIZE:               
case			 CL_DEVICE_PROFILING_TIMER_RESOLUTION:        
			size_t st;
			clGetDeviceInfo(device(i,j),param,sizeof(size_t),&st,0);
			ss<<st;
			break;
/*size_t[]			 CL_DEVICE_MAX_WORK_ITEM_SIZES */              
/*uint*/
case			 CL_DEVICE_ADDRESS_BITS:                      
case			 CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE:         
case			 CL_DEVICE_MAX_CLOCK_FREQUENCY:               
case			 CL_DEVICE_MAX_COMPUTE_UNITS:                 
case			 CL_DEVICE_MAX_CONSTANT_ARGS:                 
case			 CL_DEVICE_MAX_READ_IMAGE_ARGS:               
case			 CL_DEVICE_MAX_SAMPLERS:                      
case			 CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS:          
case			 CL_DEVICE_MAX_WRITE_IMAGE_ARGS:              
case			 CL_DEVICE_MEM_BASE_ADDR_ALIGN:               
case			 CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE:          
case			 CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR:          
case			 CL_DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE:        
case			 CL_DEVICE_NATIVE_VECTOR_WIDTH_FLOAT:         
case			 CL_DEVICE_NATIVE_VECTOR_WIDTH_HALF:          
case			 CL_DEVICE_NATIVE_VECTOR_WIDTH_INT:           
case			 CL_DEVICE_NATIVE_VECTOR_WIDTH_LONG:          
case			 CL_DEVICE_NATIVE_VECTOR_WIDTH_SHORT:         
#ifdef CL_VERSION_1_2
case			 CL_DEVICE_PARTITION_MAX_SUB_DEVICES:         
case			 CL_DEVICE_REFERENCE_COUNT:                   
#endif
case			 CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR:       
case			 CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE:     
case			 CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT:      
case			 CL_DEVICE_PREFERRED_VECTOR_WIDTH_HALF:       
case			 CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT:        
case			 CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG:       
case			 CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT:      
case			 CL_DEVICE_VENDOR_ID:                         
			cl_uint u;
			clGetDeviceInfo(device(i,j),param,sizeof(cl_uint),&u,0);
			ss<<u;
			break;
/*ulong*/
case			 CL_DEVICE_GLOBAL_MEM_CACHE_SIZE:             
case			 CL_DEVICE_GLOBAL_MEM_SIZE:                   
case			 CL_DEVICE_LOCAL_MEM_SIZE:                    
case			 CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE:          
case			 CL_DEVICE_MAX_MEM_ALLOC_SIZE:                
			cl_ulong ul;
			clGetDeviceInfo(device(i,j),param,sizeof(cl_ulong),&ul,0);
			ss<<ul;
			break;
default:
			break;
		}
		return ss.str();
	}
};

extern host_singleton host;

class command_queue;

class context {
	friend class command_queue;
	friend class mem;
	friend class image2d;
	friend class program;
	friend class event;
	friend class sampler;
	cl_context ctx_;
	int platform_;
	vector<cl_device_id> dev_ids_;
	public:
	context() : platform_(0), ctx_(0) {
	 	debug_print("context default(%p)\n",this);
	}
	context(int platform) : platform_(platform), ctx_(0) {
	 	debug_print("context new(%p)\n",this);
	}
	context(const context& ctx) : platform_(ctx.platform_), ctx_(ctx.ctx_),
		dev_ids_(ctx.dev_ids_)  {
		if(ctx_) {
			clRetainContext(ctx_);
	 		debug_print("context copy_cons(%p)\n",this);
		}
	}
	void add_device(int i) {
		dev_ids_.push_back(host.device(platform_,i));
	}
	void init() {
		if(ctx_) { //error
		} else {
			cl_int status;
			cl_context_properties properties[] = {
   			CL_CONTEXT_PLATFORM, (cl_context_properties) host.platform(platform_), 
   			0
			};
			ctx_=clCreateContext(properties,dev_ids_.size(),
				&dev_ids_[0],NULL,NULL,&status);
		}
	} 
	void initGL() {
		if(ctx_) { //error
		} else {
			cl_int status;
#if defined(_WIN32)
			cl_context_properties properties[] = {
				CL_GL_CONTEXT_KHR, (cl_context_properties) wglGetCurrentContext(), 
				CL_WGL_HDC_KHR, (cl_context_properties) wglGetCurrentDC(), 
				CL_CONTEXT_PLATFORM, (cl_context_properties) host.platform(platform_), 
   			0
			};
#else
			cl_context_properties properties[] = {
   			CL_GL_CONTEXT_KHR, (cl_context_properties) glXGetCurrentContext(),
   			CL_GLX_DISPLAY_KHR, (cl_context_properties) glXGetCurrentDisplay(), 
   			CL_CONTEXT_PLATFORM, (cl_context_properties) host.platform(platform_), 
   			0
			};
#endif
			ctx_=clCreateContext(properties,dev_ids_.size(),
				&dev_ids_[0],NULL,NULL,&status);
		}
	} 
	~context() {
		if(CL_SUCCESS==clReleaseContext(ctx_)) {
	 		debug_print("~context(%p)\n",this);
		} else {
	 		debug_print("error ~context(%p)\n",this);
		}
	}
};

class mem {
	friend class kernel;
	friend class command_queue;
	protected:
	cl_mem mo_;
	public:
	mem() : mo_(0) {
	 	debug_print("mem default(%p)\n",this);
	}
	mem(const context& ctx, cl_mem_flags flags, size_t size=0, void * ptr=0) {
		cl_int code;
		mo_=clCreateBuffer(ctx.ctx_,flags,size,ptr,&code);
	 	debug_print("mem new(%p)\n",this);
	} 
	mem(const mem& mo) : mo_(mo.mo_) {
		if(mo_) {
			clRetainMemObject(mo_);
	 		debug_print("mem copy_cons(%p)\n",this);
		} else {
	 		debug_print("null mem copy_cons(%p)\n",this);
		}
	}
	virtual ~mem() {
		if(CL_SUCCESS==clReleaseMemObject(mo_)) {
	 		debug_print("~mem(%p)\n",this);
		} else {
	 		debug_print("error ~mem(%p)\n",this);
		}
	}
};

class image2d : public mem {
	friend class kernel;
	friend class command_queue;
	public:
	image2d() : mem() {
	 	debug_print("image2d default(%p)\n",this);
	}
	image2d(const context& ctx, cl_mem_flags flags, cl_channel_order order,
		cl_channel_type type,	size_t image_width,	size_t image_height,
		void *host_ptr=0, size_t image_row_pitch=0) {
		cl_int code;
		cl_image_format ifmt;
		ifmt.image_channel_order=order;
		ifmt.image_channel_data_type=type;
#ifdef CL_VERSION_1_2
		cl_image_desc idesc;
		idesc.image_type=CL_MEM_OBJECT_IMAGE2D;
		idesc.image_width=image_width;
		idesc.image_height=image_height;
		idesc.image_depth=0;
		idesc.image_array_size=0;
		idesc.image_row_pitch=image_row_pitch;
		idesc.image_slice_pitch=0;
		idesc.num_mip_levels=0;
		idesc.num_samples=0;
		idesc.buffer=0;
		mo_=clCreateImage(ctx.ctx_,flags,&ifmt,&idesc,host_ptr,&code);
#else
		mo_=clCreateImage2D(ctx.ctx_,flags,&ifmt,image_width,image_height,
			image_row_pitch,host_ptr,&code);
#endif
	 	debug_print("image2d new(%p)\n",this);
	} 
	image2d(const image2d& im) {
		mem::mo_=im.mo_;
		if(mem::mo_) {
			clRetainMemObject(mem::mo_);
	 		debug_print("image2d copy_cons(%p)\n",this);
		}
	}
	virtual ~image2d() {
	 	debug_print("~image2d(%p)",this);
	}
};

class program {
	friend class kernel;
	cl_program prg_;
	public:
	program() : prg_(0) {
	 	debug_print("program default(%p)\n",this);
	}
	program(const context& ctx, const char * src) {
		cl_int code;
		prg_=clCreateProgramWithSource(ctx.ctx_,1,(const char **)&src,0,&code);
		if(clBuildProgram(prg_,0,0,0,0,0)!=CL_SUCCESS) {
			cerr<<"error building program"<<endl;
		}
	 	debug_print("program new(%p)\n",this);
	}
	program(const program& prg) : prg_(prg.prg_) {
		if(prg_) {
			clRetainProgram(prg_);
	 		debug_print("program copy_cons(%p)\n",this);
		}
	}
	~program() {
		if(CL_SUCCESS==clReleaseProgram(prg_)) {
	 		debug_print("~program(%p)\n",this);
		} else {
	 		debug_print("error ~program(%p)\n",this);
		}
	}
};

class sampler {
	friend class kernel;
	cl_sampler sam_;
	public:
	sampler() : sam_(0) {
	 	debug_print("sampler default(%p)\n",this);
	}
	sampler(const context& ctx,	bool norm,
		cl_addressing_mode addr, cl_filter_mode fil) {
		cl_int code;
		sam_=clCreateSampler(ctx.ctx_, norm, addr, fil, &code);
	 	debug_print("sampler new(%p)\n",this);
	}
	sampler(const sampler& sam) : sam_(sam.sam_) {
		if(sam_) {
			clRetainSampler(sam_);
	 		debug_print("sampler copy_cons(%p)\n",this);
		}
	}
	~sampler() {
		if(CL_SUCCESS==clReleaseSampler(sam_)) {
	 		debug_print("~sampler(%p)\n",this);
		} else {
	 		debug_print("error ~sampler(%p)\n",this);
		}
	}
};

class kernel {
	friend class command_queue;
	cl_kernel ker_;
	public:
	kernel() : ker_(0) {
	 	debug_print("kernel default(%p)\n",this);
	}
	kernel(const program& prg, const char * name) {
		cl_int code;
		ker_=clCreateKernel(prg.prg_,name,&code);
	 	debug_print("kernel new(%p)\n",this);
	}
	kernel(const kernel& ker) : ker_(ker.ker_) {
		if(ker_) {
			clRetainKernel(ker_);
	 		debug_print("kernel copy_cons(%p)\n",this);
		}
	}
	void arg(int i, const mem& mo) {
		clSetKernelArg(ker_,i,sizeof(cl_mem),&mo.mo_);
	}
	void arg(int i, int p) {
		clSetKernelArg(ker_,i,sizeof(int),&p);
	}
	void arg(int i, const sampler& s) {
		clSetKernelArg(ker_,i,sizeof(cl_sampler),&s.sam_);
	}
	~kernel() {
		if(CL_SUCCESS==clReleaseKernel(ker_)) {
	 		debug_print("~kernel(%p)\n",this);
		} else {
	 		debug_print("error ~kernel(%p)\n",this);
		}
	}
};

class event {
	friend class command_queue;
	cl_event ev_;
	public:
	event() : ev_(0) {
	 	debug_print("event default(%p)\n",this);
	}
	event(const context& ctx) {
		cl_int code;
		ev_=clCreateUserEvent(ctx.ctx_, &code);
	 	debug_print("event new(%p)\n",this);
	}
	event(const event& ev) : ev_(ev.ev_) {
		if(ev_) {
			clRetainEvent(ev_);
	 		debug_print("event copy_cons(%p)\n",this);
		}
	}
	~event() {
		if(ev_==0) debug_print("error ~event(%p): ev_==0\n",this);
		if(CL_SUCCESS==clReleaseEvent(ev_)) {
	 		debug_print("~event(%p)\n",this);
		} else {
	 		debug_print("error ~event(%p)\n",this);
		}
	}
};

class command_queue {
	cl_command_queue que_;
	vector<cl_event> wait_;
	const context * ctx_;
	cl_event * ev_;
	public:
	command_queue() : que_(0), ctx_(0), ev_(0) {
	 	debug_print("command_queue default(%p)\n",this);
	}
	command_queue(const context& ctx, int dev_id, cl_command_queue_properties pr) : ctx_(&ctx), ev_(0) {
		cl_int code;
		que_=clCreateCommandQueue(ctx.ctx_,ctx.dev_ids_[dev_id],pr,&code);
	 	debug_print("command_queue new(%p)\n",this);
	}
	command_queue(const command_queue& que) : que_(que.que_), ctx_(que.ctx_), ev_(0) {
		if(que_) {
			clRetainCommandQueue(que_);
	 		debug_print("command_queue copy_cons(%p)\n",this);
		}
	}
	~command_queue() {
		if(CL_SUCCESS==clReleaseCommandQueue(que_)) {
	 		debug_print("~command_queue(%p)\n",this);
		} else {
	 		debug_print("error ~command_queue(%p)\n",this);
		}
	}
	void add_wait(const event& ev) {
		wait_.push_back(ev.ev_);
	}
	void event(const event& ev) {
		ev_=(cl_event *)&ev.ev_;
	}
	void write_buffer(const mem& mo, bool block, size_t offset, size_t count, 
		void * ptr) {
		clEnqueueWriteBuffer(que_,mo.mo_,block,offset,count,ptr,wait_.size(),&wait_[0],ev_);
		wait_.clear();ev_=0;
	} 
	void read_buffer(const mem& mo, bool block, size_t offset, size_t count, 
		void * ptr) {
		clEnqueueReadBuffer(que_,mo.mo_,block,offset,count,ptr,wait_.size(),&wait_[0],ev_);
		wait_.clear();ev_=0;
	} 
	void range_kernel1d(const kernel& ker,size_t offset, size_t global, size_t local) {
		size_t offset_[1]; offset_[0]=offset;
		size_t global_[1]; global_[0]=global;
		size_t local_[1]; local_[0]=local;
		clEnqueueNDRangeKernel(que_,ker.ker_,1,offset_,global_,local_,wait_.size(),&wait_[0],ev_);
		wait_.clear();ev_=0;
	}
	void range_kernel2d(const kernel& ker,size_t offset_x, size_t offset_y,
		size_t global_x, size_t global_y, size_t local_x, size_t local_y) {
		size_t offset_[2]; offset_[0]=offset_x; offset_[1]=offset_y;
		size_t global_[2]; global_[0]=global_x; global_[1]=global_y;
		size_t local_[2]; local_[0]=local_x; local_[1]=local_y;

		clEnqueueNDRangeKernel(que_,ker.ker_,2,offset_,global_,local_,wait_.size(),&wait_[0],ev_);
		wait_.clear();ev_=0;
	}
	void range_kernel3d(const kernel& ker,size_t offset_x, size_t offset_y,
		size_t offset_z, size_t global_x, size_t global_y, size_t global_z,
		size_t local_x, size_t local_y, size_t local_z) {
		size_t offset_[2]; offset_[0]=offset_x; offset_[1]=offset_y; offset_[2]=offset_z;
		size_t global_[2]; global_[0]=global_x; global_[1]=global_y; global_[2]=global_z;
		size_t local_[2]; local_[0]=local_x; local_[1]=local_y; local_[2]=local_z;
		clEnqueueNDRangeKernel(que_,ker.ker_,3,offset_,global_,local_,wait_.size(),&wait_[0],ev_);
		wait_.clear();ev_=0;
	}
	void flush() {
		clFlush(que_);
	}
	void finish() {
		clFinish(que_);
	}
	void barrier() {
#ifdef CL_VERSION_1_2
		clEnqueueBarrierWithWaitList(que_,wait_.size(),&wait_[0],ev_);
		wait_.clear();ev_=0;
#else
		clEnqueueBarrier(que_);
#endif
	}
	void wait_for_events() {
#ifdef CL_VERSION_1_2
		clEnqueueMarkerWithWaitList(que_,wait_.size(),&wait_[0],ev_);
#else
		clEnqueueWaitForEvents(que_,wait_.size(),&wait_[0]);
#endif
		wait_.clear();ev_=0;
	}
	void marker() {
#ifdef CL_VERSION_1_2
		clEnqueueMarkerWithWaitList(que_,wait_.size(),&wait_[0],ev_);
#else
		clEnqueueMarker(que_,ev_);
#endif
		wait_.clear();ev_=0;
	}
};


#endif // WRAP_CL_HPP
