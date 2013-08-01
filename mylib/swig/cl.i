%module cl
%{
#include <wrappers/cl.hpp>
typedef unsigned bitfield;
typedef unsigned int uint;
%}

%include "std_string.i"
%include cl.inc

typedef unsigned bitfield;
typedef unsigned int uint;

class host {
    public:
        static void init();
        static void finish();
        static int nplatforms();
        static int ndevices(int i);
        static std::string get_platform_info(int i, unsigned param);
        static std::string get_device_info(int i, int j, unsigned param);
        static std::string get_error();
};

class context {
    public:
        context();
        context(int platform);
        context(const context& ctx);
        void add_device(int i);
        void init();
        void initGL();
        ~context();
};

class mem {
    public:
        mem();
        mem(const context& ctx, bitfield flags, size_t size=0, void * ptr=0);
        mem(const mem& mo);
        cl_mem ptr() const;
        ~mem();
};

struct cl_image_format {
    bitfield image_channel_order;
    bitfield image_channel_data_type;
};

struct cl_image_desc {
          uint image_type;
          size_t image_width;
          size_t image_height;
          size_t image_depth;
          size_t image_array_size;
          size_t image_row_pitch;
          size_t image_slice_pitch;
          uint num_mip_levels;
          uint num_samples;
          cl_mem buffer;
};

class image : public mem {
    public:
    image() : mem();
    image(const context& ctx, bitfield flags, const cl_image_format& ifmt,
            const cl_image_desc& idesc,
            void *host_ptr=0);
    image(const image& im);
    ~image();
};

class image2d : public mem {
    public:
        image2d();
        image2d(const context& ctx, bitfield flags, unsigned order,
                unsigned type, size_t image_width, size_t image_height,
                void *host_ptr=0, size_t image_row_pitch=0);
        image2d(const image2d& im);
        ~image2d();
};

class gl_texture2d : public mem {
    public:
        gl_texture2d() : mem();
        gl_texture2d(const context& ctx, bitfield flags, unsigned target, int miplevel, unsigned texture);
        gl_texture2d(const gl_texture2d& im);
        virtual ~gl_texture2d();
};

class gl_buffer : public mem {
    public:
        gl_buffer() : mem();
        gl_buffer(const context& ctx, bitfield flags, unsigned buffer);
        gl_buffer(const gl_buffer& im);
        virtual ~gl_buffer();
};

class gl_render_buffer : public mem {
    public:
        gl_render_buffer() : mem();
        gl_render_buffer(const context& ctx, bitfield flags, unsigned buffer);
        gl_render_buffer(const gl_render_buffer& im);
        virtual ~gl_render_buffer();
};

class program {
    public:
        program();
        program(const context& ctx, const char * src);
        program(const program& prg) : prg_(prg.prg_);
        ~program();
};

class sampler {
    public:
        sampler();
        sampler(const context& ctx,	bool norm,
                unsigned addr, unsigned fil);
        sampler(const sampler& sam);
        ~sampler();
};

class kernel {
    public:
        kernel();
        kernel(const program& prg, const char * name);
        kernel(const kernel& ker) : ker_(ker.ker_);
        void arg(int i, const mem& mo);
        void arg(int i, int p);
        void arg_float(int i, float p);
        void arg(int i, const sampler& s);
        std::string work_group_info(int platform, int device, unsigned param);
        ~kernel();
};

class event {;
    public:
        event();
        event(const context& ctx);
        event(const event& ev);
        ~event();
};

class command_queue {
    public:
        command_queue();
        command_queue(const context& ctx, int dev_id, bitfield pr); 
        command_queue(const command_queue& que);
        ~command_queue();
        void add_wait(const event& ev);
        void set_event(const event& ev);
        void write_buffer(const mem& mo, bool block, size_t offset, size_t count, 
                void * ptr) ;
        void read_buffer(const mem& mo, bool block, size_t offset, size_t count, 
                void * ptr) ;
        void copy_buffer(const mem& mo_src, const mem& mo_dst,
            size_t offset_src, size_t offset_dst, size_t count) ;
        void write_image(const mem& mo, bool block,
            size_t ox, size_t oy, size_t oz,
            size_t cx, size_t cy, size_t cz,
            size_t row_pitch,
            size_t slice_pitch,
            void * ptr) ;
        void read_image(const mem& mo, bool block,
            size_t ox, size_t oy, size_t oz,
            size_t cx, size_t cy, size_t cz,
            size_t row_pitch,
            size_t slice_pitch,
            void * ptr) ;
        void range_kernel1d(const kernel& ker,size_t offset, size_t global, size_t local=0) ;
        void range_kernel2d(const kernel& ker,size_t offset_x, size_t offset_y,
                size_t global_x, size_t global_y, size_t local_x=0, size_t local_y=0);
        void range_kernel3d(const kernel& ker,size_t offset_x, size_t offset_y,
                size_t offset_z, size_t global_x, size_t global_y, size_t global_z,
                size_t local_x=0, size_t local_y=0, size_t local_z=0);
        void add_object(const mem& mo);
        void aquire_globject();
        void release_globject();
        void flush();
        void finish();
        void barrier();
        void wait_for_events();
        void marker();
};

