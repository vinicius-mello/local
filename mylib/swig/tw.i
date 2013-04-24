%module tw
%{
#include <wrappers/tw.hpp>
%}

%rename("%(strip:[Tw])s") "";
 TwBar *       TwNewBar(const char *barName);
 int           TwDeleteBar(TwBar *bar);
 int           TwDeleteAllBars();
 int           TwSetTopBar(const TwBar *bar);
 TwBar *       TwGetTopBar();
 int           TwSetBottomBar(const TwBar *bar);
 TwBar *       TwGetBottomBar();
 const char *  TwGetBarName(TwBar *bar);
 int           TwGetBarCount();
 TwBar *       TwGetBarByIndex(int barIndex);
 TwBar *       TwGetBarByName(const char *barName);
 int           TwRefreshBar(TwBar *bar);

 int       TwDefine(const char *def);

 int       TwInit(TwGraphAPI graphAPI);
 int       TwTerminate();

 int       TwDraw();
 int       TwWindowSize(int width, int height);

 int       TwSetCurrentWindow(int windowID); // multi-windows support
 int       TwGetCurrentWindow();
 int       TwWindowExists(int windowID);

 int       TwKeyPressed(int key, int modifiers);
 int       TwKeyTest(int key, int modifiers);

 int       TwMouseButton(TwMouseAction action, TwMouseButtonID button);
 int       TwMouseMotion(int mouseX, int mouseY);
 int       TwMouseWheel(int pos);

 const char *  TwGetLastError();


 int  TwEventMouseButtonGLUT(int glutButton, int glutState, int mouseX, int mouseY);
 int  TwEventMouseMotionGLUT(int mouseX, int mouseY);
 int  TwEventKeyboardGLUT(unsigned char glutKey, int mouseX, int mouseY);
 int  TwEventSpecialGLUT(int glutKey, int mouseX, int mouseY);


void TwNewVar(const char * bar_name, const char * var_name, TwType type, const char * prop=0, bool ro=false);
void TwNewEnum(const char * bar_name, const char * var_name, const char * enum_name, const char * enum_values, const char * prop=0);
TwType TwGetVarType(const char * bar_name, const char * var_name);
int TwGetIntVarByName(const char * bar_name, const char * var_name);
void TwSetIntVarByName(const char * bar_name, const char * var_name, int value);
bool TwGetBoolVarByName(const char * bar_name, const char * var_name);
void TwSetBoolVarByName(const char * bar_name, const char * var_name, bool value);
char * TwGetStringVarByName(const char * bar_name, const char * var_name);
void TwSetStringVarByName(const char * bar_name, const char * var_name, char * value);
double TwGetDoubleVarByName(const char * bar_name, const char * var_name);
void TwSetDoubleVarByName(const char * bar_name, const char * var_name, double value);
array<double> TwGetArrayDoubleVarByName(const char * bar_name, const char * var_name);
void TwSetArrayDoubleVarByName(const char * bar_name, const char * var_name, const array<double>& value);
array<float> TwGetArrayFloatVarByName(const char * bar_name, const char * var_name);
void TwSetArrayFloatVarByName(const char * bar_name, const char * var_name, const array<float>& value);
void TwAddSeparatorByName(const char * bar_name, const char * sp_name);
void TwAddButtonByName(const char * bar_name, const char * button_name,
        TwButtonCallback callback, void *clientData);

%rename("%(strip:[TW_])s") "";


enum TwType
{
    TW_TYPE_UNDEF   = 0,
    TW_TYPE_BOOLCPP = 1,
    TW_TYPE_BOOL8   = 2,
    TW_TYPE_BOOL16,
    TW_TYPE_BOOL32,
    TW_TYPE_CHAR,
    TW_TYPE_INT8,
    TW_TYPE_UINT8,
    TW_TYPE_INT16,
    TW_TYPE_UINT16,
    TW_TYPE_INT32,
    TW_TYPE_UINT32,
    TW_TYPE_FLOAT,
    TW_TYPE_DOUBLE,
    TW_TYPE_COLOR32,    // 32 bits color. Order is RGBA if API is OpenGL or Direct3D10, and inversed if API is Direct3D9 (can be modified by defining 'colorOrder=...', see doc)
    TW_TYPE_COLOR3F,    // 3 floats color. Order is RGB.
    TW_TYPE_COLOR4F,    // 4 floats color. Order is RGBA.
    TW_TYPE_CDSTRING,   // Null-terminated C Dynamic String (pointer to an array of char dynamically allocated with malloc/realloc/strdup)
    TW_TYPE_QUAT4F = TYPE_CDSTRING+2, // 4 floats encoding a quaternion {qx,qy,qz,qs}
    TW_TYPE_QUAT4D,     // 4 doubles encoding a quaternion {qx,qy,qz,qs}
    TW_TYPE_DIR3F,      // direction vector represented by 3 floats
    TW_TYPE_DIR3D,       // direction vector represented by 3 doubles
    TW_TYPE_CSSTRING_256 = TW_TYPE_CSSTRING_256
};


enum TwParamValueType
{
    TW_PARAM_INT32,
    TW_PARAM_FLOAT,
    TW_PARAM_DOUBLE,
    TW_PARAM_CSTRING // Null-terminated array of char (ie, c-string)
};


enum TwGraphAPI
{
    TW_OPENGL           = 1,
    TW_DIRECT3D9        = 2,
    TW_DIRECT3D10       = 3,
    TW_DIRECT3D11       = 4,
    TW_OPENGL_CORE      = 5
};


enum TwKeyModifier
{
    TW_KMOD_NONE        = 0x0000,   // same codes as SDL keysym.mod
    TW_KMOD_SHIFT       = 0x0003,
    TW_KMOD_CTRL        = 0x00c0,
    TW_KMOD_ALT         = 0x0100,
    TW_KMOD_META        = 0x0c00
};
enum KeySpecial
{
    TW_KEY_BACKSPACE    = '\b',
    TW_KEY_TAB          = '\t',
    TW_KEY_CLEAR        = 0x0c,
    TW_KEY_RETURN       = '\r',
    TW_KEY_PAUSE        = 0x13,
    TW_KEY_ESCAPE       = 0x1b,
    TW_KEY_SPACE        = ' ',
    TW_KEY_DELETE       = 0x7f,
    TW_KEY_UP           = 273,      // same codes and order as SDL 1.2 keysym.sym
    TW_KEY_DOWN,
    TW_KEY_RIGHT,
    TW_KEY_LEFT,
    TW_KEY_INSERT,
    TW_KEY_HOME,
    TW_KEY_END,
    TW_KEY_PAGE_UP,
    TW_KEY_PAGE_DOWN,
    TW_KEY_F1,
    TW_KEY_F2,
    TW_KEY_F3,
    TW_KEY_F4,
    TW_KEY_F5,
    TW_KEY_F6,
    TW_KEY_F7,
    TW_KEY_F8,
    TW_KEY_F9,
    TW_KEY_F10,
    TW_KEY_F11,
    TW_KEY_F12,
    TW_KEY_F13,
    TW_KEY_F14,
    TW_KEY_F15,
    TW_KEY_LAST
};

enum TwMouseAction
{
    TW_MOUSE_RELEASED,
    TW_MOUSE_PRESSED
};

enum TwMouseButtonID
{
    TW_MOUSE_LEFT       = 1,    // same code as SDL_BUTTON_LEFT
    TW_MOUSE_MIDDLE     = 2,    // same code as SDL_BUTTON_MIDDLE
    TW_MOUSE_RIGHT      = 3     // same code as SDL_BUTTON_RIGHT
};

