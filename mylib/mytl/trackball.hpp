#ifndef MYTL_CG_TRACKBALL_HPP
#define MYTL_CG_TRACKBALL_HPP

/*! \file
 * \brief Simple Trackball
 */

#include <mytl/GL.hpp>
#include <iostream>
using std::cout;
using std::endl;

namespace mytl {

    /*! \addtogroup cg
     * @{
     */

    //! Simple Arcball
    /*!
     * \b Example:
     * \include arcball.cpp
     * \b Output:
     * \include arcball.out
     */
    class trackball {
        vec<3> last_point;
        vec<3> trans;
        double s;
        double radius;
        vec<3> now, down;
        quat<double> qnow, qdrag;
        point<3> center;
        double unity;
        vec<3> project_to_sphere(const vec<3>& a) {
            double r=dot(a,a);
            vec<3> b;
            b[0]=a[0];b[1]=a[1];b[2]=0;
            if(r>1)
                normalize(b);
            else
                b[2]=sqrt(1-r);
            return b;
        }
        public:
        trackball()  {
            //        printf("trackball new\n");
            reset();
        }
        ~trackball() {
            //        printf("trackball delete\n");
        }
        void reset() {
            last_point.assign(0);
            trans.assign(0);
            s=1.0;
            qnow.assign(0.0);
            qdrag.assign(0.0);
            qnow[0]=qdrag[0]=1.0;
        }
        void resize(double rad=1.0) {
            array<vec<4,double>,4> pr;
            array<vec<4,double>,4> mv;
            point<2,int> p;
            vec<2,int> s;
            glGetModelviewMatrix(mv);
            glGetProjectionMatrix(pr);
            glGetViewport(p,s);
            center=gluProject(_(0.0,0.0,0.0),mv,pr,p,s);
            vec<3> r= center-gluProject(_(rad,0.0,0.0),mv,pr,p,s);
            unity=sqrt(dot(r,r));
            radius=rad;
        }
        void start_motion(int x, int y) {
            down=_<double>((x-center[0])/unity,(center[1]-y)/unity,0);
        }
        void move_rotation(int x, int y) {
            vec<3> from, to;
            now=_<double>((x-center[0])/unity,(center[1]-y)/unity,0);
            from=project_to_sphere(down);
            to=project_to_sphere(now);
            qdrag=mytl::rotation(from,to);
            qnow=qdrag*qnow;
            down=now;
        }
        void move_pan(int x, int y) {
            now=_<double>((x-center[0])/unity,(center[1]-y)/unity,0);
            trans=action(1.0/qnow,action(qnow,trans)+radius*(now-down));
            down=now;
        }
        void move_zoom(int x, int y) {
            now=_<double>((x-center[0])/unity,(center[1]-y)/unity,0);
            vec<3> d=_(0.0,0.0,now[1]-down[1]);
            trans=action(1.0/qnow,action(qnow,trans)+radius*d);
            down=now;
        }
        void move_scaling(int x, int y) {
            now=_<double>((x-center[0])/unity,(center[1]-y)/unity,0);
            s*=pow(3.0,now[1]-down[1]);
            down=now;
        }
        void transform() {
            glRotate(qnow);
            glTranslate(trans);
            glScale(_(s,s,s));
        }
        void inverse_transform() {
            glScale(_(1.0/s,1.0/s,1.0/s));
            glTranslate(-trans);
            glRotate(1.0/qnow);
        }
        void rotate() {
            glRotate(qnow);
        }
        quat<double> rotation() {
            return qnow;
        }
    };

    /* @} */

}

#endif // MYTL_CG_TRACKBALL_HPP
