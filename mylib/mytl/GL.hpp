#ifndef UTL_GL_H
#define UTL_GL_H

/*! \file
 * \brief OpenGL wrapers
 */

//#ifdef USE_GLEE
//#include <GL/GLee.h>
//#include <GL/glu.h>
//#else

//#ifdef _WIN32
//#include <windows.h>
//#endif
#ifdef __APPLE__
#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#else
#include <GL/gl.h>
#include <GL/glu.h>
#endif
//#ifdef __WIN32__
//#include <GL/glext.h>
//#endif

//#endif
#include <mytl/vec.hpp>
#include <mytl/point.hpp>
#include <mytl/quat.hpp>

namespace mytl {

    /*! \addtogroup cg
     * @{
     */

    /*! \name Predefined Colors
     * \#
     */
    //@
    const vec<4,float> Black     (_<float>(0.0,0.0,0.0,1.0));
    const vec<4,float> White     (_<float>(1.0,1.0,1.0,1.0));
    const vec<4,float> Red       (_<float>(1.0,0.0,0.0,1.0));
    const vec<4,float> Green     (_<float>(0.0,1.0,0.0,1.0));
    const vec<4,float> Blue      (_<float>(0.0,0.0,1.0,1.0));
    const vec<4,float> Cyan      (_<float>(0.0,1.0,1.0,1.0));
    const vec<4,float> Magenta   (_<float>(1.0,0.0,1.0,1.0));
    const vec<4,float> Yellow    (_<float>(1.0,1.0,0.0,1.0));
    const vec<4,float> AlphaFull (_<float>(0.0,0.0,0.0,1.0));
    const vec<4,float> AlphaNull (_<float>(0.0,0.0,0.0,0.0));
    //@}

    /*! \name glVertex wrapers
     * \#
     */
    //@{
    inline
        void glVertex(const point<3,float> &p) {
            glVertex3f(p[0], p[1], p[2]);
        }

    inline
        void glVertex(const point<3,double> &p) {
            glVertex3d(p[0], p[1], p[2]);
        }

    inline
        void glVertex(const point<2, float> &p) {
            glVertex2f(p[0], p[1]);
        }

    inline
        void glVertex(const point<2, double> &p) {
            glVertex2d(p[0], p[1]);
        }
    //@}

    /*! \name glNormal wrapers
     * \#
     */
    //@{
    inline
        void glNormal(const vec<3,float> &n) {
            glNormal3f(n[0], n[1], n[2]);
        }

    inline
        void glNormal(const point<3,float> &p0,
                const point<3,float> &p1,
                const point<3,float> &p2) {
            glNormal(cross(p2-p1, p0-p1));
        }

    inline
        void glNormal(const vec<3,double> &n) {
            glNormal3d(n[0], n[1], n[2]);
        }

    inline
        void glNormal(const point<3,double> &p0,
                const point<3,double> &p1,
                const point<3,double> &p2) {
            glNormal(cross(p2-p1, p0-p1));
        }
    //@}

    /*! \name glTranslate wrapers
     * \#
     */
    //@{
    inline
        void glTranslate(const vec<3,float> &v) {
            glTranslatef(v[0], v[1], v[2]);
        }

    inline
        void glTranslate(const vec<3,double> &v) {
            glTranslated(v[0], v[1], v[2]);
        }

    inline
        void glTranslate(const vec<2,float> &v) {
            glTranslatef(v[0], v[1], 0);
        }

    inline
        void glTranslate(const vec<2,double> &v) {
            glTranslated(v[0], v[1], 0);
        }
    //@}

    /*! \name glScale wrapers
     * \#
     */
    //@{
    inline
        void glScale(float v) {
            glScalef(v, v, v);
        }

    inline
        void glScale(double v) {
            glScaled(v, v, v);
        }

    inline
        void glScale(const vec<3,float> &v) {
            glScalef(v[0], v[1], v[2]);
        }

    inline
        void glScale(const vec<3,double> &v) {
            glScaled(v[0], v[1], v[2]);
        }
    //@}

    /*! \name glRotate wrapers
     * \#
     */
    //@{
    inline
        void glRotate(double ang, const vec<3,double> &v) {
            glRotated(ang, v[0], v[1], v[2]);
        }

    inline
        void glRotate(float ang, const vec<3,float> &v) {
            glRotatef(ang, v[0], v[1], v[2]);
        }

    inline
        void glRotate(const quat<double> &q) {
            glRotate(angle(q)*180/M_PI, axis(q));
        }

    inline
        void glRotate(const quat<float> &q) {
            glRotate(angle(q)*180/M_PI, axis(q));
        }
    //@}

    /*! \name glColor wrapers
     * \#
     */
    //@{
    inline
        void glColor(const vec<3,float> &c) {
            glColor3f(c[0], c[1], c[2]);
        }

    inline
        void glColor(const vec<3,double> &c) {
            glColor3d(c[0], c[1], c[2]);
        }

    inline
        void glColor(const vec<4,float> &c) {
            glColor4f(c[0], c[1], c[2], c[3]);
        }

    inline
        void glColor(const vec<4,double> &c) {
            glColor4d(c[0], c[1], c[2], c[3]);
        }

    inline
        void glClearColor(const vec<4,float> &c) {
            ::glClearColor(c[0], c[1], c[2], c[3]);
        }

    inline
        void glClearColor(const vec<4,double> &c) {
            ::glClearColor(c[0], c[1], c[2], c[3]);
        }
    //@}

    /*! \name gluLookAt wrapers
     * \#
     */
    //@{
    inline
        void gluLookAt(const point<3,float> &eye,
                const point<3,float> &center,
                const vec<3,float> &up) {
            ::gluLookAt(eye[0], eye[1], eye[2],
                    center[0], center[1], center[2],
                    up[0], up[1], up[2]);
        }

    inline
        void gluLookAt(const point<3,double> &eye,
                const point<3,double> &center,
                const vec<3,double> &up) {
            ::gluLookAt(eye[0], eye[1], eye[2],
                    center[0], center[1], center[2],
                    up[0], up[1], up[2]);
        }

    inline
        void glGetModelviewMatrix(array<vec<4,double>,4>& m) {
            glGetDoublev(GL_MODELVIEW_MATRIX,&m[0][0]);
        }

    inline
        void glGetProjectionMatrix(array<vec<4,double>,4>& m) {
            glGetDoublev(GL_PROJECTION_MATRIX,&m[0][0]);
        }

    inline
        void glGetViewport(point<2,int>& p, vec<2,int>& s) {
            int a[4];
            glGetIntegerv(GL_VIEWPORT,&a[0]);
            p[0]=a[0];p[1]=a[1];
            s[0]=a[2];s[1]=a[3];
        }

    inline
        void glMultMatrix(const array<vec<4,double>,4>& m) {
            glMultMatrixd(&m[0][0]);
        }

    inline
        point<3,double> gluProject(const point<3,double>& p,
                const array<vec<4,double>,4>& mv,
                const array<vec<4,double>,4>& pr,
                const point<2,int>& pos,
                const vec<2,int>& s) {
            int a[4];
            a[0]=p[0];a[1]=p[1];
            a[2]=s[0];a[3]=s[1];
            point<3,double> r;
            ::gluProject(p[0],p[1],p[2],&mv[0][0],&pr[0][0],&a[0],&r[0],&r[1],&r[2]);
            return r;
        }

    inline
        point<3,double> gluUnProject(const point<3,double>& p,
                const array<vec<4,double>,4>& mv,
                const array<vec<4,double>,4>& pr,
                const point<2,int>& pos,
                const vec<2,int>& s) {
            int a[4];
            a[0]=p[0];a[1]=p[1];
            a[2]=s[0];a[3]=s[1];
            point<3,double> r;
            if(::gluUnProject(p[0],p[1],p[2],&mv[0][0],&pr[0][0],&a[0],&r[0],&r[1],&r[2])==GL_FALSE)
                r.assign(0.0);
            return r;
        }


    //@}

    /* @} */

}

#endif























