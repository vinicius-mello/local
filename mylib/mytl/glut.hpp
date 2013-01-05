#ifndef MYTL_GLUT_HPP
#define MYTL_GLUT_HPP

#include <vector>
#include <utility>
#include "GL.hpp"
#ifdef __APPLE__
#include <GLUT/glut.h>
#else
#include <GL/glut.h>
#endif

/*
#define MYTL_GLUT_WINDOWS_ARRAY(X) std::vector<mytl::glut::window *> mytl::glut::window::callback::windows_array((X)+1)
#define MYTL_GLUT_MENUS_ARRAY(X) std::vector<mytl::glut::base_menu *> mytl::glut::base_menu::callback::menus_array((X)+1)
*/

#define MYTL_GLUT_ENTRY \
    mytl::glut::window * mytl::glut::window::callback::windows_array[16];\
mytl::glut::base_menu * mytl::glut::base_menu::callback::menus_array[16];

namespace mytl {

    using std::vector;

    namespace glut {

        inline void run() {
            glutMainLoop();
        }

        class window;

        inline void window_register(window * w);

        inline void idle(void (*f)(void)) {
            glutIdleFunc(f);
        }

        inline void timer(unsigned int milisec, void (*f)(int value), int value) {
            glutTimerFunc(milisec,f,value);
        }

        inline void init(int * argc, char ** argv) {
            glutInit(argc,argv);
        }


        class window {
            int ID;
            bool vis;
            public:

            struct callback {
                //static vector<window *> windows_array;
                static window * windows_array[16];
                static void reshape(int w, int h) {
                    window * bw=windows_array[glutGetWindow()];
                    bw->reshape(w,h);
                }
                static void display() {
                    window * bw=windows_array[glutGetWindow()];
                    bw->display();
                }
                static void mouse(int button, int state, int x, int y) {
                    window * bw=windows_array[glutGetWindow()];
                    bw->mouse(button,state,x,y);
                }
                static void visibility(int state) {
                    window * bw=windows_array[glutGetWindow()];
                    bw->visibility(state);
                }
                static void entry(int state) {
                    window * bw=windows_array[glutGetWindow()];
                    bw->entry(state);
                }
                static void keyboard(unsigned char key, int x, int y) {
                    window * bw=windows_array[glutGetWindow()];
                    bw->keyboard(key,x,y);
                }
                static void special(int key, int x, int y) {
                    window * bw=windows_array[glutGetWindow()];
                    bw->special(key,x,y);
                }
                static void motion(int x, int y) {
                    window * bw=windows_array[glutGetWindow()];
                    bw->motion(x,y);
                }
                static void passive_motion(int x, int y) {
                    window * bw=windows_array[glutGetWindow()];
                    bw->passive_motion(x,y);
                }
                static void callback_set() {
                    glutReshapeFunc(reshape);
                    glutDisplayFunc(display);
                    glutMouseFunc(mouse);
                    glutVisibilityFunc(visibility);
                    glutEntryFunc(entry);
                    glutKeyboardFunc(keyboard);
                    glutSpecialFunc(special);
                    glutMotionFunc(motion);
                    glutPassiveMotionFunc(0);
                }
            };
            window(char * title, unsigned int mode=GLUT_RGBA, int w=300, int h=300) {
                glutInitDisplayMode(mode);
                glutInitWindowSize(w,h);
                ID=glutCreateWindow(title);
                callback::callback_set();
                window_register(this);
            }
            window() {
                glutInitDisplayMode(GLUT_RGBA);
                glutInitWindowSize(300,300);
                ID=glutCreateWindow("");
                callback::callback_set();
                window_register(this);
            }
            virtual ~window() {
                glutDestroyWindow(getID());
            };
            virtual void reshape(int w, int h) {
                glViewport(0,0,w,h);
            }
            virtual void display() {}
            virtual void mouse(int button, int state, int x, int y) {}
            virtual void motion(int x, int y) {}
            virtual void passive_motion(int x, int y) {}
            virtual void keyboard(unsigned char key, int x, int y) {}
            virtual void special(int key, int x, int y) {}
            virtual void entry(int state) {}
            virtual void visibility(int state) {
                if(state==GLUT_VISIBLE) vis=true;
                else vis=false;
            };
            int getID() const {
                return ID;
            }
            bool visible() const {
                return vis;
            }
            void post_redisplay() {
                glutSetWindow(getID());
                glutPostRedisplay();
            }
            void make_active() {
                glutSetWindow(getID());
            }
            void swap_buffers() {
                glutSetWindow(getID());
                glutSwapBuffers();
            }
            void position_window(int x, int y) {
                glutSetWindow(getID());
                glutPositionWindow(x,y);
            }
            void reshape_window(int w, int h) {
                glutSetWindow(getID());
                glutReshapeWindow(w,h);
            }
            void full_screen() {
                glutSetWindow(getID());
                glutFullScreen();
            }
            void show_window() {
                glutSetWindow(getID());
                glutShowWindow();
            }
            void hide_window() {
                glutSetWindow(getID());
                glutHideWindow();
            }
            void iconify_window() {
                glutSetWindow(getID());
                glutIconifyWindow();
            }
            void set_window_title(char * title) {
                glutSetWindow(getID());
                glutSetWindowTitle(title);
            }
            void set_icon_title(char * title) {
                glutSetWindow(getID());
                glutSetIconTitle(title);
            }
            void set_cursor(int cursor) {
                glutSetWindow(getID());
                glutSetCursor(cursor);
            }
            int width() const {
                glutSetWindow(getID());
                return glutGet(GLUT_WINDOW_WIDTH);
            }
            int height() const {
                glutSetWindow(getID());
                return glutGet(GLUT_WINDOW_HEIGHT);
            }
            double aspect_ratio() const {
                double f=width();
                return f/height();
            }
            std::pair<double,double> normalize(int x, int y) const {
                double w=width();
                double h=height();
                double fx,fy;
                if(w<h) {
                    fx=2*x/w-1;
                    fy=(h-2*y)/w;
                } else {
                    fx=(2*x-w)/h;
                    fy=1-2*y/h;
                }
                return std::make_pair(fx,fy);
            }
            std::pair<double,double> denormalize(double fx, double fy) const {
                double w=width();
                double h=height();
                double x,y;
                if(w<h) {
                    x=w*(fx+1)/2;
                    y=(h-w*fy)/2;
                } else {
                    x=(fx*h+w)/2;
                    y=h*(1-fy)/2;
                }
                return std::make_pair(x,y);
            }
            void passive_motion_enable() {
                glutPassiveMotionFunc(callback::passive_motion);
            }
            void passive_motion_disable() {
                glutPassiveMotionFunc(0);
            }
        };


        inline void window_register(window * w) {
            window::callback::windows_array[w->getID()]=w;
        }

        class base_menu {
            int ID;
            public:

            struct callback {
                //static vector<base_menu *> menus_array;
                static base_menu * menus_array[16];
                static void call(int entry) {
                    base_menu * m=menus_array[glutGetMenu()];
                    m->call(entry);
                }
            };

            base_menu() {
                ID=glutCreateMenu(callback::call);
                callback::menus_array[ID]=this;
            }
            virtual ~base_menu() {
                glutDestroyWindow(getID());
            };
            virtual void call(int e)=0;
            int getID() const {
                return ID;
            }
        };

        template <class Window>
            class menu : public base_menu {
                typedef void (Window::*menuentry)();
                vector<menuentry> entries;
                Window * w;
                public:
                menu(Window * _w) : w(_w) {}
                void add(char * name, menuentry ne) {
                    glutSetMenu(getID());
                    glutAddMenuEntry(name, entries.size());
                    entries.push_back(ne);
                }
                void call(int e) {
                    (w->*(entries[e]))();
                }
                void attach(int button) {
                    glutSetWindow(w->getID());
                    glutSetMenu(getID());
                    glutAttachMenu(button);
                }
                void detach(int button) {
                    glutSetWindow(w->getID());
                    glutSetMenu(getID());
                    glutDetachMenu(button);
                }
            };
    }

}

#endif  // MYTL_GLUT_WINDOW_HPP
