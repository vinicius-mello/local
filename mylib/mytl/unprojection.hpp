#ifndef MYTL_CG_UNPROJECTION_HPP
#define MYTL_CG_UNPROJECTION_HPP

#include <mytl/GL.hpp>

namespace mytl {

    class unprojection {
        protected:
            bool perspective_;
            array<vec<4,double>,4> mv_;
            array<vec<4,double>,4> pr_;
            point<2,int> pos_;
            vec<2,int> size_;
        public:
            unprojection() : perspective_(true) {}
            void reset() {
                glGetModelviewMatrix(mv_);
                glGetProjectionMatrix(pr_);
                glGetViewport(pos_,size_);
            }
            point<3,double> project(const point<3,double>& p) const {
                return gluProject(p,mv_,pr_,pos_,size_);
            }
            point<3,double> to_space(const point<3,double>& p) const {
                return gluUnProject(p,mv_,pr_,pos_,size_);
            }
            const array<vec<4,double>,4>& modelview() const {
                return mv_;
            }
            point<3,double> to_plane(const point<2,double>& p,
                    const array<point<3,double>,3>& ps) const {
                array<point<2,double>,3> qs;
                mytl::project(2,project(ps[0]),qs[0]);
                mytl::project(2,project(ps[1]),qs[1]);
                mytl::project(2,project(ps[2]),qs[2]);
                point<3,double> w=barycentric_coordinates(p,qs);
                if(perspective()) {
                    point<3,double> z;
                    z[0]=mv_[0][2]*ps[0][0]+mv_[1][2]*ps[0][1]+mv_[2][2]*ps[0][2]+mv_[3][2];
                    z[1]=mv_[0][2]*ps[1][0]+mv_[1][2]*ps[1][1]+mv_[2][2]*ps[1][2]+mv_[3][2];
                    z[2]=mv_[0][2]*ps[2][0]+mv_[1][2]*ps[2][1]+mv_[2][2]*ps[2][2]+mv_[3][2];
                    w=_(w[0]/z[0],w[1]/z[1],w[2]/z[2]);
                    w=barycentric_project(w);
                }
                return w;
            }
            double to_line(const point<2,double>& p,
                    const array<point<3,double>,2>& ps) const {
                array<point<2,double>,2> qs;
                mytl::project(2,project(ps[0]),qs[0]);
                mytl::project(2,project(ps[1]),qs[1]);
                vec<2,double> v=qs[1]-qs[0];
                double l=sqrt(dot(v,v));
                normalize(v);
                double t=dot(p-qs[0],v)/l;
                if(perspective()) {
                    point<2,double> z;
                    z[0]=mv_[0][2]*ps[0][0]+mv_[1][2]*ps[0][1]+mv_[2][2]*ps[0][2]+mv_[3][2];
                    z[1]=mv_[0][2]*ps[1][0]+mv_[1][2]*ps[1][1]+mv_[2][2]*ps[1][2]+mv_[3][2];
                    t=(t*z[0])/(t*z[0]+(1.0-t)*z[1]);
                }
                return t;
            }
            bool to_tetra(const point<2,double>& p,
                    const array<point<3,double>,4>& ps,
                    point<3,double>& r, double& t, int o=1) const {
                bool inter=false;
                o=(o>0)?1:0;
                array<point<3,double>,3> fs;
                array<point<2,double>,3> qs;
                for(dim_t j=0;j<4;++j) {
                    for(dim_t i=0; i<j; ++i) fs[i]=ps[i];
                    for(dim_t i=j+1; i<4; ++i) fs[i-1]=ps[i];
                    if(j%2==o) swap(fs[1],fs[2]);
                    mytl::project(2,project(fs[0]),qs[0]);
                    mytl::project(2,project(fs[1]),qs[1]);
                    mytl::project(2,project(fs[2]),qs[2]);
                    if(bracket(qs)<0) continue;
                    point<3,double> w=barycentric_coordinates(p,qs);
                    if((w[0]>=0.0)&&(w[1]>=0.0)&&(w[2]>=0.0)) {
                        inter=true;
                        if(perspective()) {
                            point<3,double> z;
                            z[0]=mv_[0][2]*ps[0][0]+mv_[1][2]*ps[0][1]+mv_[2][2]*ps[0][2]+mv_[3][2];
                            z[1]=mv_[0][2]*ps[1][0]+mv_[1][2]*ps[1][1]+mv_[2][2]*ps[1][2]+mv_[3][2];
                            z[2]=mv_[0][2]*ps[2][0]+mv_[1][2]*ps[2][1]+mv_[2][2]*ps[2][2]+mv_[3][2];
                            w=_(w[0]/z[0],w[1]/z[1],w[2]/z[2]);
                            w=barycentric_project(w);
                        }
                        r=barycentric_combination(w,fs);
                        point<3,double> a=project(r);
                        t=a[2];
                    }
                }
                return inter;
            }
            void to_space(double px, double py, double pz,
                    double& qx, double& qy, double& qz) const {
                point<3,double> p=_(px,py,pz);
                point<3,double> q=to_space(p);
                qx=q[0];qy=q[1];qz=q[2];
            }
            void to_plane(double px, double py,
                    double ax, double ay, double az,
                    double bx, double by, double bz,
                    double cx, double cy, double cz,
                    double& wa, double& wb, double& wc) const {
                array<point<3,double>,3> ps;
                ps[0]=_(ax,ay,az);
                ps[1]=_(bx,by,bz);
                ps[2]=_(cx,cy,cz);
                point<3,double> w=to_plane(_(px,py),ps);
                wa=w[0];wb=w[1];wc=w[2];
            }
            void to_line(double px, double py,
                    double ax, double ay, double az,
                    double bx, double by, double bz,
                    double& t) const {
                array<point<3,double>,2> ps;
                ps[0]=_(ax,ay,az);
                ps[1]=_(bx,by,bz);
                t=to_line(_(px,py),ps);
            }
            bool to_tetra(double px, double py,
                    double ax, double ay, double az,
                    double bx, double by, double bz,
                    double cx, double cy, double cz,
                    double dx, double dy, double dz,
                    double& rx, double& ry, double& rz, double& t) const {
                point<3,double> r;
                array<point<3,double>,4> ps;
                ps[0]=_(ax,ay,az);
                ps[1]=_(bx,by,bz);
                ps[2]=_(cx,cy,cz);
                ps[3]=_(dx,dy,dz);
                bool ret=to_tetra(_(px,py),ps,r,t);
                rx=r[0];ry=r[1];rz=r[2];
                return ret;
            }
            void to_space(const double * p_ptr, double * q_ptr) const {
                const point<3,double>& p=reinterpret_cast<const point<3,double>&>(p_ptr);
                point<3,double>& q=reinterpret_cast<point<3,double>&>(q_ptr);
                q=to_space(p);
            }
            void to_plane(const double * p_ptr, const double * ps_ptr, double * w_ptr) const {
                const point<2,double>& p=reinterpret_cast<const point<2,double>&>(p_ptr);
                const array<point<3,double>,3>& ps=reinterpret_cast<const array<point<3,double>,3>&>(ps_ptr);
                point<3,double>& w=reinterpret_cast<point<3,double>&>(w_ptr);
                w=to_plane(p,ps);
            }
            void to_line(const double * p_ptr, const double * ps_ptr, double * t) const {
                const point<2,double>& p=reinterpret_cast<const point<2,double>&>(p_ptr);
                const array<point<3,double>,2>& ps=reinterpret_cast<const array<point<3,double>,2>&>(ps_ptr);
                *t=to_line(p,ps);
            }
            bool to_tetra(const double * p_ptr, const double * ps_ptr, double * r_ptr,
                    double * t, int o=1) const {
                const point<2,double>& p=reinterpret_cast<const point<2,double>&>(*p_ptr);
                const array<point<3,double>,4>& ps=reinterpret_cast<const array<point<3,double>,4>&>(*ps_ptr);
                point<3,double>& r=reinterpret_cast<point<3,double>&>(*r_ptr);
                return to_tetra(p,ps,r,*t,o);
            }
            void perspective_on() {
                perspective_=true;
            }
            void perspective_off() {
                perspective_=false;
            }
            bool perspective() const {
                return perspective_;
            }
    };

}

#endif // MYTL_CG_UNPROJECTION_HPP
