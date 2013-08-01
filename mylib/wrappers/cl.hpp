#ifndef WRAP_CL_HPP
#define WRAP_CL_HPP

#include <list>
#include <vector>
#include <iostream>
#include <string>
#include <sstream>
#include "debug.h"

using namespace std;

#ifdef __APPLE__
//#include <GL/glew.h>
#include <OpenGL/OpenGL.h>
#include <OpenGL/gl.h>
#include <OpenGL/CGLDevice.h>
#include <OpenCL/cl.h>
#include <OpenCL/opencl.h>
#include <OpenCL/cl_gl.h>
#else
//#include <GL/glew.h>
#include <GL/gl.h>
#include <CL/cl.h>
#include <CL/cl_gl.h>
#endif
#if defined(_WIN32)
#include <windows.h>
#else
#ifdef __APPLE__
#include <AGL/agl.h>
#else
#include <GL/glx.h>
#endif
#endif

class host {
    static cl_uint nplatforms_;
    static cl_uint * ndevices_;
    static cl_device_id** devices_;
    static cl_platform_id* platforms_;
    static char buffer[1024];
    public:
    static cl_int code_;
    static void init() {
        if(platforms_==0) {
            code_=clGetPlatformIDs(0, 0, &nplatforms_);
            platforms_=new cl_platform_id[nplatforms_];
            ndevices_=new cl_uint[nplatforms_];
            devices_=new cl_device_id *[nplatforms_];
            code_=clGetPlatformIDs(nplatforms_, platforms_, 0);
            for(int i=0;i<nplatforms_;++i) {
                code_=clGetDeviceIDs(platforms_[i],CL_DEVICE_TYPE_ALL,0,0,&ndevices_[i]);
                devices_[i]=new cl_device_id[ndevices_[i]];
                code_=clGetDeviceIDs(platforms_[i],CL_DEVICE_TYPE_ALL,ndevices_[i],devices_[i],0);
            }
        }
    }
    static cl_device_id device(int i, int j) {
        return devices_[i][j];
    }
    static cl_platform_id platform(int i) {
        return platforms_[i];
    }
    static void finish() {
        if(platforms_!=0) {
            for(int i=0;i<nplatforms_;++i) {
                delete [] devices_[i];
            }
            delete [] devices_;
            delete [] ndevices_;
            delete [] platforms_;
            platforms_=0;
        }
    }
    static int nplatforms() {
        return nplatforms_;
    }
    static int ndevices(int i) {
        return ndevices_[i];
    }
    static string get_platform_info(int i, unsigned param) {
        clGetPlatformInfo(platform(i),param,1024,buffer,0);
        string ret(buffer);
        return ret;
    }
    static string get_device_info(int i, int j, unsigned param);
    static string get_error();
};

class command_queue;

class context {
    friend class command_queue;
    friend class mem;
    friend class image2d;
    friend class image;
    friend class gl_texture2d;
    friend class gl_buffer;
    friend class gl_render_buffer;
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
        dev_ids_.push_back(host::device(platform_,i));
    }
    void init() {
        if(ctx_) { //error
        } else {
            cl_context_properties properties[] = {
                CL_CONTEXT_PLATFORM, (cl_context_properties) host::platform(platform_),
                0
            };
            ctx_=clCreateContext(properties,dev_ids_.size(),
                    &dev_ids_[0],NULL,NULL,&host::code_);
        }
    }
    void initGL() {
        if(ctx_) { //error
        } else {
#if defined(_WIN32)
            cl_context_properties properties[] = {
                CL_GL_CONTEXT_KHR, (cl_context_properties) wglGetCurrentContext(),
                CL_WGL_HDC_KHR, (cl_context_properties) wglGetCurrentDC(),
                CL_CONTEXT_PLATFORM, (cl_context_properties) host::platform(platform_),
                0
            };
#else
#ifdef __APPLE__
            CGLContextObj glContext = CGLGetCurrentContext();
            CGLShareGroupObj shareGroup = CGLGetShareGroup(glContext);

            cl_context_properties properties[] = {
                CL_CONTEXT_PROPERTY_USE_CGL_SHAREGROUP_APPLE,
                (cl_context_properties)shareGroup,
                0};
#else
            cl_context_properties properties[] = {
                CL_GL_CONTEXT_KHR, (cl_context_properties) glXGetCurrentContext(),
                CL_GLX_DISPLAY_KHR, (cl_context_properties) glXGetCurrentDisplay(),
                CL_CONTEXT_PLATFORM, (cl_context_properties) host::platform(platform_),
                0
            };
#endif
#endif
            ctx_=clCreateContext(properties,dev_ids_.size(),
                    &dev_ids_[0],NULL,NULL,&host::code_);
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
        mo_=clCreateBuffer(ctx.ctx_,flags,size,ptr,&host::code_);
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
    cl_mem ptr() const { return mo_;}
    virtual ~mem() {
        if(CL_SUCCESS==clReleaseMemObject(mo_)) {
            debug_print("~mem(%p)\n",this);
        } else {
            debug_print("error ~mem(%p)\n",this);
        }
    }
};

#ifndef CL_VERSION_1_2
struct cl_image_desc {
          cl_mem_object_type image_type;
          size_t image_width;
          size_t image_height;
          size_t image_depth;
          size_t image_array_size;
          size_t image_row_pitch;
          size_t image_slice_pitch;
          cl_uint num_mip_levels;
          cl_uint num_samples;
          cl_mem buffer;
};
#endif

class image : public mem {
    friend class kernel;
    friend class command_queue;
    public:
    image() : mem() {
        debug_print("image default(%p)\n",this);
    }
    image(const context& ctx, cl_mem_flags flags, const cl_image_format& ifmt,
            const cl_image_desc& idesc,
            void *host_ptr=0) {
#ifdef CL_VERSION_1_2
        mo_=clCreateImage(ctx.ctx_,flags,&ifmt,&idesc,host_ptr,&host::code_);
#else
        if(idesc.image_type==CL_MEM_OBJECT_IMAGE3D) {
            mo_=clCreateImage3D(ctx.ctx_,flags,&ifmt,idesc.image_width,idesc.image_height,
                idesc.image_depth,idesc.image_row_pitch,
                idesc.image_slice_pitch,host_ptr,&host::code_);
        } else {
            mo_=clCreateImage2D(ctx.ctx_,flags,&ifmt,idesc.image_width,idesc.image_height,
                idesc.image_row_pitch,host_ptr,&host::code_);
        }
#endif
        debug_print("image new(%p)\n",this);
    }
    image(const image& im) {
        mem::mo_=im.mo_;
        if(mem::mo_) {
            clRetainMemObject(mem::mo_);
            debug_print("image copy_cons(%p)\n",this);
        }
    }
    virtual ~image() {
        debug_print("~image(%p)",this);
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
            cl_channel_type type, size_t image_width, size_t image_height,
            void *host_ptr=0, size_t image_row_pitch=0) {
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
        mo_=clCreateImage(ctx.ctx_,flags,&ifmt,&idesc,host_ptr,&host::code_);
#else
        mo_=clCreateImage2D(ctx.ctx_,flags,&ifmt,image_width,image_height,
                image_row_pitch,host_ptr,&host::code_);
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

class gl_texture2d : public mem {
    friend class kernel;
    friend class command_queue;
    public:
    gl_texture2d() : mem() {
        debug_print("gl_texture2d default(%p)\n",this);
    }
    gl_texture2d(const context& ctx, cl_mem_flags flags, GLenum target, int miplevel, unsigned texture) {
#ifdef CL_VERSION_1_2
        mo_=clCreateFromGLTexture(ctx.ctx_,flags,target,miplevel,texture,&host::code_);
#else
        mo_=clCreateFromGLTexture2D(ctx.ctx_,flags,target,miplevel,texture,&host::code_);
#endif
    }
    gl_texture2d(const gl_texture2d& im) {
        mem::mo_=im.mo_;
        if(mem::mo_) {
            clRetainMemObject(mem::mo_);
            debug_print("gl_texture2d copy_cons(%p)\n",this);
        }
    }
    virtual ~gl_texture2d() {
        debug_print("~gl_texture2d(%p)",this);
    }
};

class gl_buffer : public mem {
    friend class kernel;
    friend class command_queue;
    public:
    gl_buffer() : mem() {
        debug_print("gl_buffer default(%p)\n",this);
    }
    gl_buffer(const context& ctx, cl_mem_flags flags, GLuint buffer) {
        mo_=clCreateFromGLBuffer(ctx.ctx_,flags,buffer,&host::code_);
    }
    gl_buffer(const gl_buffer& im) {
        mem::mo_=im.mo_;
        if(mem::mo_) {
            clRetainMemObject(mem::mo_);
            debug_print("gl_buffer copy_cons(%p)\n",this);
        }
    }
    virtual ~gl_buffer() {
        debug_print("~gl_buffer(%p)",this);
    }
};

class gl_render_buffer : public mem {
    friend class kernel;
    friend class command_queue;
    public:
    gl_render_buffer() : mem() {
        debug_print("gl_render_buffer default(%p)\n",this);
    }
    gl_render_buffer(const context& ctx, cl_mem_flags flags, GLuint buffer) {
        mo_=clCreateFromGLRenderbuffer(ctx.ctx_,flags,buffer,&host::code_);
    }
    gl_render_buffer(const gl_render_buffer& im) {
        mem::mo_=im.mo_;
        if(mem::mo_) {
            clRetainMemObject(mem::mo_);
            debug_print("gl_render_buffer copy_cons(%p)\n",this);
        }
    }
    virtual ~gl_render_buffer() {
        debug_print("~gl_render_buffer(%p)",this);
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
        prg_=clCreateProgramWithSource(ctx.ctx_,1,(const char **)&src,0,&host::code_);
        if(clBuildProgram(prg_,0,0,0,0,0)!=CL_SUCCESS) {
            char buffer[64*1024];
            unsigned err=clGetProgramBuildInfo(prg_,
                ctx.dev_ids_[0], CL_PROGRAM_BUILD_LOG, 64*1024,buffer,0);
            switch(err) {
                case CL_INVALID_DEVICE:
                    cerr<<"invalid device"<<endl;
                    break;
                case CL_INVALID_VALUE:
                    cerr<<"invalid value"<<endl;
                    break;
                case CL_INVALID_PROGRAM:
                    cerr<<"invalid program"<<endl;
                    break;
                case CL_SUCCESS:
                    cerr<<buffer<<endl;
                    break;
            }
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
        sam_=clCreateSampler(ctx.ctx_, norm, addr, fil, &host::code_);
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
        ker_=clCreateKernel(prg.prg_,name,&host::code_);
        debug_print("kernel new(%p)\n",this);
    }
    kernel(const kernel& ker) : ker_(ker.ker_) {
        if(ker_) {
            clRetainKernel(ker_);
            debug_print("kernel copy_cons(%p)\n",this);
        }
    }
    void arg(int i, const mem& mo) {
        host::code_=clSetKernelArg(ker_,i,sizeof(cl_mem),&mo.mo_);
    }
    void arg(int i, int p) {
        host::code_=clSetKernelArg(ker_,i,sizeof(int),&p);
    }
    void arg(int i, float p) {
        host::code_=clSetKernelArg(ker_,i,sizeof(float),&p);
    }
    void arg_float(int i, float p) {
        host::code_=clSetKernelArg(ker_,i,sizeof(float),&p);
    }
    void arg(int i, const sampler& s) {
        host::code_=clSetKernelArg(ker_,i,sizeof(cl_sampler),&s.sam_);
    }
    string work_group_info(int platform, int device, unsigned param) {
        stringstream ss;
        switch(param) {
            case CL_KERNEL_WORK_GROUP_SIZE:
                size_t res;
                clGetKernelWorkGroupInfo(ker_,
                        host::device(platform, device),
                        param,
                        sizeof(size_t),
                        &res,0);
                ss<<res;
                break;
            case CL_KERNEL_COMPILE_WORK_GROUP_SIZE:
                size_t res3[3];
                clGetKernelWorkGroupInfo(ker_,
                        host::device(platform, device),
                        param,
                        3*sizeof(size_t),
                        &res3[0],0);
                ss<<res3[0]<<" "<<res3[1]<<" "<<res3[2];
                break;
            case CL_KERNEL_LOCAL_MEM_SIZE:
                cl_ulong resu;
                clGetKernelWorkGroupInfo(ker_,
                        host::device(platform, device),
                        param,
                        sizeof(cl_ulong),
                        &resu,0);
                ss<<resu;
                break;
        }
        return ss.str();
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
        ev_=clCreateUserEvent(ctx.ctx_, &host::code_);
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
    vector<cl_mem> obj_;
    const context * ctx_;
    cl_event * ev_;
    public:
    command_queue() : que_(0), ctx_(0), ev_(0) {
        debug_print("command_queue default(%p)\n",this);
    }
    command_queue(const context& ctx, int dev_id, cl_command_queue_properties pr) : ctx_(&ctx), ev_(0) {
        que_=clCreateCommandQueue(ctx.ctx_,ctx.dev_ids_[dev_id],pr,&host::code_);
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
    void set_event(const event& ev) {
        ev_=(cl_event *)&ev.ev_;
    }
    void write_buffer(const mem& mo, bool block, size_t offset, size_t count,
            void * ptr) {
        host::code_=clEnqueueWriteBuffer(que_,mo.mo_,block,offset,count,ptr,wait_.size(),&wait_[0],ev_);
        wait_.clear();ev_=0;
    }
    void read_buffer(const mem& mo, bool block, size_t offset, size_t count,
            void * ptr) {
        host::code_=clEnqueueReadBuffer(que_,mo.mo_,block,offset,count,ptr,wait_.size(),&wait_[0],ev_);
        wait_.clear();ev_=0;
    }
    void copy_buffer(const mem& mo_src, const mem& mo_dst,
            size_t offset_src, size_t offset_dst, size_t count) {
        host::code_=clEnqueueCopyBuffer(que_,mo_src.mo_,
                mo_dst.mo_,offset_src,offset_dst,count,wait_.size(),&wait_[0],ev_);
        wait_.clear();ev_=0;
    }
    void write_image(const mem& mo, bool block,
            size_t ox, size_t oy, size_t oz,
            size_t cx, size_t cy, size_t cz,
            size_t row_pitch,
            size_t slice_pitch,
            void * ptr) {
        size_t origin[3];
        size_t region[3];
        origin[0]=ox;origin[1]=oy;origin[2]=oz;
        region[0]=cx;region[1]=cy;region[2]=cz;
        host::code_=clEnqueueWriteImage(que_,mo.mo_,block,origin,region,row_pitch,slice_pitch,ptr,wait_.size(),&wait_[0],ev_);
        wait_.clear();ev_=0;
    }
    void read_image(const mem& mo, bool block,
            size_t ox, size_t oy, size_t oz,
            size_t cx, size_t cy, size_t cz,
            size_t row_pitch,
            size_t slice_pitch,
            void * ptr) {
        size_t origin[3];
        size_t region[3];
        origin[0]=ox;origin[1]=oy;origin[2]=oz;
        region[0]=cx;region[1]=cy;region[2]=cz;
        host::code_=clEnqueueReadImage(que_,mo.mo_,block,origin,region,row_pitch,slice_pitch,ptr,wait_.size(),&wait_[0],ev_);
        wait_.clear();ev_=0;
    }
    void range_kernel1d(const kernel& ker,size_t offset, size_t global, size_t local=0) {
        size_t offset_[1]; offset_[0]=offset;
        size_t global_[1]; global_[0]=global;
        size_t local_[1]; local_[0]=local;
        if(local==0)
            host::code_=clEnqueueNDRangeKernel(que_,ker.ker_,1,offset_,global_,0,wait_.size(),&wait_[0],ev_);
        else
            host::code_=clEnqueueNDRangeKernel(que_,ker.ker_,1,offset_,global_,local_,wait_.size(),&wait_[0],ev_);
        wait_.clear();ev_=0;
    }
    void range_kernel2d(const kernel& ker,size_t offset_x, size_t offset_y,
            size_t global_x, size_t global_y, size_t local_x=0, size_t local_y=0) {
        size_t offset_[2]; offset_[0]=offset_x; offset_[1]=offset_y;
        size_t global_[2]; global_[0]=global_x; global_[1]=global_y;
        size_t local_[2]; local_[0]=local_x; local_[1]=local_y;
        if(local_x==0 || local_y==0)
            host::code_=clEnqueueNDRangeKernel(que_,ker.ker_,2,offset_,global_,0,wait_.size(),&wait_[0],ev_);
        else
            host::code_=clEnqueueNDRangeKernel(que_,ker.ker_,2,offset_,global_,local_,wait_.size(),&wait_[0],ev_);
        wait_.clear();ev_=0;
    }
    void range_kernel3d(const kernel& ker,size_t offset_x, size_t offset_y,
            size_t offset_z, size_t global_x, size_t global_y, size_t global_z,
            size_t local_x=0, size_t local_y=0, size_t local_z=0) {
        size_t offset_[3]; offset_[0]=offset_x; offset_[1]=offset_y; offset_[2]=offset_z;
        size_t global_[3]; global_[0]=global_x; global_[1]=global_y; global_[2]=global_z;
        size_t local_[3]; local_[0]=local_x; local_[1]=local_y; local_[2]=local_z;
        if(local_x==0 || local_y==0 || local_z==0)
            host::code_=clEnqueueNDRangeKernel(que_,ker.ker_,3,offset_,global_,0,wait_.size(),&wait_[0],ev_);
        else
            host::code_=clEnqueueNDRangeKernel(que_,ker.ker_,3,offset_,global_,local_,wait_.size(),&wait_[0],ev_);
        wait_.clear();ev_=0;
    }
    void add_object(const mem& mo) {
        obj_.push_back(mo.mo_);
    }
    void aquire_globject() {
        host::code_=clEnqueueAcquireGLObjects(que_, obj_.size(), &obj_[0], wait_.size(),
                &wait_[0],ev_);
        obj_.clear();
        wait_.clear();ev_=0;
    }
    void release_globject() {
        host::code_=clEnqueueReleaseGLObjects(que_, obj_.size(), &obj_[0], wait_.size(),
                &wait_[0],ev_);
        obj_.clear();
        wait_.clear();ev_=0;
    }
    void flush() {
        host::code_=clFlush(que_);
    }
    void finish() {
        host::code_=clFinish(que_);
    }
    void barrier() {
#ifdef CL_VERSION_1_2
        host::code_=clEnqueueBarrierWithWaitList(que_,wait_.size(),&wait_[0],ev_);
        wait_.clear();ev_=0;
#else
        host::code_=clEnqueueBarrier(que_);
#endif
    }
    void wait_for_events() {
#ifdef CL_VERSION_1_2
        host::code_=clEnqueueMarkerWithWaitList(que_,wait_.size(),&wait_[0],ev_);
#else
        host::code_=clEnqueueWaitForEvents(que_,wait_.size(),&wait_[0]);
#endif
        wait_.clear();ev_=0;
    }
    void marker() {
#ifdef CL_VERSION_1_2
        host::code_=clEnqueueMarkerWithWaitList(que_,wait_.size(),&wait_[0],ev_);
#else
        host::code_=clEnqueueMarker(que_,ev_);
#endif
        wait_.clear();ev_=0;
    }
};


#endif // WRAP_CL_HPP
