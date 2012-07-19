#ifndef APP_H
#define APP_H

#include <vector>
#include <map>
#include <list>
#include <mytl/point.hpp>
#include <mytl/GL.hpp>

using namespace std;
using namespace mytl;

typedef vector<array<int,3> > Triangles;
typedef vector<vec<3> > Vertices;
typedef vector<vec<2> > TexCoords;
typedef map<array<int,2>,int> EdgeVertexMap;
typedef list<vec<3> > Landmarks;


class App {
	Triangles trs;
	Vertices vtx;
	Vertices wtx;
	TexCoords tex;
	Landmarks src;
	Landmarks dst;
	Landmarks::iterator selected;
	public:
	App();
	void draw_sphere();
	void draw_warped_sphere();
	void draw_source_landmarks();
	void draw_destination_landmarks();
	void draw_arcs();
	void add_landmark(int x, int y);
	void delete_landmark();
	bool select_landmark(int x, int y);
	void drag_landmark(int x, int y);
	void release_landmark(int x, int y);
	void compute_warping();
};

#endif // APP_H
