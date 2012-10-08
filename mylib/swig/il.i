%module luail
%{
  #include <IL/il.h>
%}

#define CLAMP_HALF		1
#define CLAMP_FLOATS	1
#define CLAMP_DOUBLES	1

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


#define FALSE			0
#define TRUE				1

//  Matches OpenGL's right now.
//! Data formats \link Formats Formats\endlink
#define COLOUR_INDEX     0x1900
#define COLOR_INDEX      0x1900
#define ALPHA			0x1906
#define RGB              0x1907
#define RGBA             0x1908
#define BGR              0x80E0
#define BGRA             0x80E1
#define LUMINANCE        0x1909
#define LUMINANCE_ALPHA  0x190A

//! Data types \link Types Types\endlink
#define BYTE           0x1400
#define UNSIGNED_BYTE  0x1401
#define SHORT          0x1402
#define UNSIGNED_SHORT 0x1403
#define INT            0x1404
#define UNSIGNED_INT   0x1405
#define FLOAT          0x1406
#define DOUBLE         0x140A
#define HALF           0x140B


#define MAX_BYTE		  		SCHAR_MAX
#define MAX_UNSIGNED_BYTE  	UCHAR_MAX
#define MAX_SHORT	  		SHRT_MAX
#define MAX_UNSIGNED_SHORT 	USHRT_MAX
#define MAX_INT		  		INT_MAX
#define MAX_UNSIGNED_INT   	UINT_MAX

#define LIMIT(x,m,M)		(x<m?m:(x>M?M:x))
#define CLAMP(x) 		IL_LIMIT(x,0,1)

#define VENDOR   0x1F00
#define LOAD_EXT 0x1F01
#define SAVE_EXT 0x1F02


//
// IL-specific #define's
//

#define VERSION_1_7_8 1
#define VERSION       178


// Attribute Bits
#define ORIGIN_BIT          0x00000001
#define FILE_BIT            0x00000002
#define PAL_BIT             0x00000004
#define FORMAT_BIT          0x00000008
#define TYPE_BIT            0x00000010
#define COMPRESS_BIT        0x00000020
#define LOADFAIL_BIT        0x00000040
#define FORMAT_SPECIFIC_BIT 0x00000080
#define ALL_ATTRIB_BITS     0x000FFFFF


// Palette types
#define PAL_NONE   0x0400
#define PAL_RGB24  0x0401
#define PAL_RGB32  0x0402
#define PAL_RGBA32 0x0403
#define PAL_BGR24  0x0404
#define PAL_BGR32  0x0405
#define PAL_BGRA32 0x0406


// Image types
#define TYPE_UNKNOWN 0x0000
#define BMP          0x0420  //!< Microsoft Windows Bitmap - .bmp extension
#define CUT          0x0421  //!< Dr. Halo - .cut extension
#define DOOM         0x0422  //!< DooM walls - no specific extension
#define DOOM_FLAT    0x0423  //!< DooM flats - no specific extension
#define ICO          0x0424  //!< Microsoft Windows Icons and Cursors - .ico and .cur extensions
#define JPG          0x0425  //!< JPEG - .jpg, .jpe and .jpeg extensions
#define JFIF         0x0425  //!<
#define ILBM         0x0426  //!< Amiga IFF (FORM ILBM) - .iff, .ilbm, .lbm extensions
#define PCD          0x0427  //!< Kodak PhotoCD - .pcd extension
#define PCX          0x0428  //!< ZSoft PCX - .pcx extension
#define PIC          0x0429  //!< PIC - .pic extension
#define PNG          0x042A  //!< Portable Network Graphics - .png extension
#define PNM          0x042B  //!< Portable Any Map - .pbm, .pgm, .ppm and .pnm extensions
#define SGI          0x042C  //!< Silicon Graphics - .sgi, .bw, .rgb and .rgba extensions
#define TGA          0x042D  //!< TrueVision Targa File - .tga, .vda, .icb and .vst extensions
#define TIF          0x042E  //!< Tagged Image File Format - .tif and .tiff extensions
#define CHEAD        0x042F  //!< C-Style Header - .h extension
#define RAW          0x0430  //!< Raw Image Data - any extension
#define MDL          0x0431  //!< Half-Life Model Texture - .mdl extension
#define WAL          0x0432  //!< Quake 2 Texture - .wal extension
#define LIF          0x0434  //!< Homeworld Texture - .lif extension
#define MNG          0x0435  //!< Multiple-image Network Graphics - .mng extension
#define JNG          0x0435  //!< 
#define GIF          0x0436  //!< Graphics Interchange Format - .gif extension
#define DDS          0x0437  //!< DirectDraw Surface - .dds extension
#define DCX          0x0438  //!< ZSoft Multi-PCX - .dcx extension
#define PSD          0x0439  //!< Adobe PhotoShop - .psd extension
#define EXIF         0x043A  //!< 
#define PSP          0x043B  //!< PaintShop Pro - .psp extension
#define PIX          0x043C  //!< PIX - .pix extension
#define PXR          0x043D  //!< Pixar - .pxr extension
#define XPM          0x043E  //!< X Pixel Map - .xpm extension
#define HDR          0x043F  //!< Radiance High Dynamic Range - .hdr extension
#define ICNS			0x0440  //!< Macintosh Icon - .icns extension
#define JP2			0x0441  //!< Jpeg 2000 - .jp2 extension
#define EXR			0x0442  //!< OpenEXR - .exr extension
#define WDP			0x0443  //!< Microsoft HD Photo - .wdp and .hdp extension
#define VTF			0x0444  //!< Valve Texture Format - .vtf extension
#define WBMP			0x0445  //!< Wireless Bitmap - .wbmp extension
#define SUN			0x0446  //!< Sun Raster - .sun, .ras, .rs, .im1, .im8, .im24 and .im32 extensions
#define IFF			0x0447  //!< Interchange File Format - .iff extension
#define TPL			0x0448  //!< Gamecube Texture - .tpl extension
#define FITS			0x0449  //!< Flexible Image Transport System - .fit and .fits extensions
#define DICOM		0x044A  //!< Digital Imaging and Communications in Medicine (DICOM) - .dcm and .dicom extensions
#define IWI			0x044B  //!< Call of Duty Infinity Ward Image - .iwi extension
#define BLP			0x044C  //!< Blizzard Texture Format - .blp extension
#define FTX			0x044D  //!< Heavy Metal: FAKK2 Texture - .ftx extension
#define ROT			0x044E  //!< Homeworld 2 - Relic Texture - .rot extension
#define TEXTURE		0x044F  //!< Medieval II: Total War Texture - .texture extension
#define DPX			0x0450  //!< Digital Picture Exchange - .dpx extension
#define UTX			0x0451  //!< Unreal (and Unreal Tournament) Texture - .utx extension
#define MP3			0x0452  //!< MPEG-1 Audio Layer 3 - .mp3 extension


#define JASC_PAL     0x0475  //!< PaintShop Pro Palette


// Error Types
#define NO_ERROR             0x0000
#define INVALID_ENUM         0x0501
#define OUT_OF_MEMORY        0x0502
#define FORMAT_NOT_SUPPORTED 0x0503
#define INTERNAL_ERROR       0x0504
#define INVALID_VALUE        0x0505
#define ILLEGAL_OPERATION    0x0506
#define ILLEGAL_FILE_VALUE   0x0507
#define INVALID_FILE_HEADER  0x0508
#define INVALID_PARAM        0x0509
#define COULD_NOT_OPEN_FILE  0x050A
#define INVALID_EXTENSION    0x050B
#define FILE_ALREADY_EXISTS  0x050C
#define OUT_FORMAT_SAME      0x050D
#define STACK_OVERFLOW       0x050E
#define STACK_UNDERFLOW      0x050F
#define INVALID_CONVERSION   0x0510
#define BAD_DIMENSIONS       0x0511
#define FILE_READ_ERROR      0x0512  // 05/12/2002: Addition by Sam.
#define FILE_WRITE_ERROR     0x0512

#define LIB_GIF_ERROR  0x05E1
#define LIB_JPEG_ERROR 0x05E2
#define LIB_PNG_ERROR  0x05E3
#define LIB_TIFF_ERROR 0x05E4
#define LIB_MNG_ERROR  0x05E5
#define LIB_JP2_ERROR  0x05E6
#define LIB_EXR_ERROR  0x05E7
#define UNKNOWN_ERROR  0x05FF


// Origin Definitions
#define ORIGIN_SET        0x0600
#define ORIGIN_LOWER_LEFT 0x0601
#define ORIGIN_UPPER_LEFT 0x0602
#define ORIGIN_MODE       0x0603


// Format and Type Mode Definitions
#define FORMAT_SET  0x0610
#define FORMAT_MODE 0x0611
#define TYPE_SET    0x0612
#define TYPE_MODE   0x0613


// File definitions
#define FILE_OVERWRITE	0x0620
#define FILE_MODE		0x0621


// Palette definitions
#define CONV_PAL			0x0630


// Load fail definitions
#define DEFAULT_ON_FAIL	0x0632


// Key colour and alpha definitions
#define USE_KEY_COLOUR	0x0635
#define USE_KEY_COLOR	0x0635
#define BLIT_BLEND		0x0636


// Interlace definitions
#define SAVE_INTERLACED	0x0639
#define INTERLACE_MODE	0x063A


// Quantization definitions
#define QUANTIZATION_MODE 0x0640
#define WU_QUANT          0x0641
#define NEU_QUANT         0x0642
#define NEU_QUANT_SAMPLE  0x0643
#define MAX_QUANT_INDEXS  0x0644 //XIX : ILint : Maximum number of colors to reduce to, default of 256. and has a range of 2-256
#define MAX_QUANT_INDICES 0x0644 // Redefined, since the above #define is misspelled


// Hints
#define FASTEST          0x0660
#define LESS_MEM         0x0661
#define DONT_CARE        0x0662
#define MEM_SPEED_HINT   0x0665
#define USE_COMPRESSION  0x0666
#define NO_COMPRESSION   0x0667
#define COMPRESSION_HINT 0x0668


// Compression
#define NVIDIA_COMPRESS	0x0670
#define SQUISH_COMPRESS	0x0671


// Subimage types
#define SUB_NEXT   0x0680
#define SUB_MIPMAP 0x0681
#define SUB_LAYER  0x0682


// Compression definitions
#define COMPRESS_MODE 0x0700
#define COMPRESS_NONE 0x0701
#define COMPRESS_RLE  0x0702
#define COMPRESS_LZO  0x0703
#define COMPRESS_ZLIB 0x0704


// File format-specific values
#define TGA_CREATE_STAMP        0x0710
#define JPG_QUALITY             0x0711
#define PNG_INTERLACE           0x0712
#define TGA_RLE                 0x0713
#define BMP_RLE                 0x0714
#define SGI_RLE                 0x0715
#define TGA_ID_STRING           0x0717
#define TGA_AUTHNAME_STRING     0x0718
#define TGA_AUTHCOMMENT_STRING  0x0719
#define PNG_AUTHNAME_STRING     0x071A
#define PNG_TITLE_STRING        0x071B
#define PNG_DESCRIPTION_STRING  0x071C
#define TIF_DESCRIPTION_STRING  0x071D
#define TIF_HOSTCOMPUTER_STRING 0x071E
#define TIF_DOCUMENTNAME_STRING 0x071F
#define TIF_AUTHNAME_STRING     0x0720
#define JPG_SAVE_FORMAT         0x0721
#define CHEAD_HEADER_STRING     0x0722
#define PCD_PICNUM              0x0723
#define PNG_ALPHA_INDEX 0x0724 //XIX : ILint : the color in the palette at this index value (0-255) is considered transparent, -1 for no trasparent color
#define JPG_PROGRESSIVE         0x0725
#define VTF_COMP                0x0726


// DXTC definitions
#define DXTC_FORMAT      0x0705
#define DXT1             0x0706
#define DXT2             0x0707
#define DXT3             0x0708
#define DXT4             0x0709
#define DXT5             0x070A
#define DXT_NO_COMP      0x070B
#define KEEP_DXTC_DATA   0x070C
#define DXTC_DATA_FORMAT 0x070D
#define 3DC              0x070E
#define RXGB             0x070F
#define ATI1N            0x0710
#define DXT1A            0x0711  // Normally the same as IL_DXT1, except for nVidia Texture Tools.

// Environment map definitions
#define CUBEMAP_POSITIVEX 0x00000400
#define CUBEMAP_NEGATIVEX 0x00000800
#define CUBEMAP_POSITIVEY 0x00001000
#define CUBEMAP_NEGATIVEY 0x00002000
#define CUBEMAP_POSITIVEZ 0x00004000
#define CUBEMAP_NEGATIVEZ 0x00008000
#define SPHEREMAP         0x00010000


// Values
#define VERSION_NUM           0x0DE2
#define IMAGE_WIDTH           0x0DE4
#define IMAGE_HEIGHT          0x0DE5
#define IMAGE_DEPTH           0x0DE6
#define IMAGE_SIZE_OF_DATA    0x0DE7
#define IMAGE_BPP             0x0DE8
#define IMAGE_BYTES_PER_PIXEL 0x0DE8
#define IMAGE_BPP             0x0DE8
#define IMAGE_BITS_PER_PIXEL  0x0DE9
#define IMAGE_FORMAT          0x0DEA
#define IMAGE_TYPE            0x0DEB
#define PALETTE_TYPE          0x0DEC
#define PALETTE_SIZE          0x0DED
#define PALETTE_BPP           0x0DEE
#define PALETTE_NUM_COLS      0x0DEF
#define PALETTE_BASE_TYPE     0x0DF0
#define NUM_FACES             0x0DE1
#define NUM_IMAGES            0x0DF1
#define NUM_MIPMAPS           0x0DF2
#define NUM_LAYERS            0x0DF3
#define ACTIVE_IMAGE          0x0DF4
#define ACTIVE_MIPMAP         0x0DF5
#define ACTIVE_LAYER          0x0DF6
#define ACTIVE_FACE           0x0E00
#define CUR_IMAGE             0x0DF7
#define IMAGE_DURATION        0x0DF8
#define IMAGE_PLANESIZE       0x0DF9
#define IMAGE_BPC             0x0DFA
#define IMAGE_OFFX            0x0DFB
#define IMAGE_OFFY            0x0DFC
#define IMAGE_CUBEFLAGS       0x0DFD
#define IMAGE_ORIGIN          0x0DFE
#define IMAGE_CHANNELS        0x0DFF

#define SEEK_SET	0
#define SEEK_CUR	1
#define SEEK_END	2
#define EOF		-1


%rename("%(strip:[il])s") "";

// ImageLib Functions
 ILboolean  ilActiveFace(ILuint Number);
 ILboolean  ilActiveImage(ILuint Number);
 ILboolean  ilActiveLayer(ILuint Number);
 ILboolean  ilActiveMipmap(ILuint Number);
 ILboolean  ilApplyPal(ILconst_string FileName);
 ILboolean  ilApplyProfile(ILstring InProfile, ILstring OutProfile);
 void		 ilBindImage(ILuint Image);
 ILboolean  ilBlit(ILuint Source, ILint DestX, ILint DestY, ILint DestZ, ILuint SrcX, ILuint SrcY, ILuint SrcZ, ILuint Width, ILuint Height, ILuint Depth);
 ILboolean  ilClampNTSC(void);
 void		 ilClearColor(ILclampf Red, ILclampf Green, ILclampf Blue, ILclampf Alpha);
 ILboolean  ilClearImage(void);
 ILuint     ilCloneCurImage(void);
 ILubyte*	 ilCompressDXT(ILubyte *Data, ILuint Width, ILuint Height, ILuint Depth, ILenum DXTCFormat, ILuint *DXTCSize);
 ILboolean  ilCompressFunc(ILenum Mode);
 ILboolean  ilConvertImage(ILenum DestFormat, ILenum DestType);
 ILboolean  ilConvertPal(ILenum DestFormat);
 ILboolean  ilCopyImage(ILuint Src);
 ILuint     ilCopyPixels(ILuint XOff, ILuint YOff, ILuint ZOff, ILuint Width, ILuint Height, ILuint Depth, ILenum Format, ILenum Type, void *Data);
 ILuint     ilCreateSubImage(ILenum Type, ILuint Num);
 ILboolean  ilDefaultImage(void);
 void		 ilDeleteImage(const ILuint Num);
 void       ilDeleteImages(ILsizei Num, const ILuint *Images);
 ILenum	 ilDetermineType(ILconst_string FileName);
// ILenum	 ilDetermineTypeF(ILHANDLE File);
 ILenum	 ilDetermineTypeL(const void *Lump, ILuint Size);
 ILboolean  ilDisable(ILenum Mode);
 ILboolean  ilDxtcDataToImage(void);
 ILboolean  ilDxtcDataToSurface(void);
 ILboolean  ilEnable(ILenum Mode);
 void		 ilFlipSurfaceDxtcData(void);
 ILboolean  ilFormatFunc(ILenum Mode);
 void	     ilGenImages(ILsizei Num, ILuint *Images);
 ILuint	 ilGenImage(void);
 ILubyte*   ilGetAlpha(ILenum Type);
 ILboolean  ilGetBoolean(ILenum Mode);
 void       ilGetBooleanv(ILenum Mode, ILboolean *Param);
 ILubyte*   ilGetData(void);
 ILuint     ilGetDXTCData(void *Buffer, ILuint BufferSize, ILenum DXTCFormat);
 ILenum     ilGetError(void);
 ILint      ilGetInteger(ILenum Mode);
 void       ilGetIntegerv(ILenum Mode, ILint *Param);
 ILuint     ilGetLumpPos(void);
 ILubyte*   ilGetPalette(void);
 ILconst_string   ilGetString(ILenum StringName);
 void       ilHint(ILenum Target, ILenum Mode);
 ILboolean	 ilInvertSurfaceDxtcDataAlpha(void);
 void       ilInit(void);
 ILboolean  ilImageToDxtcData(ILenum Format);
 ILboolean  ilIsDisabled(ILenum Mode);
 ILboolean  ilIsEnabled(ILenum Mode);
 ILboolean  ilIsImage(ILuint Image);
 ILboolean  ilIsValid(ILenum Type, ILconst_string FileName);
// ILboolean  ilIsValidF(ILenum Type, ILHANDLE File);
 ILboolean  ilIsValidL(ILenum Type, void *Lump, ILuint Size);
 void       ilKeyColor(ILclampf Red, ILclampf Green, ILclampf Blue, ILclampf Alpha);
 ILboolean  ilLoad(ILenum Type, ILconst_string FileName);
// ILboolean  ilLoadF(ILenum Type, ILHANDLE File);
 ILboolean  ilLoadImage(ILconst_string FileName);
 ILboolean  ilLoadL(ILenum Type, const void *Lump, ILuint Size);
 ILboolean  ilLoadPal(ILconst_string FileName);
 void       ilModAlpha(ILdouble AlphaValue);
 ILboolean  ilOriginFunc(ILenum Mode);
 ILboolean  ilOverlayImage(ILuint Source, ILint XCoord, ILint YCoord, ILint ZCoord);
 void       ilPopAttrib(void);
 void       ilPushAttrib(ILuint Bits);
 void       ilRegisterFormat(ILenum Format);
// ILboolean  ilRegisterLoad(ILconst_string Ext, IL_LOADPROC Load);
 ILboolean  ilRegisterMipNum(ILuint Num);
 ILboolean  ilRegisterNumFaces(ILuint Num);
 ILboolean  ilRegisterNumImages(ILuint Num);
 void       ilRegisterOrigin(ILenum Origin);
 void       ilRegisterPal(void *Pal, ILuint Size, ILenum Type);
// ILboolean  ilRegisterSave(ILconst_string Ext, IL_SAVEPROC Save);
 void       ilRegisterType(ILenum Type);
 ILboolean  ilRemoveLoad(ILconst_string Ext);
 ILboolean  ilRemoveSave(ILconst_string Ext);
 void       ilResetMemory(void); // Deprecated
 void       ilResetRead(void);
 void       ilResetWrite(void);
 ILboolean  ilSave(ILenum Type, ILconst_string FileName);
// ILuint     ilSaveF(ILenum Type, ILHANDLE File);
 ILboolean  ilSaveImage(ILconst_string FileName);
 ILuint     ilSaveL(ILenum Type, void *Lump, ILuint Size);
 ILboolean  ilSavePal(ILconst_string FileName);
 ILboolean  ilSetAlpha(ILdouble AlphaValue);
 ILboolean  ilSetData(void *Data);
 ILboolean  ilSetDuration(ILuint Duration);
 void       ilSetInteger(ILenum Mode, ILint Param);
 void       ilSetMemory(mAlloc, mFree);
 void       ilSetPixels(ILint XOff, ILint YOff, ILint ZOff, ILuint Width, ILuint Height, ILuint Depth, ILenum Format, ILenum Type, void *Data);
// void       ilSetRead(fOpenRProc, fCloseRProc, fEofProc, fGetcProc, fReadProc, fSeekRProc, fTellRProc);
 void       ilSetString(ILenum Mode, const char *String);
// void       ilSetWrite(fOpenWProc, fCloseWProc, fPutcProc, fSeekWProc, fTellWProc, fWriteProc);
 void       ilShutDown(void);
 ILboolean  ilSurfaceToDxtcData(ILenum Format);
 ILboolean  ilTexImage(ILuint Width, ILuint Height, ILuint Depth, ILubyte NumChannels, ILenum Format, ILenum Type, void *Data);
 ILboolean  ilTexImageDxtc(ILint w, ILint h, ILint d, ILenum DxtFormat, const ILubyte* data);
 ILenum     ilTypeFromExt(ILconst_string FileName);
 ILboolean  ilTypeFunc(ILenum Mode);
 ILboolean  ilLoadData(ILconst_string FileName, ILuint Width, ILuint Height, ILuint Depth, ILubyte Bpp);
// ILboolean  ilLoadDataF(ILHANDLE File, ILuint Width, ILuint Height, ILuint Depth, ILubyte Bpp);
 ILboolean  ilLoadDataL(void *Lump, ILuint Size, ILuint Width, ILuint Height, ILuint Depth, ILubyte Bpp);
 ILboolean  ilSaveData(ILconst_string FileName);

