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

#ifndef __GL_OBJECT_H__
#define __GL_OBJECT_H__

class gl_object
{
    public:
        gl_object(void)
        {
            //	  printf("gl_object new\n");
            this->objectID = 0;
        }

        virtual ~gl_object(void)
        {
            //	  printf("gl_object delete\n");
        }

        GLuint object_id(void) const
        {
            return this->objectID;
        }

        bool valid_object(void) const
        {
            return (this->objectID != 0);
        }

        virtual void gen(void) = 0;
        virtual void del(void) = 0;

    protected:
        GLuint objectID;
};

class bindable
{
    public:
        bindable(void)
        {
            this->bound = false;
        }

        void bind(void)
        {
            this->bound = true;
            this->do_bind();
        }

        void unbind(void)
        {
            this->do_unbind();
            this->bound = false;
        }

        bool is_bound(void) const
        {
            return this->bound;
        }

    protected:
        bool bound;

        virtual void do_bind(void) = 0;
        virtual void do_unbind(void) = 0;
};

#endif //__GL_OBJECT_H__
