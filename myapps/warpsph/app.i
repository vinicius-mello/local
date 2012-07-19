/* File : app.i */
%module app

%{
class App {
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
%}
class App {
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
