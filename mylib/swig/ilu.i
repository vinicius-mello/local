//-----------------------------------------------------------------------------
//
// ImageLib Utility Sources
// Copyright (C) 2000-2009 by Denton Woods
// Last modified: 03/07/2009
//
// Filename: IL/ilu.h
//
// Description: The main include file for ILU
//
//-----------------------------------------------------------------------------

// Doxygen comment
/*! \file ilu.h
    The main include file for ILU
*/
%module luailu
%{
#include <IL/ilu.h>
#define iluScaleColors  iluScaleColours
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



#define VERSION_1_7_8 1
#define VERSION       178


#define FILTER         0x2600
#define NEAREST        0x2601
#define LINEAR         0x2602
#define BILINEAR       0x2603
#define SCALE_BOX      0x2604
#define SCALE_TRIANGLE 0x2605
#define SCALE_BELL     0x2606
#define SCALE_BSPLINE  0x2607
#define SCALE_LANCZOS3 0x2608
#define SCALE_MITCHELL 0x2609


// Error types
#define INVALID_ENUM      0x0501
#define OUT_OF_MEMORY     0x0502
#define INTERNAL_ERROR    0x0504
#define INVALID_VALUE     0x0505
#define ILLEGAL_OPERATION 0x0506
#define INVALID_PARAM     0x0509


// Values
#define PLACEMENT          0x0700
#define LOWER_LEFT         0x0701
#define LOWER_RIGHT        0x0702
#define UPPER_LEFT         0x0703
#define UPPER_RIGHT        0x0704
#define CENTER             0x0705
#define CONVOLUTION_MATRIX 0x0710
  
#define VERSION_NUM IL_VERSION_NUM
#define VENDOR      IL_VENDOR


// Languages
#define ENGLISH            0x0800
#define ARABIC             0x0801
#define DUTCH              0x0802
#define JAPANESE           0x0803
#define SPANISH            0x0804
#define GERMAN             0x0805
#define FRENCH             0x0806


// Filters
/*
#define FILTER_BLUR         0x0803
#define FILTER_GAUSSIAN_3x3 0x0804
#define FILTER_GAUSSIAN_5X5 0x0805
#define FILTER_EMBOSS1      0x0807
#define FILTER_EMBOSS2      0x0808
#define FILTER_LAPLACIAN1   0x080A
#define FILTER_LAPLACIAN2   0x080B
#define FILTER_LAPLACIAN3   0x080C
#define FILTER_LAPLACIAN4   0x080D
#define FILTER_SHARPEN1     0x080E
#define FILTER_SHARPEN2     0x080F
#define FILTER_SHARPEN3     0x0810
*/


typedef struct ILinfo
{
	ILuint  Id;         // the image's id
	ILubyte *Data;      // the image's data
	ILuint  Width;      // the image's width
	ILuint  Height;     // the image's height
	ILuint  Depth;      // the image's depth
	ILubyte Bpp;        // bytes per pixel (not bits) of the image
	ILuint  SizeOfData; // the total size of the data (in bytes)
	ILenum  Format;     // image format (in IL enum style)
	ILenum  Type;       // image type (in IL enum style)
	ILenum  Origin;     // origin of the image
	ILubyte *Palette;   // the image's palette
	ILenum  PalType;    // palette type
	ILuint  PalSize;    // palette size
	ILenum  CubeFlags;  // flags for what cube map sides are present
	ILuint  NumNext;    // number of images following
	ILuint  NumMips;    // number of mipmaps
	ILuint  NumLayers;  // number of layers
} ILinfo;


typedef struct ILpointf {
	ILfloat x;
	ILfloat y;
} ILpointf;

typedef struct ILpointi {
	ILint x;
	ILint y;
} ILpointi;

%rename("%(strip:[ilu])s") "";

 ILboolean       iluAlienify(void);
 ILboolean       iluBlurAvg(ILuint Iter);
 ILboolean       iluBlurGaussian(ILuint Iter);
 ILboolean       iluBuildMipmaps(void);
 ILuint          iluColorsUsed(void);
 ILboolean       iluCompareImage(ILuint Comp);
 ILboolean       iluContrast(ILfloat Contrast);
 ILboolean       iluCrop(ILuint XOff, ILuint YOff, ILuint ZOff, ILuint Width, ILuint Height, ILuint Depth);
 void            iluDeleteImage(ILuint Id); // Deprecated
 ILboolean       iluEdgeDetectE(void);
 ILboolean       iluEdgeDetectP(void);
 ILboolean       iluEdgeDetectS(void);
 ILboolean       iluEmboss(void);
 ILboolean       iluEnlargeCanvas(ILuint Width, ILuint Height, ILuint Depth);
 ILboolean       iluEnlargeImage(ILfloat XDim, ILfloat YDim, ILfloat ZDim);
 ILboolean       iluEqualize(void);
 ILconst_string 		  iluErrorString(ILenum Error);
 ILboolean       iluConvolution(ILint *matrix, ILint scale, ILint bias);
 ILboolean       iluFlipImage(void);
 ILboolean       iluGammaCorrect(ILfloat Gamma);
 ILuint          iluGenImage(void); // Deprecated
 void            iluGetImageInfo(ILinfo *Info);
 ILint           iluGetInteger(ILenum Mode);
 void            iluGetIntegerv(ILenum Mode, ILint *Param);
 ILstring 		  iluGetString(ILenum StringName);
 void            iluImageParameter(ILenum PName, ILenum Param);
 void            iluInit(void);
 ILboolean       iluInvertAlpha(void);
 ILuint          iluLoadImage(ILconst_string FileName);
 ILboolean       iluMirror(void);
 ILboolean       iluNegative(void);
 ILboolean       iluNoisify(ILclampf Tolerance);
 ILboolean       iluPixelize(ILuint PixSize);
 void            iluRegionfv(ILpointf *Points, ILuint n);
 void            iluRegioniv(ILpointi *Points, ILuint n);
 ILboolean       iluReplaceColor(ILubyte Red, ILubyte Green, ILubyte Blue, ILfloat Tolerance);
 ILboolean       iluRotate(ILfloat Angle);
 ILboolean       iluRotate3D(ILfloat x, ILfloat y, ILfloat z, ILfloat Angle);
 ILboolean       iluSaturate1f(ILfloat Saturation);
 ILboolean       iluSaturate4f(ILfloat r, ILfloat g, ILfloat b, ILfloat Saturation);
 ILboolean       iluScale(ILuint Width, ILuint Height, ILuint Depth);
 ILboolean       iluScaleAlpha(ILfloat scale);
 ILboolean       iluScaleColors(ILfloat r, ILfloat g, ILfloat b);
 ILboolean       iluSetLanguage(ILenum Language);
 ILboolean       iluSharpen(ILfloat Factor, ILuint Iter);
 ILboolean       iluSwapColors(void);
 ILboolean       iluWave(ILfloat Angle);

