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

%module devilut
%{
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

#define ILUT_VERSION_1_7_8 1
#define ILUT_VERSION       178


// Attribute Bits
#define ILUT_OPENGL_BIT      0x00000001
#define ILUT_D3D_BIT         0x00000002
#define ILUT_ALL_ATTRIB_BITS 0x000FFFFF


// Error Types
#define ILUT_INVALID_ENUM        0x0501
#define ILUT_OUT_OF_MEMORY       0x0502
#define ILUT_INVALID_VALUE       0x0505
#define ILUT_ILLEGAL_OPERATION   0x0506
#define ILUT_INVALID_PARAM       0x0509
#define ILUT_COULD_NOT_OPEN_FILE 0x050A
#define ILUT_STACK_OVERFLOW      0x050E
#define ILUT_STACK_UNDERFLOW     0x050F
#define ILUT_BAD_DIMENSIONS      0x0511
#define ILUT_NOT_SUPPORTED       0x0550


// State Definitions
#define ILUT_PALETTE_MODE         0x0600
#define ILUT_OPENGL_CONV          0x0610
#define ILUT_D3D_MIPLEVELS        0x0620
#define ILUT_MAXTEX_WIDTH         0x0630
#define ILUT_MAXTEX_HEIGHT        0x0631
#define ILUT_MAXTEX_DEPTH         0x0632
#define ILUT_GL_USE_S3TC          0x0634
#define ILUT_D3D_USE_DXTC         0x0634
#define ILUT_GL_GEN_S3TC          0x0635
#define ILUT_D3D_GEN_DXTC         0x0635
#define ILUT_S3TC_FORMAT          0x0705
#define ILUT_DXTC_FORMAT          0x0705
#define ILUT_D3D_POOL             0x0706
#define ILUT_D3D_ALPHA_KEY_COLOR  0x0707
#define ILUT_D3D_ALPHA_KEY_COLOUR 0x0707
#define ILUT_FORCE_INTEGER_FORMAT 0x0636

//This new state does automatic texture target detection
//if enabled. Currently, only cubemap detection is supported.
//if the current image is no cubemap, the 2d texture is chosen.
#define ILUT_GL_AUTODETECT_TEXTURE_TARGET 0x0807


// Values
#define ILUT_VERSION_NUM IL_VERSION_NUM
#define ILUT_VENDOR      IL_VENDOR

#define ILUT_OPENGL     0
#define ILUT_ALLEGRO    1
#define ILUT_WIN32      2
#define ILUT_DIRECT3D8  3
#define	ILUT_DIRECT3D9  4
#define ILUT_X11        5
#define	ILUT_DIRECT3D10 6

#define ILUT_USE_OPENGL

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

