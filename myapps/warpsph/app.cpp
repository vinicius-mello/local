#include "app.hpp"
#include <mytl/linalg.hpp>
#include <mytl/quat.hpp>
#include <GL/glut.h>

vec<2> nsphcoord(const vec<3>& v) {
	double x=v[0];
	double y=v[1];
	double z=v[2];
	double phi=(M_PI+atan2(y,x))/(2.0*M_PI);
	double th=atan2(x*x+y*y,z)/M_PI;
	return vec<2>(_(1.0-phi,th));
}

void subdivide4(Vertices& vtx, Triangles& trs, TexCoords& tex) {
	EdgeVertexMap edges;
	int counter=vtx.size();
	for(Triangles::iterator i=trs.begin();i!=trs.end();++i) {
		array<int,3>& t=*i;
		if(edges.count(_(t[0],t[1]))==0) {
			edges[_(t[0],t[1])]=counter;
			++counter;
			vec<3> m=0.5*(vtx[t[0]]+vtx[t[1]]);
			normalize(m);
			vtx.push_back(m);
			tex.push_back(nsphcoord(m));
		}
		if(edges.count(_(t[0],t[2]))==0) {
			edges[_(t[0],t[2])]=counter;
			++counter;
			vec<3> m=0.5*(vtx[t[0]]+vtx[t[2]]);
			normalize(m);
			vtx.push_back(m);
			tex.push_back(nsphcoord(m));
		}
		if(edges.count(_(t[1],t[2]))==0) {
			edges[_(t[1],t[2])]=counter;
			++counter;
			vec<3> m=0.5*(vtx[t[1]]+vtx[t[2]]);
			normalize(m);
			vtx.push_back(m);
			tex.push_back(nsphcoord(m));
		}
	}
	Triangles new_triangles;
	for(Triangles::iterator i=trs.begin();i!=trs.end();++i) {
		array<int,3>& t=*i;
		int m[3];
		m[0]=edges[_(t[1],t[2])];
		m[1]=edges[_(t[0],t[2])];
		m[2]=edges[_(t[0],t[1])];
		new_triangles.push_back(_(t[0],m[2],m[1]));	
		new_triangles.push_back(_(t[1],m[0],m[2]));	
		new_triangles.push_back(_(t[2],m[1],m[0]));	
		t[0]=m[0];
		t[1]=m[1];
		t[2]=m[2];
	}
	for(Triangles::iterator i=new_triangles.begin();i!=new_triangles.end();++i) {
		array<int,3>& t=*i;
		trs.push_back(t);
	}
}

void make_icosahedron(Vertices& vtx, Triangles& trs, TexCoords& tex) {
	double phi=(1.0+sqrt(5.0))/2.0;
	vtx.push_back(_(0.0,1.0,phi));
	vtx.push_back(_(0.0,-1.0,phi));
	vtx.push_back(_(0.0,-1.0,-phi));
	vtx.push_back(_(0.0,1.0,-phi));
	vtx.push_back(_(1.0,phi,0.0));
	vtx.push_back(_(1.0,-phi,0.0));
	vtx.push_back(_(-1.0,-phi,0.0));
	vtx.push_back(_(-1.0,phi,0.0));
	vtx.push_back(_(phi,0.0,1.0));
	vtx.push_back(_(-phi,0.0,1.0));
	vtx.push_back(_(-phi,0.0,-1.0));
	vtx.push_back(_(phi,0.0,-1.0));
	for(Vertices::iterator i=vtx.begin();i!=vtx.end();++i) {
		normalize(*i);
	}
	trs.push_back(_(0,1,8));
	trs.push_back(_(0,9,1));
	trs.push_back(_(3,2,10));
	trs.push_back(_(3,11,2));
	trs.push_back(_(0,4,7));
	trs.push_back(_(4,3,7));
	trs.push_back(_(1,6,5));
	trs.push_back(_(2,5,6));
	trs.push_back(_(7,10,9));
	trs.push_back(_(6,9,10));
	trs.push_back(_(11,4,8));
	trs.push_back(_(5,11,8));
	trs.push_back(_(0,7,9));
	trs.push_back(_(0,8,4));
	trs.push_back(_(1,5,8));
	trs.push_back(_(1,9,6));
	trs.push_back(_(2,6,10));
	trs.push_back(_(2,11,5));
	trs.push_back(_(3,10,7));
	trs.push_back(_(3,4,11));
	for(Vertices::iterator i=vtx.begin();i!=vtx.end();++i) {
		tex.push_back(nsphcoord(*i));
	}
}


App::App() : vtx(), trs(), tex() {
	make_icosahedron(vtx,trs,tex);
	subdivide4(vtx,trs,tex);
	subdivide4(vtx,trs,tex);
	subdivide4(vtx,trs,tex);
	for(int i=0;i<vtx.size();++i) wtx.push_back(vtx[i]);
}

vec<3> get_pos(int x, int y)
{
	GLint viewport[4];
	GLdouble modelview[16];
	GLdouble projection[16];
	GLfloat winX, winY, winZ;
	GLdouble posX, posY, posZ;

	glGetDoublev( GL_MODELVIEW_MATRIX, modelview );
	glGetDoublev( GL_PROJECTION_MATRIX, projection );
	glGetIntegerv( GL_VIEWPORT, viewport );

	winX = (float)x;
	winY = (float)viewport[3] - (float)y;
	glReadPixels( x, int(winY), 1, 1, GL_DEPTH_COMPONENT, GL_FLOAT, &winZ );

	gluUnProject( winX, winY, winZ, modelview, projection, viewport, &posX, &posY, &posZ);

	return vec<3>(_(posX, posY, posZ));
}

void App::add_landmark(int x, int y) {
	vec<3> u=get_pos(x,y);
	normalize(u);
	src.push_back(u);
	dst.push_back(u);
}

void App::delete_landmark() {
	Landmarks::iterator i,j;
	for(i=dst.begin(),j=src.begin();i!=dst.end();++i,++j) {
		if((i==selected)||(j==selected)) break;
	}
	dst.erase(i);
	src.erase(j);
}


bool App::select_landmark(int x, int y) {
	vec<3> u=get_pos(x,y);
	normalize(u);
	for(Landmarks::iterator i=dst.begin();i!=dst.end();++i) {
		vec<3>& c=*i;
		double d=dot(u-c,u-c);
		if(d<0.002) {
			selected=i;
			return true;
		}
	}
	for(Landmarks::iterator i=src.begin();i!=src.end();++i) {
		vec<3>& c=*i;
		double d=dot(u-c,u-c);
		if(d<0.0005) {
			selected=i;
			return true;
		}
	}
	selected=src.end();
	return false;
}

void App::drag_landmark(int x, int y) {
	vec<3> u=get_pos(x,y);
	normalize(u);
	*selected=u;
}

void App::release_landmark(int x, int y) {
	vec<3> u=get_pos(x,y);
	normalize(u);
	*selected=u;
	selected=src.end();
}

void App::draw_source_landmarks() {
	for(Landmarks::iterator i=src.begin();i!=src.end();++i) {
		vec<3>& c=*i;
		glPushMatrix();
		glTranslatef(c[0],c[1],c[2]);
		glutSolidSphere(0.03,8,8);
		glPopMatrix();
	}
}

void App::draw_destination_landmarks() {
	for(Landmarks::iterator i=dst.begin();i!=dst.end();++i) {
		vec<3>& c=*i;
		glPushMatrix();
		glTranslatef(c[0],c[1],c[2]);
		glutSolidSphere(0.03,8,8);
		glPopMatrix();
	}
}

void App::draw_arcs() {
	Landmarks::iterator i,j;
	for(i=dst.begin(),j=src.begin();i!=dst.end();++i,++j) {
		vec<3>& u=*i;
		vec<3>& v=*j;
		glBegin(GL_LINE_STRIP);
		for(double t=0.0;t<=1.0;t+=0.05) {
			vec<3> m=(1.0-t)*u+t*v;
			normalize(m);
			glVertex(m);
		}
		glEnd();
	}
}

void App::draw_sphere() {
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glVertexPointer(3,GL_DOUBLE,0,&vtx[0]);
	glNormalPointer(GL_DOUBLE,0,&vtx[0]);
	glTexCoordPointer(2,GL_DOUBLE,0,&tex[0]);
	glDrawElements(GL_TRIANGLES,3*trs.size(),GL_UNSIGNED_INT,&trs[0]);
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
}

void App::draw_warped_sphere() {
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glVertexPointer(3,GL_DOUBLE,0,&wtx[0]);
	glNormalPointer(GL_DOUBLE,0,&wtx[0]);
	glTexCoordPointer(2,GL_DOUBLE,0,&tex[0]);
	glDrawElements(GL_TRIANGLES,3*trs.size(),GL_UNSIGNED_INT,&trs[0]);
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
}

void App::compute_warping() {
	int n=src.size();
	vector<array<double,10> > Q1(n);
	vector<vec<3> > uu(n);
	Landmarks::iterator si,di;
	array<vec<4>,4> eigv;
	vec<4> eiga;
	si=src.begin();
	di=dst.begin();
	for(int i=0;i<n;++i,++si,++di) {
		vec<3>& u=*si;
		vec<3>& v=*di;
		uu[i]=u;
		Q1[i][0]=v[0]*u[0]+v[1]*u[1]+v[2]*u[2];
		Q1[i][1]=-v[1]*u[2]+v[2]*u[1];
		Q1[i][2]=v[0]*u[0]-v[1]*u[1]-v[2]*u[2];
		Q1[i][3]=v[0]*u[2]-v[2]*u[0];
		Q1[i][4]=v[0]*u[1]+v[1]*u[0];
		Q1[i][5]=-v[0]*u[0]+v[1]*u[1]-v[2]*u[2];
		Q1[i][6]=-v[0]*u[1]+v[1]*u[0];
		Q1[i][7]=v[0]*u[2]+v[2]*u[0];
		Q1[i][8]=v[1]*u[2]+v[2]*u[1];
		Q1[i][9]=-v[0]*u[0]-v[1]*u[1]+v[2]*u[2];
	}
	
	for(int j=0;j<vtx.size();++j) {
		vec<3>& x=vtx[j];
		array<vec<4>,4> mat;
		for(int i=0;i<n;++i) {
			double d=10000*dot(x-uu[i],x-uu[i]);
			double w=1.0/(d+0.000000001);
			mat[0][0]+=Q1[i][0]*w;
			mat[0][1]+=Q1[i][1]*w;
			mat[1][1]+=Q1[i][2]*w;
			mat[0][2]+=Q1[i][3]*w;
			mat[1][2]+=Q1[i][4]*w;
			mat[2][2]+=Q1[i][5]*w;
			mat[0][3]+=Q1[i][6]*w;
			mat[1][3]+=Q1[i][7]*w;
			mat[2][3]+=Q1[i][8]*w;
			mat[3][3]+=Q1[i][9]*w;
		}
		mat[1][0]=mat[0][1];
		mat[2][0]=mat[0][2];
		mat[2][1]=mat[1][2];
		mat[3][0]=mat[0][3];
		mat[3][1]=mat[1][3];
		mat[3][2]=mat[2][3];
		
		eigenvalues(mat,eigv,eiga); 
		quat<double> q(eigv[3]);
		wtx[j]=action(q,x);
	}

}
