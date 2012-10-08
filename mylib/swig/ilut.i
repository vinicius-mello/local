//-----------------------------------------------------------------------------
//
// ImageLib Utility Toolkit Sources
// Copyright (C) 2000-2009 by Denton Woods
// Last modified: 03/07/2009
//
// Filename: IL/ilut.h
//
// Description: The main include file for ILUT
//
//-----------------------------------------------------------------------------

// Doxygen comment
/*! \file ilut.h
    The main include file for ILUT
*/

%module luailut
%{
#include <GL/gl.h>
#define ILUT_USE_OPENGL
#include <IL/ilut.h>
%}

typedef unsigned int   ILenum;
typedef unsigned char  ILboolean;
typedef unsigned int   ILbitfield;
typedef signed char    ILbyte;
typedef signed short   ILshort;
typedef int     	     ILint;
typedef size_t         ILsizei;
typedef unsigned char  ILubyte;
typedef unsigned short ILushort;
typedef unsigned int   ILuint;
typedef float          ILfloat;
typedef float          ILclampf;
typedef double         ILdouble;
typedef double         ILclampd;
typedef char           ILchar;
typedef char*          ILstring;
typedef char const *   ILconst_string;

typedef unsigned int   GLuint;

//-----------------------------------------------------------------------------
// Defines
//-----------------------------------------------------------------------------

#define VERSION_1_7_8 1
#define VERSION       178


// Attribute Bits
#define OPENGL_BIT      0x00000001
#define D3D_BIT         0x00000002
#define ALL_ATTRIB_BITS 0x000FFFFF


// Error Types
#define INVALID_ENUM        0x0501
#define OUT_OF_MEMORY       0x0502
#define INVALID_VALUE       0x0505
#define ILLEGAL_OPERATION   0x0506
#define INVALID_PARAM       0x0509
#define COULD_NOT_OPEN_FILE 0x050A
#define STACK_OVERFLOW      0x050E
#define STACK_UNDERFLOW     0x050F
#define BAD_DIMENSIONS      0x0511
#define NOT_SUPPORTED       0x0550


// State Definitions
#define PALETTE_MODE         0x0600
#define OPENGL_CONV          0x0610
#define D3D_MIPLEVELS        0x0620
#define MAXTEX_WIDTH         0x0630
#define MAXTEX_HEIGHT        0x0631
#define MAXTEX_DEPTH         0x0632
#define GL_USE_S3TC          0x0634
#define D3D_USE_DXTC         0x0634
#define GL_GEN_S3TC          0x0635
#define D3D_GEN_DXTC         0x0635
#define S3TC_FORMAT          0x0705
#define DXTC_FORMAT          0x0705
#define D3D_POOL             0x0706
#define D3D_ALPHA_KEY_COLOR  0x0707
#define D3D_ALPHA_KEY_COLOUR 0x0707
#define FORCE_INTEGER_FORMAT 0x0636

//This new state does automatic texture target detection
//if enabled. Currently, only cubemap detection is supported.
//if the current image is no cubemap, the 2d texture is chosen.
#define GL_AUTODETECT_TEXTURE_TARGET 0x0807


// Values
#define VERSION_NUM IL_VERSION_NUM
#define VENDOR      IL_VENDOR

#define OPENGL     0
#define ALLEGRO    1
#define WIN32      2
#define DIRECT3D8  3
#define	DIRECT3D9  4
#define X11        5
#define	DIRECT3D10 6

#define USE_OPENGL

%rename("%(strip:[ilut])s") "";

// ImageLib Utility Toolkit Functions
 ILboolean		 ilutDisable(ILenum Mode);
 ILboolean		 ilutEnable(ILenum Mode);
 ILboolean		 ilutGetBoolean(ILenum Mode);
 void           ilutGetBooleanv(ILenum Mode, ILboolean *Param);
 ILint			 ilutGetInteger(ILenum Mode);
 void           ilutGetIntegerv(ILenum Mode, ILint *Param);
 ILstring       ilutGetString(ILenum StringName);
 void           ilutInit(void);
 ILboolean      ilutIsDisabled(ILenum Mode);
 ILboolean      ilutIsEnabled(ILenum Mode);
 void           ilutPopAttrib(void);
 void           ilutPushAttrib(ILuint Bits);
 void           ilutSetInteger(ILenum Mode, ILint Param);

 ILboolean      ilutRenderer(ILenum Renderer);


	 GLuint	 ilutGLBindTexImage();
	 GLuint	 ilutGLBindMipmaps(void);
	 ILboolean	 ilutGLBuildMipmaps(void);
	 GLuint	 ilutGLLoadImage(ILstring FileName);
	 ILboolean	 ilutGLScreen(void);
	 ILboolean	 ilutGLScreenie(void);
	 ILboolean	 ilutGLSaveImage(ILstring FileName, GLuint TexID);
	 ILboolean  ilutGLSubTex2D(GLuint TexID, ILuint XOff, ILuint YOff);
	 ILboolean  ilutGLSubTex3D(GLuint TexID, ILuint XOff, ILuint YOff, ILuint ZOff);
	 ILboolean	 ilutGLSetTex2D(GLuint TexID);
	 ILboolean	 ilutGLSetTex3D(GLuint TexID);
	 ILboolean	 ilutGLTexImage(GLuint Level);
	 ILboolean  ilutGLSubTex(GLuint TexID, ILuint XOff, ILuint YOff);

	 ILboolean	 ilutGLSetTex(GLuint TexID);  // Deprecated - use ilutGLSetTex2D.
	 ILboolean  ilutGLSubTex(GLuint TexID, ILuint XOff, ILuint YOff);  // Use ilutGLSubTex2D.

