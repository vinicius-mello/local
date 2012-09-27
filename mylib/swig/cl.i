%module cl
%{
#include <wrappers/cl.hpp>
typedef unsigned bitfield;
%}

%include cl.inc

typedef unsigned bitfield;

class host_singleton {
	public:
	host_singleton();
	~host_singleton();
	int nplatforms() const;
	int ndevices(int i) const;
};

extern host_singleton host;

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
	~mem();
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
	void arg(int i, const sampler& s);
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
	event write_buffer(const mem& mo, bool block, size_t offset, size_t count, 
		void * ptr) ;
	event read_buffer(const mem& mo, bool block, size_t offset, size_t count, 
		void * ptr) ;
	event range_kernel1d(const kernel& ker,size_t offset, size_t global, size_t local) ;
	event range_kernel2d(const kernel& ker,size_t offset_x, size_t offset_y,
		size_t global_x, size_t global_y, size_t local_x, size_t local_y);
	event range_kernel3d(const kernel& ker,size_t offset_x, size_t offset_y,
		size_t offset_z, size_t global_x, size_t global_y, size_t global_z,
		size_t local_x, size_t local_y, size_t local_z);
	int flush();
	int finish();
	int barrier();
};

