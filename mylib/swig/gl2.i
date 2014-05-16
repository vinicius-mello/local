%module gl2
%{
#include <string>
#include <wrappers/gl2.hpp>
%}

#define BUFFER_SIZE 0x8764
#define BUFFER_USAGE 0x8765
#define QUERY_COUNTER_BITS 0x8864
#define CURRENT_QUERY 0x8865
#define QUERY_RESULT 0x8866
#define QUERY_RESULT_AVAILABLE 0x8867
#define ARRAY_BUFFER 0x8892
#define ELEMENT_ARRAY_BUFFER 0x8893
#define ARRAY_BUFFER_BINDING 0x8894
#define ELEMENT_ARRAY_BUFFER_BINDING 0x8895
#define VERTEX_ARRAY_BUFFER_BINDING 0x8896
#define NORMAL_ARRAY_BUFFER_BINDING 0x8897
#define COLOR_ARRAY_BUFFER_BINDING 0x8898
#define INDEX_ARRAY_BUFFER_BINDING 0x8899
#define TEXTURE_COORD_ARRAY_BUFFER_BINDING 0x889A
#define EDGE_FLAG_ARRAY_BUFFER_BINDING 0x889B
#define SECONDARY_COLOR_ARRAY_BUFFER_BINDING 0x889C
#define FOG_COORDINATE_ARRAY_BUFFER_BINDING 0x889D
#define WEIGHT_ARRAY_BUFFER_BINDING 0x889E
#define VERTEX_ATTRIB_ARRAY_BUFFER_BINDING 0x889F
#define READ_ONLY 0x88B8
#define WRITE_ONLY 0x88B9
#define READ_WRITE 0x88BA
#define BUFFER_ACCESS 0x88BB
#define BUFFER_MAPPED 0x88BC
#define BUFFER_MAP_POINTER 0x88BD
#define STREAM_DRAW 0x88E0
#define STREAM_READ 0x88E1
#define STREAM_COPY 0x88E2
#define STATIC_DRAW 0x88E4
#define STATIC_READ 0x88E5
#define STATIC_COPY 0x88E6
#define DYNAMIC_DRAW 0x88E8
#define DYNAMIC_READ 0x88E9
#define DYNAMIC_COPY 0x88EA
#define SAMPLES_PASSED 0x8914

#define INVALID_FRAMEBUFFER_OPERATION 0x0506
#define FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING 0x8210
#define FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE 0x8211
#define FRAMEBUFFER_ATTACHMENT_RED_SIZE 0x8212
#define FRAMEBUFFER_ATTACHMENT_GREEN_SIZE 0x8213
#define FRAMEBUFFER_ATTACHMENT_BLUE_SIZE 0x8214
#define FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE 0x8215
#define FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE 0x8216
#define FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE 0x8217
#define FRAMEBUFFER_DEFAULT 0x8218
#define FRAMEBUFFER_UNDEFINED 0x8219
#define DEPTH_STENCIL_ATTACHMENT 0x821A
#define INDEX 0x8222
#define MAX_RENDERBUFFER_SIZE 0x84E8
#define DEPTH_STENCIL 0x84F9
#define UNSIGNED_INT_24_8 0x84FA
#define DEPTH24_STENCIL8 0x88F0
#define TEXTURE_STENCIL_SIZE 0x88F1
#define UNSIGNED_NORMALIZED 0x8C17
#define SRGB 0x8C40
#define DRAW_FRAMEBUFFER_BINDING 0x8CA6
#define FRAMEBUFFER_BINDING 0x8CA6
#define RENDERBUFFER_BINDING 0x8CA7
#define READ_FRAMEBUFFER 0x8CA8
#define DRAW_FRAMEBUFFER 0x8CA9
#define READ_FRAMEBUFFER_BINDING 0x8CAA
#define RENDERBUFFER_SAMPLES 0x8CAB
#define FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE 0x8CD0
#define FRAMEBUFFER_ATTACHMENT_OBJECT_NAME 0x8CD1
#define FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL 0x8CD2
#define FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE 0x8CD3
#define FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER 0x8CD4
#define FRAMEBUFFER_COMPLETE 0x8CD5
#define FRAMEBUFFER_INCOMPLETE_ATTACHMENT 0x8CD6
#define FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT 0x8CD7
#define FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER 0x8CDB
#define FRAMEBUFFER_INCOMPLETE_READ_BUFFER 0x8CDC
#define FRAMEBUFFER_UNSUPPORTED 0x8CDD
#define MAX_COLOR_ATTACHMENTS 0x8CDF
#define COLOR_ATTACHMENT0 0x8CE0
#define COLOR_ATTACHMENT1 0x8CE1
#define COLOR_ATTACHMENT2 0x8CE2
#define COLOR_ATTACHMENT3 0x8CE3
#define COLOR_ATTACHMENT4 0x8CE4
#define COLOR_ATTACHMENT5 0x8CE5
#define COLOR_ATTACHMENT6 0x8CE6
#define COLOR_ATTACHMENT7 0x8CE7
#define COLOR_ATTACHMENT8 0x8CE8
#define COLOR_ATTACHMENT9 0x8CE9
#define COLOR_ATTACHMENT10 0x8CEA
#define COLOR_ATTACHMENT11 0x8CEB
#define COLOR_ATTACHMENT12 0x8CEC
#define COLOR_ATTACHMENT13 0x8CED
#define COLOR_ATTACHMENT14 0x8CEE
#define COLOR_ATTACHMENT15 0x8CEF
#define DEPTH_ATTACHMENT 0x8D00
#define STENCIL_ATTACHMENT 0x8D20
#define FRAMEBUFFER 0x8D40
#define RENDERBUFFER 0x8D41
#define RENDERBUFFER_WIDTH 0x8D42
#define RENDERBUFFER_HEIGHT 0x8D43
#define RENDERBUFFER_INTERNAL_FORMAT 0x8D44
#define STENCIL_INDEX1 0x8D46
#define STENCIL_INDEX4 0x8D47
#define STENCIL_INDEX8 0x8D48
#define STENCIL_INDEX16 0x8D49
#define RENDERBUFFER_RED_SIZE 0x8D50
#define RENDERBUFFER_GREEN_SIZE 0x8D51
#define RENDERBUFFER_BLUE_SIZE 0x8D52
#define RENDERBUFFER_ALPHA_SIZE 0x8D53
#define RENDERBUFFER_DEPTH_SIZE 0x8D54
#define RENDERBUFFER_STENCIL_SIZE 0x8D55
#define FRAMEBUFFER_INCOMPLETE_MULTISAMPLE 0x8D56
#define MAX_SAMPLES 0x8D57

#define RG                             0x8227
#define RG_INTEGER                     0x8228
#define R8                             0x8229
#define R16                            0x822A
#define RG8                            0x822B
#define RG16                           0x822C
#define R16F                           0x822D
#define R32F                           0x822E
#define RG16F                          0x822F
#define RG32F                          0x8230
#define R8I                            0x8231
#define R8UI                           0x8232
#define R16I                           0x8233
#define R16UI                          0x8234
#define R32I                           0x8235
#define R32UI                          0x8236
#define RG8I                           0x8237
#define RG8UI                          0x8238
#define RG16I                          0x8239
#define RG16UI                         0x823A
#define RG32I                          0x823B
#define RG32UI                         0x823C
#define DEPTH_COMPONENT32F             0x8CAC
#define DEPTH_COMPONENT16              0x81A5
#define DEPTH_COMPONENT24              0x81A6
#define DEPTH_COMPONENT32              0x81A7

typedef unsigned int uint;
typedef unsigned char byte;


void init();
void vertex_array(const array<float>& b, int n=0, int stride=0);
void texcoord_array(const array<float>& b, int n=0, int stride=0);
void normal_array(const array<float>& b, int stride=0);
void color_array(const array<float>& b, int n=0, int stride=0);
void vertex_array(const array<double>& b, int n=0, int stride=0);
void texcoord_array(const array<double>& b, int n=0, int stride=0);
void normal_array(const array<double>& b, int stride=0);
void color_array(const array<double>& b, int n=0, int stride=0);
void vertex_buffer(int n, unsigned type, size_t stride=0, size_t offset=0);
void vertex_attrib_buffer(int i, int n, unsigned type, size_t stride=0, size_t offset=0);
void texcoord_buffer(int n, unsigned type, size_t stride=0, size_t offset=0);
void draw_triangles(const array<uint>& b);
void draw_quads(const array<uint>& b);
void generate_mipmap(unsigned target);
void active_texture(int i);
void tex_1D(const array<float>& b);
void vertex_attrib_array(uint i, const array<float>& b, bool norm=false, int n=0, int stride=0);
void vertex_attrib_array(uint i, const array<double>& b, bool norm=false, int n=0, int stride=0);
void enable_vertex_attrib_array(uint i);
void disable_vertex_attrib_array(uint i);
void GetModelviewMatrix(double * m);
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
        void inverse_transform();
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

class color_texture1d 
{
    public:
        color_texture1d(void);
        unsigned object_id(void) const;
        size_t width(void) const;
        int dimensions(void) const;
        size_t size(const unsigned i) const;
        unsigned target(void) const;
        void bind(void);
        void unbind(void);
        bool set(int level, int internalFormat, size_t width, int border, unsigned format, unsigned type, const void * pixels);
};

class color_texture2d 
{
    public:
        color_texture2d(void);
        unsigned object_id(void) const;
        size_t width(void) const;
        size_t height(void) const;
        int dimensions(void) const;
        size_t size(const unsigned i) const;
        unsigned target(void) const;
        void bind(void);
        void unbind(void);
        bool set(int level, int internalFormat, size_t width, size_t height, int border, unsigned format, unsigned type, const void * pixels);
};

class color_texture3d 
{
    public:
        color_texture3d(void);
        unsigned object_id(void) const;
        size_t width(void) const;
        size_t height(void) const;
        size_t depth(void) const;
        int dimensions(void) const;
        size_t size(const unsigned i) const;
        unsigned target(void) const;
        void bind(void);
        void unbind(void);
        bool set(int level, int internalFormat, size_t width, size_t height, size_t depth, int border, unsigned format, unsigned type, const void * pixels);
};

class buffer_object
{
    public:
        buffer_object(void);
        unsigned object_id(void) const;
        unsigned target(void) const;
        void bind(void);
        void unbind(void);
        bool set(unsigned target, size_t size,
        unsigned usage, const void *data=0);
};

class frame_buffer
{
    public:
        frame_buffer(void);
        unsigned object_id(void) const;
        void bind(void);
        void unbind(void);
        bool attach_tex(unsigned attachmentPoint, unsigned textureTarget,
                unsigned textureId, int  level) ;
        bool attach_rb(unsigned attachmentPoint, unsigned rbId);
        bool check();
};

class render_buffer
{
    public:
        render_buffer(void);
        unsigned object_id(void) const;
        void bind(void);
        void unbind(void);
        bool set(unsigned _format, size_t _width, size_t _height) ;
};
