%module glut
%{
  #include <mytl/glut.hpp>
%}

// Mouse buttons
#define LEFT_BUTTON    0
#define MIDDLE_BUTTON  1
#define RIGHT_BUTTON   2

// Mouse button state
#define DOWN           0
#define UP             1

// glutGetModifiers return mask
#define ACTIVE_SHIFT   1
#define ACTIVE_CTRL    2
#define ACTIVE_ALT     4

// function keys
#define KEY_F1         1
#define KEY_F2         2
#define KEY_F3         3
#define KEY_F4         4
#define KEY_F5         5
#define KEY_F6         6
#define KEY_F7         7
#define KEY_F8         8
#define KEY_F9         9
#define KEY_F10        10
#define KEY_F11        11
#define KEY_F12        12

// directional keys
#define KEY_LEFT       100
#define KEY_UP         101
#define KEY_RIGHT      102
#define KEY_DOWN       103
#define KEY_PAGE_UP    104
#define KEY_PAGE_DOWN  105
#define KEY_HOME       106
#define KEY_END        107
#define KEY_INSERT     108

// display mode bit masks
#define RGB            0
#define RGBA           RGB
#define INDEX          1
#define SINGLE         0
#define DOUBLE         2
#define ACCUM          4
#define ALPHA          8
#define DEPTH          16
#define STENCIL        32


%rename("%(strip:[glut])s") "";
// functions subset
 void  glutInitDisplayMode(unsigned int mode);
 int   glutCreateWindow(const char *title);
 int   glutGetWindow(void);
 void  glutSetWindow(int win);
 int   glutCreateSubWindow(int win, int x, int y, int width, int height);
 int   glutGet(unsigned int type);
 void  glutSwapBuffers();
 void  glutPostRedisplay();
 void  glutFullScreen();
 void  glutInitWindowPosition(int x, int y);
 void  glutInitWindowSize(int width, int height);
 void  glutPositionWindow(int x, int y);
 void  glutReshapeWindow(int width, int height);
 void  glutMainLoop();
 int   glutGetModifiers(void);
 void  glutSolidTorus(double innerRadius, double outerRadius, int sides, int rings);
 void  glutSolidCone(double base, double height, int slices, int stacks);
 void  glutSolidTeapot(double size);
