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

#ifndef __FBO_H__
#define __FBO_H__

#pragma warning(disable : 4250)

#include <map>
#include <vector>

#include <GL/glew.h>
#ifdef __APPLE__
#include <GLUT/glut.h>
#else
#include <GL/glut.h>
#endif

#include "gl_object.h"

class frame_buffer_semantic
{
    public:
        typedef enum
        {
            COLOR,
            DEPTH,
            STENCIL
        } FBSType;

        virtual FBSType semantic(void) const = 0;
        virtual bool validate_format(GLenum format) const = 0;

        static bool validate_format(FBSType type, GLenum format)
        {
            switch (type)
            {
                case COLOR   : return frame_buffer_semantic::validate_color(format);
                case DEPTH   : return frame_buffer_semantic::validate_depth(format);
                case STENCIL : return frame_buffer_semantic::validate_stencil(format);
                default      : return false;
            }
        }

        static bool validate_color(GLenum type)
        {
            return true;
        }

        static bool validate_depth(GLenum type)
        {
            return  true;
        }

        static bool validate_stencil(GLenum type)
        {
            return true;
        }
};

class buffer_object : public gl_object, public bindable
{
    GLenum target_;
    public:
        buffer_object(void) : gl_object(), bindable()
    {
        gen();
    }

        void gen(void)
        {
            this->del();
            glGenBuffers(1, &(this->objectID));
        }

        void del(void)
        {
            if (this->objectID == 0) return;
            glDeleteBuffers(1, &(this->objectID));
            this->objectID = 0;
        }

        GLenum target(void) const {
            return target_;
        }
        bool set(GLenum _target, GLsizeiptr _size,
                GLenum _usage,
                const GLvoid * _data=0) {
            target_=_target;
            this->bind();
            glBufferData(target_,_size,_data,_usage);
            this->unbind();
            return true;
        }
    protected:

        void do_bind(void)
        {
            glBindBuffer(this->target(), this->objectID);
        }

        void do_unbind(void)
        {
            glBindBuffer(this->target(), 0);
        }
};


class frame_buffer : public gl_object, public bindable
{
    public:
        frame_buffer(void) : gl_object(), bindable()
    {
        gen();
    }

        void gen(void)
        {
            this->del();
            glGenFramebuffers(1, &(this->objectID));
        }

        void del(void)
        {
            if (this->objectID == 0) return;
            glDeleteFramebuffers(1, &(this->objectID));
            this->objectID = 0;
        }

        bool attach_tex(GLenum attachmentPoint, GLenum textureTarget,
                GLuint textureId, GLint  level) {
            this->bind();
            glFramebufferTexture2D(GL_FRAMEBUFFER, attachmentPoint,
                    textureTarget, textureId, level);
            this->unbind();
            return true;
        }
        bool attach_rb(GLenum attachmentPoint, GLuint rbId) {
            this->bind();
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, attachmentPoint,
                    GL_RENDERBUFFER, rbId);
            this->unbind();
            return true;
        }
        bool check() {
            this->bind();
            GLenum result=glCheckFramebufferStatus(GL_FRAMEBUFFER);
            this->unbind();
         /*   switch(result) {
                case GL_FRAMEBUFFER_COMPLETE:
                    printf("framebuffer complete\n");
                    break;
                case GL_FRAMEBUFFER_UNDEFINED:
                    printf("framebuffer undefined\n");
                    break;
                case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
                    printf("framebuffer incomplete attachment\n");
                    break;
                case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
                    printf("framebuffer incomplete missing attachment\n");
                    break;
                case GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER:
                    printf("framebuffer incomplete draw buffer\n");
                    break;
                case GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER:
                    printf("framebuffer incomplete read buffer\n");
                    break;
                case GL_FRAMEBUFFER_UNSUPPORTED:
                    printf("framebuffer unsupported\n");
                    break;
                case GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE:
                    printf("framebuffer incomplete multisample\n");
                    break;
                case GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS:
                    printf("framebuffer incomplete layer targets\n");
                    break;
            }*/
            return result==GL_FRAMEBUFFER_COMPLETE;
        }
    protected:

        void do_bind(void)
        {
            glBindFramebuffer(GL_FRAMEBUFFER, this->objectID);
        }

        void do_unbind(void)
        {
            glBindFramebuffer(GL_FRAMEBUFFER, 0);
        }
};

class render_buffer : public gl_object, public bindable
{
    public:
        render_buffer(void) : gl_object(), bindable()
    {
        gen();
    }

        void gen(void)
        {
            this->del();
            glGenRenderbuffers(1, &(this->objectID));
        }

        void del(void)
        {
            if (this->objectID == 0) return;
            glDeleteRenderbuffers(1, &(this->objectID));
            this->objectID = 0;
        }

        bool set(GLenum _format, GLsizei _width, GLsizei _height) {
            this->bind();
            glRenderbufferStorage(GL_RENDERBUFFER,_format,_width,_height);
            this->unbind();
            return true;
        }
    protected:

        void do_bind(void)
        {
            glBindRenderbuffer(GL_RENDERBUFFER, this->objectID);
        }

        void do_unbind(void)
        {
            glBindRenderbuffer(GL_RENDERBUFFER, 0);
        }
};


class texture : public gl_object, public bindable, public frame_buffer_semantic
{
    public:
        texture(void) : gl_object(), bindable(), frame_buffer_semantic()
    {
        this->format_ = GL_NONE;
        gen();
    }

        void gen(void)
        {
            this->del();
            glGenTextures(1, &(this->objectID));
        }

        void del(void)
        {
            if (this->objectID == 0) return;
            glDeleteTextures(1, &(this->objectID));
            this->objectID = 0;
        }

        GLenum format(void) const
        {
            return this->format_;
        }

        virtual GLint dimensions(void) const = 0;

        virtual GLsizei size(const unsigned int i) const = 0;

        virtual GLenum target(void) const = 0;

    protected:
        GLenum format_;

        void do_bind(void)
        {
            glBindTexture(this->target(), this->objectID);
        }

        void do_unbind(void)
        {
            glBindTexture(this->target(), 0);
        }
};

class color_texture : public virtual texture
{
    public:
        color_texture(void) : texture()
    {
    }

        frame_buffer_semantic::FBSType semantic(void) const
        {
            return frame_buffer_semantic::COLOR;
        }

        bool validate_format(GLenum format) const
        {
            return frame_buffer_semantic::validate_color(format);
        }
};

class depth_texture : public virtual texture
{
    public:
        depth_texture(void) : texture()
    {
    }

        frame_buffer_semantic::FBSType semantic(void) const
        {
            return frame_buffer_semantic::DEPTH;
        }

        bool validate_format(GLenum format) const
        {
            return frame_buffer_semantic::validate_depth(format);
        }
};

class stencil_texture : public virtual texture
{
    public:
        stencil_texture(void) : texture()
    {
    }

        frame_buffer_semantic::FBSType semantic(void) const
        {
            return frame_buffer_semantic::STENCIL;
        }

        bool validate_format(GLenum format) const
        {
            return frame_buffer_semantic::validate_stencil(format);
        }
};

class texture1d : public virtual texture
{
    public:
        texture1d(void) : texture()
    {
        this->dims[0] = 0;
        this->wraps[0] = GL_CLAMP_TO_EDGE;
    }

        GLsizei width(void) const
        {
            return this->dims[0];
        }

        GLint dimensions(void) const
        {
            return 1;
        }

        GLsizei size(const unsigned int i) const
        {
            if (i > 0) return 0;
            return this->dims[0];
        }

        GLenum target(void) const
        {
            return GL_TEXTURE_1D;
        }

        bool set(GLint level, GLint internalFormat, GLsizei width, GLint border, GLenum format, GLenum type, const GLvoid * pixels)
        {
            if (!this->validate_format(internalFormat)) return false;

            this->bind();

            glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexImage1D(GL_TEXTURE_1D, level, internalFormat, width, border, format, type, pixels);

            this->unbind();

            this->format_ = internalFormat;
            this->dims[0] = width;

            return true;
        }

    protected:
        GLsizei dims[1];
        GLenum wraps[1];
};

class texture2d : public virtual texture
{
    public:
        texture2d(void) : texture()
    {
        this->dims[0] = 0;
        this->dims[1] = 0;
    }

        GLsizei width(void) const
        {
            return this->dims[0];
        }

        GLsizei height(void) const
        {
            return this->dims[1];
        }

        GLint dimensions(void) const
        {
            return 2;
        }

        GLsizei size(const unsigned int i) const
        {
            if (i > 1) return 0;
            return this->dims[i];
        }

        GLenum target(void) const
        {
            return GL_TEXTURE_2D;
        }

        bool set(GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid * pixels)
        {
            if (!this->validate_format(internalFormat)) return false;

            this->bind();

            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexImage2D(GL_TEXTURE_2D, level, internalFormat, width, height, border, format, type, pixels);

            this->unbind();

            this->format_ = internalFormat;
            this->dims[0] = width;
            this->dims[1] = height;

            return true;
        }

    protected:
        GLsizei dims[2];

        void do_bind(void)
        {
            glBindTexture(GL_TEXTURE_2D, this->objectID);
        }

        void do_unbind(void)
        {
            glBindTexture(GL_TEXTURE_2D, 0);
        }
};

class texture3d : public virtual texture
{
    public:
        texture3d(void) : texture()
    {
        this->dims[0] = 0;
        this->dims[1] = 0;
        this->dims[2] = 0;
    }

        GLsizei width(void) const
        {
            return this->dims[0];
        }

        GLsizei height(void) const
        {
            return this->dims[1];
        }

        GLsizei depth(void) const
        {
            return this->dims[2];
        }

        GLint dimensions(void) const
        {
            return 3;
        }

        GLsizei size(const unsigned int i) const
        {
            if (i > 2) return 0;
            return this->dims[i];
        }

        GLenum target(void) const
        {
            return GL_TEXTURE_3D;
        }

        bool set(GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLenum format, GLenum type, const GLvoid * pixels)
        {
            if (!this->validate_format(internalFormat)) return false;

            this->bind();

            glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
            glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);
            glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_BORDER);
            glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexImage3D(GL_TEXTURE_3D, level, internalFormat, width, height, depth, border, format, type, pixels);

            this->unbind();

            this->format_ = internalFormat;
            this->dims[0] = width;
            this->dims[1] = height;
            this->dims[2] = depth;

            return true;
        }

    protected:
        GLsizei dims[3];

        void do_bind(void)
        {
            glBindTexture(GL_TEXTURE_3D, this->objectID);
        }

        void do_unbind(void)
        {
            glBindTexture(GL_TEXTURE_3D, 0);
        }
};

class color_texture1d : public virtual color_texture, public virtual texture1d
{
    public:
        color_texture1d(void) : color_texture(), texture1d()
    {
    }
};

class color_texture2d : public virtual color_texture, public virtual texture2d
{
    public:
        color_texture2d(void) : color_texture(), texture2d()
    {
    }
};

class color_texture3d : public virtual color_texture, public virtual texture3d
{
    public:
        color_texture3d(void) : color_texture(), texture3d()
    {
    }
};

class depth_texture2d : public virtual depth_texture, public virtual texture2d
{
    public:
        depth_texture2d(void) : depth_texture(), texture2d()
    {
    }
};

class stencil_texture2d : public virtual stencil_texture, public virtual texture2d
{
    public:
        stencil_texture2d(void) : stencil_texture(), texture2d()
    {
    }
};
/*
   class FrameBuffer;

   class RenderTarget : public gl_object, public bindable, public frame_buffer_semantic
   {
   friend class FrameBuffer;

   public:
   typedef enum
   {
   BUFFER,
   TEXTURE
   } RTStorageType;

   RenderTarget(void) : gl_object(), bindable(), frame_buffer_semantic()
   {
   this->frameBuffer = 0;
   }

   bool Attach(FrameBuffer * fb);

   bool Detach(void);

   FrameBuffer * GetFrameBuffer(void)
   {
   return this->frameBuffer;
   }

   const FrameBuffer * GetFrameBuffer(void) const
   {
   return this->frameBuffer;
   }

   virtual GLsizei Width(void) const = 0;
   virtual GLsizei Height(void) const = 0;
   virtual GLenum Format(void) const = 0;

   virtual GLenum Attachment(void) const = 0;

   virtual bool ValidateAttachment(GLenum attachment) const = 0;

   virtual RTStorageType StorageType(void) const = 0;

   protected:
   FrameBuffer * frameBuffer;

   virtual bool BindToFB(void) = 0;
   };

   class BufferRenderTarget : public virtual RenderTarget
   {
   public:
   BufferRenderTarget(void) : RenderTarget()
   {
   this->width = 0;
   this->height = 0;
   this->format = GL_NONE;
   }

   void Gen(void)
   {
   this->Del();
   glGenRenderbuffersEXT(1, &(this->objectID));
   }

   void Del(void)
   {
   if (this->objectID == 0) return;
   glDeleteRenderbuffersEXT(1, &(this->objectID));
   this->objectID = 0;
   }

GLsizei Width(void) const
{
    return this->width;
}

GLsizei Height(void) const
{
    return this->height;
}

GLenum Format(void) const
{
    return this->format;
}

RTStorageType StorageType(void) const
{
    return RenderTarget::BUFFER;
}

bool Set(GLenum format, GLsizei width, GLsizei height)
{
    if (!this->validate_format(format)) return false;

    this->Bind();

    glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, format, width, height);

    this->Unbind();

    this->format = format;
    this->width = width;
    this->height = height;

    return true;
}

bool BindToFB(void)
{
    if (this->frameBuffer == 0) return false;
    glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, this->Attachment(), GL_RENDERBUFFER_EXT, this->objectID);

    return true;
}

protected:
GLenum format;
GLsizei width;
GLsizei height;

void do_bind(void)
{
    glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, this->objectID);
}

void do_unbind(void)
{
    glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, 0);
}
};

class TextureRenderTarget : public virtual RenderTarget
{
    public:
        TextureRenderTarget(void) : RenderTarget()
    {
        this->tex = 0;
        this->level = 0;
    }

        void Gen(void)
        {
        }

        void Del(void)
        {
        }

        GLsizei Width(void) const
        {
            if (this->tex == 0) return 0;
            return this->tex->Width();
        }

        GLsizei Height(void) const
        {
            if (this->tex == 0) return 0;
            return this->tex->Height();
        }

        GLenum Format(void) const
        {
            if (this->tex == 0) return GL_NONE;
            return this->tex->Format();
        }

        RTStorageType StorageType(void) const
        {
            return RenderTarget::TEXTURE;
        }

        void SetLevel(GLint level)
        {
            if (level < 0) level = 0;
            this->level = level;
        }

        bool Set(Texture2D * tex)
        {
            this->Unset();

            if (tex == 0) return true;
            if (this->semantic() != tex->semantic()) return false;

            this->tex = tex;

            return true;
        }

        bool Unset(void)
        {
            this->tex = 0;

            return true;
        }

        Texture2D * GetTexture(void)
        {
            return (this->tex);
        }

        bool BindToFB(void)
        {
            if (this->frameBuffer == 0) return false;
            if (this->tex == 0) return false;

            glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, this->Attachment(), GL_TEXTURE_2D, this->tex->ObjectID(), this->level);

            return true;
        }

    protected:

        Texture2D * tex;
        GLint level;

        void do_bind(void)
        {
        }

        void do_unbind(void)
        {
        }
};

class ColorRenderTarget : public virtual RenderTarget
{
    public:
        ColorRenderTarget(void) : RenderTarget()
    {
        this->attachment = GL_COLOR_ATTACHMENT0_EXT;
    }

        frame_buffer_semantic::FBSType semantic(void) const
        {
            return frame_buffer_semantic::COLOR;
        }

        bool validate_format(GLenum format) const
        {
            return frame_buffer_semantic::validate_color(format);
        }

        bool ValidateAttachment(GLenum attachment) const
        {
            return (((GL_COLOR_ATTACHMENT0_EXT) <= attachment) && (attachment <= (GL_COLOR_ATTACHMENT0_EXT + 3)));
        }

        void SetAttachment(GLenum attachment)
        {
            if (!this->ValidateAttachment(attachment)) return;
            this->attachment = attachment;
        }

        GLenum Attachment(void) const
        {
            return this->attachment;
        }

    protected:
        GLenum attachment;
};

class DepthRenderTarget : public virtual RenderTarget
{
    public:
        DepthRenderTarget(void) : RenderTarget()
    {
    }

        frame_buffer_semantic::FBSType semantic(void) const
        {
            return frame_buffer_semantic::DEPTH;
        }

        bool validate_format(GLenum format) const
        {
            return frame_buffer_semantic::validate_depth(format);
        }

        bool ValidateAttachment(GLenum attachment) const
        {
            return (attachment == GL_DEPTH_ATTACHMENT_EXT);
        }

        GLenum Attachment(void) const
        {
            return GL_DEPTH_ATTACHMENT_EXT;
        }
};

class StencilRenderTarget : public virtual RenderTarget
{
    public:
        StencilRenderTarget(void) : RenderTarget()
    {
    }

        frame_buffer_semantic::FBSType semantic(void) const
        {
            return frame_buffer_semantic::STENCIL;
        }

        bool validate_format(GLenum format) const
        {
            return frame_buffer_semantic::validate_stencil(format);
        }

        bool ValidateAttachment(GLenum attachment) const
        {
            return (attachment == GL_STENCIL_ATTACHMENT_EXT);
        }

        GLenum Attachment(void) const
        {
            return GL_STENCIL_ATTACHMENT_EXT;
        }
};

class ColorRenderBuffer : public virtual ColorRenderTarget, public virtual BufferRenderTarget
{
    public:
        ColorRenderBuffer(void) : ColorRenderTarget(), BufferRenderTarget()
    {
    }
};

class ColorRenderTexture : public virtual ColorRenderTarget, public virtual TextureRenderTarget
{
    public:
        ColorRenderTexture(void) : ColorRenderTarget(), TextureRenderTarget()
    {
    }

        ColorRenderTexture(Texture2D * tex) : ColorRenderTarget(), TextureRenderTarget()
    {
        this->Set(tex);
    }
};

class DepthRenderBuffer : public virtual DepthRenderTarget, public virtual BufferRenderTarget
{
    public:
        DepthRenderBuffer(void) : DepthRenderTarget(), BufferRenderTarget()
    {
    }
};

class DepthRenderTexture : public virtual DepthRenderTarget, public virtual TextureRenderTarget
{
    public:
        DepthRenderTexture(void) : DepthRenderTarget(), TextureRenderTarget()
    {
    }

        DepthRenderTexture(Texture2D * tex) : DepthRenderTarget(), TextureRenderTarget()
    {
        this->Set(tex);
    }
};

class StencilRenderBuffer : public virtual StencilRenderTarget, public virtual BufferRenderTarget
{
    public:
        StencilRenderBuffer(void) : StencilRenderTarget(), BufferRenderTarget()
    {
    }
};

class StencilRenderTexture : public virtual StencilRenderTarget, public virtual TextureRenderTarget
{
    public:
        StencilRenderTexture(void) : StencilRenderTarget(), TextureRenderTarget()
    {
    }

        StencilRenderTexture(Texture2D * tex) : StencilRenderTarget(), TextureRenderTarget()
    {
        this->Set(tex);
    }
};

class FrameBuffer : public gl_object, public bindable
{
    friend class RenderTarget;

    public:
    FrameBuffer(void) : gl_object(), bindable()
    {
    }

    void Gen(void)
    {
        this->Del();
        glGenFramebuffersEXT(1, &(this->objectID));
    }

    void Del(void)
    {
        if (this->objectID == 0) return;
        glDeleteFramebuffersEXT(1, &(this->objectID));
        this->objectID = 0;
    }

    bool DetachAll(void)
    {
        return false;
    }

    bool IsValid(void) const
    {
        const GLenum s = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
        //return (s == GL_FRAMEBUFFER_COMPLETE_EXT);

        switch (s)
        {
            case GL_FRAMEBUFFER_COMPLETE_EXT:
                printf("ok\n");
                break;
            case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_EXT:
                printf("i a\n");
                break;
            case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_EXT:
                printf("i m a\n");
                break;
            case GL_FRAMEBUFFER_INCOMPLETE_DUPLICATE_ATTACHMENT_EXT:
                printf("i d a\n");
                break;
            case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT:
                printf("i d\n");
                break;
            case GL_FRAMEBUFFER_INCOMPLETE_FORMATS_EXT:
                printf("i f\n");
                break;
            case GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER_EXT:
                printf("i d b\n");
                break;
            case GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER_EXT:
                printf("i r b\n");
                break;
            case GL_FRAMEBUFFER_UNSUPPORTED_EXT:
                printf("u\n");
                break;
            default:
                printf("def\n");
                break;
        }

        return (s == GL_FRAMEBUFFER_COMPLETE_EXT);
    }

    protected:
    typedef std::map<GLenum, RenderTarget *> RTMap;
    typedef RTMap::iterator RTMap_i;
    typedef RTMap::const_iterator RTMap_ci;

    RTMap renderTargets;

    void do_bind(void)
    {
        glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, this->objectID);

        std::vector<GLenum> colorDrawBuffers;
        colorDrawBuffers.reserve(this->renderTargets.size());

        for (RTMap_i rt=this->renderTargets.begin(); rt!=this->renderTargets.end(); ++rt)
        {
            RenderTarget * prt = (*rt).second;
            if (prt->semantic() == frame_buffer_semantic::COLOR)
            {
                colorDrawBuffers.push_back(prt->Attachment());
            }
            prt->BindToFB();
        }

        const GLsizei sz = (GLsizei)(colorDrawBuffers.size());
        if (sz > 0)
        {
            glDrawBuffers(sz, &(colorDrawBuffers[0]));
        }
    }

    void do_unbind(void)
    {
        glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
    }

    bool AddRT(RenderTarget * rt)
    {
        if (rt == 0) return false;
        RTMap_i it = this->renderTargets.find(rt->Attachment());
        if (it == this->renderTargets.end())
        {
            this->renderTargets.insert(std::make_pair(rt->Attachment(), rt));
            return true;
        }
        return false;
    }

    bool RemoveRT(RenderTarget * rt)
    {
        if (rt == 0) return false;
        RTMap_i it = this->renderTargets.find(rt->Attachment());
        if ((*it).second == rt)
        {
            this->renderTargets.erase(it);
            return true;
        }
        return false;
    }
};



bool RenderTarget::Attach(FrameBuffer * fb)
{
    this->Detach();
    if (fb == 0) return true;

    if (fb->AddRT(this))
    {
        this->frameBuffer = fb;
        return true;
    }

    return false;
}

bool RenderTarget::Detach(void)
{
    if (this->frameBuffer == 0) return false;
    this->frameBuffer->RemoveRT(this);
    this->frameBuffer = 0;

    return true;
}*/

#endif  // __FBO_H__
