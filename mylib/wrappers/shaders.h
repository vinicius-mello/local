/****************************************************************************
 * MeshLab                                                           o o     *
 * An extendible mesh processor                                    o     o   *
 *                                                                _   O  _   *
 * Copyright(C) 2005, 2009                                          \/)\/    *
 * Visual Computing Lab                                            /\/|      *
 * ISTI - Italian National Research Council                           |      *
 *                                                                    \      *
 * All rights reserved.                                                      *
 *                                                                           *
 * This program is free software; you can redistribute it and/or modify      *
 * it under the terms of the GNU General Public License as published by      *
 * the Free Software Foundation; either version 2 of the License, or         *
 * (at your option) any later version.                                       *
 *                                                                           *
 * This program is distributed in the hope that it will be useful,           *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of            *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             *
 * GNU General Public License (http://www.gnu.org/licenses/gpl.txt)          *
 * for more details.                                                         *
 *                                                                           *
 ****************************************************************************/

#ifndef __SHADERS_H__
#define __SHADERS_H__

#include <GL/glew.h>
#include <stdio.h>
#include <set>

#include "gl_object.h"
//#include "../../vcg/space/point2.h"
//#include "../../vcg/space/point3.h"
//#include "../../vcg/space/point4.h"

class shader : public gl_object, public bindable
{
    public:
        typedef enum
        {
            VERTEX,
            FRAGMENT,
            GEOMETRY
        } ShaderType;

        shader(void) : gl_object(), bindable()
    {
        this->flags = 0;
        this->flags |= SOURCE_DIRTY;
        this->compiled = false;
    }

        void gen(void)
        {
            this->del();
            GLenum t;
            switch (this->type())
            {
                case shader::VERTEX   : t = GL_VERTEX_SHADER;   break;
                case shader::FRAGMENT : t = GL_FRAGMENT_SHADER; break;
                case shader::GEOMETRY : t = GL_GEOMETRY_SHADER_EXT; break;
                default: return;
            };
            this->objectID = glCreateShader(t);
        }

        void del(void)
        {
            if (this->objectID == 0) return;
            glDeleteShader(this->objectID);
            this->objectID = 0;
        }

        virtual ShaderType type(void) const = 0;

        void set_source(const char * src)
        {
            if (this->objectID==0)
                gen();

            this->flags |= SOURCE_DIRTY;
            this->compiled = false;
            this->source = src;

            const char * pSrc = this->source.c_str();
            glShaderSource(this->objectID, 1, &pSrc, 0);
        }

        bool load_source(const char * fileName)
        {
            if (this->objectID==0)
                gen();

            this->flags |= SOURCE_DIRTY;
            this->compiled = false;
            FILE * f = fopen(fileName, "rb");
            if (f == 0)
            {
                this->source = "";
                return false;
            }
            fseek(f, 0, SEEK_END);
            const size_t sz = (size_t)ftell(f);
            rewind(f);
            char * buff = new char[sz + 1];
            fread(buff, sizeof(char), sz, f);
            fclose(f);
            buff[sz] = '\0';

            this->source = buff;
            delete [] buff;

            const char * pSrc = this->source.c_str();
            glShaderSource(this->objectID, 1, &pSrc, 0);

            return true;
        }

        bool compile(void)
        {
            glCompileShader(this->objectID);
            GLint cm = 0;
            glGetShaderiv(this->objectID, GL_COMPILE_STATUS, &cm);
            this->compiled = (cm != GL_FALSE);
            this->flags = 0;
            return this->compiled;
        }

        bool is_compiled(void)
        {
            return this->compiled;
        }

        std::string info_log(void)
        {
            GLint len = 0;
            glGetShaderiv(this->objectID, GL_INFO_LOG_LENGTH, &len);
            char * ch = new char[len + 1];
            glGetShaderInfoLog(this->objectID, len, &len, ch);
            std::string infoLog = ch;
            delete [] ch;
            return infoLog;
        }

        void print_log(void)
        {
            GLint len = 0;
            glGetShaderiv(this->objectID, GL_INFO_LOG_LENGTH, &len);
            char * ch = new char[len + 1];
            glGetShaderInfoLog(this->objectID, len, &len, ch);
            printf("%s\n",ch);
            delete [] ch;
        }

    protected:
        enum
        {
            SOURCE_DIRTY
        };

        std::string source;
        unsigned int flags;
        bool compiled;

        void do_bind(void)
        {
        }

        void do_unbind(void)
        {
        }
};

class vertex_shader : public shader
{
    public:
        vertex_shader(void) : shader()
    {
    }

        ShaderType type(void) const
        {
            return shader::VERTEX;
        }
};

class fragment_shader : public shader
{
    public:
        fragment_shader(void) : shader()
    {
    }

        ShaderType type(void) const
        {
            return shader::FRAGMENT;
        }
};

class geometry_shader : public shader
{
    public:
        geometry_shader(void) : shader()
    {
    }

        ShaderType type(void) const
        {
            return shader::GEOMETRY;
        }
};

class program : public gl_object, public bindable
{
    public:

        program(void)
        {
            this->linked = false;
        }

        void gen(void)
        {
            this->del();
            this->objectID = glCreateProgram();
        }

        void del(void)
        {
            if (this->objectID == 0) return;
            glDeleteProgram(this->objectID);
            this->objectID = 0;
        }

        void attach(shader * shd)
        {
            if (this->objectID==0)
                gen();
            this->shaders.insert(shd);
            this->linked = false;
            glAttachShader(this->objectID, shd->object_id());
        }

        void detach(shader * shd)
        {
            this->shaders.erase(shd);
            this->linked = false;
            glDetachShader(this->objectID, shd->object_id());
        }

        GLsizei attached_shaders(void) const
        {
            return ((GLsizei)(this->shaders.size()));
        }

        shader * attached_shader(int i)
        {
            shader * shd = 0;
            int cnt = 0;
            for (std::set<shader *>::iterator it=this->shaders.begin(); (cnt < i) && (it!=this->shaders.end()); ++it)
            {
                shd = (*it);
            }
            return shd;
        }

        bool link(void)
        {
            bool ok = true;
            for (std::set<shader *>::iterator it=this->shaders.begin(); it!=this->shaders.end(); ++it)
            {
                shader * shd = (*it);
                if (!shd->is_compiled())
                {
                    ok = shd->compile() && ok;
                }
            }

            if (!ok)
                return false;

            glLinkProgram(this->objectID);

            GLint cm = 0;
            glGetProgramiv(this->objectID, GL_LINK_STATUS, &cm);
            this->linked = (cm != GL_FALSE);

            return this->linked;
        }

        bool is_linked(void) const
        {
            return this->linked;
        }

        std::string info_log(void)
        {
            GLint len = 0;
            glGetProgramiv(this->objectID, GL_INFO_LOG_LENGTH, &len);
            char * ch = new char[len + 1];
            glGetProgramInfoLog(this->objectID, len, &len, ch);
            std::string infoLog = ch;
            delete [] ch;
            return infoLog;
        }

        void print_log(void)
        {
            GLint len = 0;
            glGetProgramiv(this->objectID, GL_INFO_LOG_LENGTH, &len);
            char * ch = new char[len + 1];
            glGetProgramInfoLog(this->objectID, len, &len, ch);
            printf("%s\n",ch);
            delete [] ch;
        }


        void uniformi(const char * name, GLint x)
        {
            const GLint loc = glGetUniformLocation(this->objectID, name);
            glUniform1i(loc, x);
        }

        void uniformi(const char * name, GLint x, GLint y)
        {
            const GLint loc = glGetUniformLocation(this->objectID, name);
            glUniform2i(loc, x, y);
        }

        void uniformi(const char * name, GLint x, GLint y, GLint z)
        {
            const GLint loc = glGetUniformLocation(this->objectID, name);
            glUniform3i(loc, x, y, z);
        }

        void uniformi(const char * name, GLint x, GLint y, GLint z, GLint w)
        {
            const GLint loc = glGetUniformLocation(this->objectID, name);
            glUniform4i(loc, x, y, z, w);
        }

        void uniform(const char * name, GLfloat x)
        {
            const GLint loc = glGetUniformLocation(this->objectID, name);
            glUniform1f(loc, x);
        }

        void uniform(const char * name, GLfloat x, GLfloat y)
        {
            const GLint loc = glGetUniformLocation(this->objectID, name);
            glUniform2f(loc, x, y);
        }

        void uniform(const char * name, GLfloat x, GLfloat y, GLfloat z)
        {
            const GLint loc = glGetUniformLocation(this->objectID, name);
            glUniform3f(loc, x, y, z);
        }

        void uniform(const char * name, GLfloat x, GLfloat y, GLfloat z, GLfloat w)
        {
            const GLint loc = glGetUniformLocation(this->objectID, name);
            glUniform4f(loc, x, y, z, w);
        }
        /*
           void Uniform(const char * name, const vcg::Point2f& p)
           {
           const GLint loc = glGetUniformLocation(this->objectID, name);
           glUniform2fv(loc, 1, p.V());
           }

           void Uniform(const char * name, const vcg::Point3f& p)
           {
           const GLint loc = glGetUniformLocation(this->objectID, name);
           glUniform3fv(loc, 1, p.V());
           }

           void Uniform(const char * name, const vcg::Point4f& p)
           {
           const GLint loc = glGetUniformLocation(this->objectID, name);
           glUniform4fv(loc, 1, p.V());
           }*/

        void parameter(GLenum pname, int value)
        {
            glProgramParameteriEXT(this->objectID, pname, value);
        }

        void attribute(int index, GLfloat x, GLfloat y, GLfloat z, GLfloat w)
        {
            glVertexAttrib4f(index, x, y, z, w);
        }

        void bind_attribute(int index, const char * name)
        {
            glBindAttribLocation(this->objectID, index, name);
        }

    protected:
        std::set<shader *> shaders;
        bool linked;

        void do_bind(void)
        {
            if (!this->is_linked())
            {
                this->link();
            }
            glUseProgram(this->objectID);
        }

        void do_unbind(void)
        {
            glUseProgram(0);
        }
};

#endif // __SHADERS_H__
