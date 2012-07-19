%module gl2
%{
#include <string>
#include <wrappers/gl2.hpp>
%}

typedef unsigned int uint;
typedef unsigned char byte;


void init();
void vertex_array(const array<float>& b, int n=0, int stride=0);
void normal_array(const array<float>& b, int stride=0);
void color_array(const array<float>& b, int n=0, int stride=0);
void draw_triangles(const array<uint>& b);
void active_texture(int i);
void tex_1D(const array<float>& b);
void vertex_attrib_array(uint i, const array<float>& b, bool norm=false, int n=0, int stride=0);
void vertex_attrib_array(uint i, const array<double>& b, bool norm=false, int n=0, int stride=0);
void enable_vertex_attrib_array(uint i);
void disable_vertex_attrib_array(uint i);
/* 
%typemap(in) vec3 {
  for(int i=0;i<3;++i) {
    lua_pushnumber(L,(double)(i+1));
    lua_gettable(L,$input);
    $1[i]=lua_tonumber(L,-1);
    lua_pop(L,1);
  }
}

%typemap(out) vec3 {
  lua_newtable(L);
  for(int i=0;i<3;++i) {
    lua_pushnumber(L,(double)(i+1));
    lua_pushnumber(L,$1[i]);
    lua_settable(L,-3);
  }
  SWIG_arg++;
}*/

  class trackball {
  public:
      trackball();
      void reset();
      void resize(double rad=1.0);
      void start_motion(int x, int y);
      void move_rotation(int x, int y);
      void move_pan(int x, int y);
      void move_zoom(int x, int y);
      void move_scaling(int x, int y);
      void transform();
      void rotate();
  };


  class unprojection {
  public:
    unprojection();
    void reset();
    void to_space(double * p_ptr, double * q_ptr) const;
    void to_plane(double * p_ptr, double * ps_ptr, double * w_ptr) const;
    void to_line(double * p_ptr, double * ps_ptr, double * t) const;
    bool to_tetra(double * p_ptr, double * ps_ptr, double * r_ptr, double * t, int o=1) const;
    void perspective_on();
    void perspective_off();
    bool perspective() const;
  };


/*
class gl_object
{
public:
	gl_object(void);
	virtual ~gl_object(void);
	GLuint object_id(void) const;
	bool valid_object(void) const;
	virtual void gen(void) = 0;
	virtual void del(void) = 0;
};

class bindable
{
public:
	bindable(void);
	void bind(void);
	void unbind(void);
	bool is_bound(void) const;
protected:
	virtual void do_bind(void) = 0;
	virtual void do_unbind(void) = 0;
};*/

class shader 
{
public:
	typedef enum
	{
		VERTEX,
		FRAGMENT,
		GEOMETRY
	} ShaderType;

	shader(void);
	void gen(void);
	void del(void);
	virtual ShaderType type(void) const = 0;
	void set_source(const char * src);
	bool load_source(const char * fileName);
	bool compile(void);
	bool is_compiled(void);
	//std::string info_log(void);
  void print_log(void);
};

class vertex_shader : public shader 
{
public:
	vertex_shader(void);
	ShaderType type(void) const;
};

class fragment_shader : public shader
{
public:
	fragment_shader(void);
	ShaderType type(void) const;
};

class geometry_shader : public shader
{
public:
	geometry_shader(void);
	ShaderType type(void) const;
};

class program 
{
public:
	program(void);
	void gen(void);
	void del(void);
	void attach(shader * shd);
	void detach(shader * shd);
	GLsizei attached_shaders(void) const;
	shader * attached_shader(int i);
	bool link(void);
	void bind(void);
	void unbind(void);
	bool is_linked(void) const;
	//std::string info_log(void);
  void print_log(void);
	void uniformi(const char * name, int x);
	void uniformi(const char * name, int x, int y);
	void uniformi(const char * name, int x, int y, int z);
  void uniformi(const char * name, int x, int y, int z, int w);
	void uniform(const char * name, float x);
	void uniform(const char * name, float x, float y);
	void uniform(const char * name, float x, float y, float z);
	void uniform(const char * name, float x, float y, float z, float w);
	void parameter(GLenum pname, int value);
	void attribute(int index, GLfloat x, GLfloat y, GLfloat z, GLfloat w);
	void bind_attribute(int index, const char * name);
};


