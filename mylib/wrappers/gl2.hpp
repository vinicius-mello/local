#ifndef WRAP_GL2_HPP
#define WRAP_GL2_HPP
#include <GL/glew.h>
#include "shaders.h"
#include "fbo.h"
#include "array.hpp"
#include <mytl/unprojection.hpp>
#include <mytl/trackball.hpp>

using mytl::unprojection;
using mytl::trackball;

inline void init() {
    GLenum err = glewInit();
    if (GLEW_OK != err)
    {
        /* Problem: glewInit failed, something is seriously wrong. */
        fprintf(stderr, "Error: %s\n", glewGetErrorString(err));
    }
    fprintf(stdout, "Status: Using GLEW %s\n", glewGetString(GLEW_VERSION));
}


inline void vertex_array(const array<float>& b, int n=0, int stride=0) {
    if(n==0) n=b.width();
    glVertexPointer(n,GL_FLOAT,stride,b.data());
}

inline void normal_array(const array<float>& b, int stride=0) {
    glNormalPointer(GL_FLOAT,stride,b.data());
}

inline void texcoord_array(const array<float>& b, int n=0, int stride=0) {
    if(n==0) n=b.width();
    glTexCoordPointer(n,GL_FLOAT,stride,b.data());
}

inline void color_array(const array<float>& b, int n=0, int stride=0) {
    if(n==0) n=b.width();
    glColorPointer(n,GL_FLOAT,stride,b.data());
}

inline void vertex_array(const array<double>& b, int n=0, int stride=0) {
    if(n==0) n=b.width();
    glVertexPointer(n,GL_DOUBLE,stride,b.data());
}

inline void normal_array(const array<double>& b, int stride=0) {
    glNormalPointer(GL_DOUBLE,stride,b.data());
}

inline void texcoord_array(const array<double>& b, int n=0, int stride=0) {
    if(n==0) n=b.width();
    glTexCoordPointer(n,GL_DOUBLE,stride,b.data());
}

inline void color_array(const array<double>& b, int n=0, int stride=0) {
    if(n==0) n=b.width();
    glColorPointer(n,GL_DOUBLE,stride,b.data());
}

inline void vertex_buffer(int n, unsigned type, size_t stride=0, size_t offset=0) {
    glVertexPointer(n,type,stride,(void *)offset);
}

inline void vertex_attrib_buffer(int i, int n, unsigned type, size_t stride=0, size_t offset=0) {
    if(type==GL_DOUBLE)
        glVertexAttribLPointer(i,n,type,stride,(void *)offset);
    else
        glVertexAttribPointer(i,n,type,GL_TRUE,stride,(void *)offset);
}

inline void texcoord_buffer(int n, unsigned type, size_t stride=0, size_t offset=0) {
    glTexCoordPointer(n,type,stride,(void *)offset);
}

inline void generate_mipmap(unsigned target) {
    glGenerateMipmap(target);
}

inline void active_texture(int i) {
    glActiveTexture(GL_TEXTURE0+i);
}

inline void tex_1D(const array<float>& b) {
    if(b.width()==3) glTexImage1D(GL_TEXTURE_1D,0,3,b.size()/b.width(),0,GL_RGB,GL_FLOAT,b.data());
    if(b.width()==1) glTexImage1D(GL_TEXTURE_1D,0,1,b.size()/b.width(),0,GL_ALPHA,GL_FLOAT,b.data());
    glTexParameterf( GL_TEXTURE_1D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameterf( GL_TEXTURE_1D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameterf( GL_TEXTURE_1D, GL_TEXTURE_WRAP_S, GL_CLAMP );
}

inline void vertex_attrib_array(uint i, const array<float>& b, bool norm=false, int n=0, int stride=0) {
    if(n==0) n=b.width();
    glVertexAttribPointer(i,n,GL_FLOAT,norm,stride,b.data());
}

inline void vertex_attrib_array(uint i, const array<double>& b, bool norm=false, int n=0, int stride=0) {
    if(n==0) n=b.width();
    glVertexAttribPointer(i,n,GL_DOUBLE,norm,stride,b.data());
}

inline void enable_vertex_attrib_array(uint i) {
    glEnableVertexAttribArray(i);
}

inline void disable_vertex_attrib_array(uint i) {
    glDisableVertexAttribArray(i);
}

inline void draw_triangles(const array<uint>& b) {
    glDrawElements(GL_TRIANGLES,b.size(),GL_UNSIGNED_INT,b.data());
}

inline void draw_quads(const array<uint>& b) {
    glDrawElements(GL_QUADS,b.size(),GL_UNSIGNED_INT,b.data());
}

    inline
        void GetModelviewMatrix(double * m) {
            glGetDoublev(GL_MODELVIEW_MATRIX,m);
        }




#endif // WRAP_GL2_HPP
