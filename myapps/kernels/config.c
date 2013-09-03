const sampler_t samplersrc = CLK_NORMALIZED_COORDS_TRUE | CLK_ADDRESS_REPEAT | CLK_FILTER_LINEAR;

typedef struct CONST_TO {
    float const_to_z_w_1;
    float const_to_z_w_2;
    float const_to_z_e_1;
    float const_to_z_e_2;
} const_to;

typedef struct LIGHT_SOURCE {
    float3 position_;        // light position in world space
    float3 ambientColor_;    // ambient color (r,g,b)
    float3 diffuseColor_;    // diffuse color (r,g,b)
    float3 specularColor_;   // specular color (r,g,b)
    float3 attenuation_;     // attenuation (constant, linear, quadratic)
} l_source;

typedef struct VOLUME_STRUCT {
    //sampler3D volume_;              // the actual dataset

    float3 datasetDimensions_;        // the dataset's resolution, e.g. [ 256.0, 128.0, 128.0]
    float3 datasetDimensionsRCP_;

    float3 datasetSpacing_;           // set dataset's voxel size, e.g. [ 2.0, 0.5, 1.0]
    float3 datasetSpacingRCP_;

    float3 volumeCubeSize_;          // the volume's size in physical coordinates, e.g. [ 1.0, 0.5, 0.5]
    float3 volumeCubeSizeRCP_;

    float3 volumeOffset_;              // see VolumeHandle::getOffset()
    float3 volumeTextureTranslation_;  // translation for scaling of texture coordinates when performing slicing

    float3 volumeBorderOffset_;    // the offset to add to texCoords based on border of faces connected to [0.0,0.0,0.0]
    float3 volumeBorderScaling_;  // the scaling to multiply to texCoords based on border of faces connected to [1.0,1.0,1.0]
    bool volumeHasBorder_;      // true if volume has border

    int bitDepth_;                  // the volume's bit depth
    float bitDepthScale_;           // scaling factor that must be applied for normalizing the fetched texture value.
                                    // currently just used for 12 bit volumes, which actually use only 12 out of 16 bits.

    float rwmScale_;                // RealWorldMapping slope
    float rwmOffset_;               // RealWorldMapping intercept

    int numChannels_;

    //mat4 volumeTransformation_;     // dataset transformation matrix (see Volume)
    //mat4 volumeTransformationINV_;  // inverse dataset transformation matrix

    float3 cameraPositionOBJ_;        // camera position in volume object coordinates (see mod_shading.frag)
    float3 lightPositionOBJ_;         // light position in volume object coordinates (see mod_shading.frag)
} v_struct;

#define EARLY_RAY_TERMINATION_OPACITY 1.0f

// Just wrap the usual functions
#define RC_EARLY_RAY_TERMINATION(opacity, maxOpacity, finished) \
    finished = earlyRayTermination(opacity, maxOpacity)

//float getDepthValue(float t, float tEnd, float3 entryPointsDepth, float3 exitPointsDepth, const_to c_to);
//gl_FragDepth = getDepthValue(t, tEnd, entryPointsDepth, entryParameters, exitPointsDepth, exitParameters);
#define WRITE_DEPTH_VALUE(tDepth, tEnd, entryPoints_, exitPoints_, c_to) \
    float fragDepth = getDepthValueB(tDepth, tEnd, entryPoints_, exitPoints_, c_to);

// Use two nested loops, should be supported everywhere
#define RC_BEGIN_LOOP_FOR                                   \
    for (int loop0=0; !finished && loop0<255; loop0++) {      \
        for (int loop1=0; !finished && loop1<255; loop1++) {
#define RC_END_LOOP_BRACES } }

#define RC_BEGIN_LOOP                                         \
    float tDepth = -1.0f;                                      \
    bool finished = false;                                    \
    RC_BEGIN_LOOP_FOR

#ifdef ADAPTIVE_SAMPLING
    #define RC_END_LOOP(result)                                        \
                RC_EARLY_RAY_TERMINATION(result.w, EARLY_RAY_TERMINATION_OPACITY, finished);    \
                t += (tIncr * convert_float(numberOfSkippedSamples));          \
                finished = finished || (t > tEnd);                     \
        RC_END_LOOP_BRACES                                             \
        WRITE_DEPTH_VALUE(tDepth, tEnd, entryPoints_, exitPoints_, c_to);
#else
    #define RC_END_LOOP(result)                                        \
                RC_EARLY_RAY_TERMINATION(result.w, EARLY_RAY_TERMINATION_OPACITY, finished);    \
                t += tIncr;                                            \
                finished = finished || (t > tEnd);                     \
        RC_END_LOOP_BRACES                                             \
        WRITE_DEPTH_VALUE(tDepth, tEnd, entryPoints_, exitPoints_, c_to);
#endif

#ifdef ADAPTIVE_SAMPLING
    #define RC_BEGIN_COMPOSITING \
        for (int i=0; i<numberOfSkippedSamples; i++) {
#else
    #define RC_BEGIN_COMPOSITING
#endif

#ifdef ADAPTIVE_SAMPLING
    #define RC_END_COMPOSITING \
        }
#else
    #define RC_END_COMPOSITING
#endif

// configure gradient calculation
#define RC_CALC_GRADIENTS(data, samplePos, width, height, depth, value, gradient)    \
    evaldx(data, samplePos, width, height, depth, &value, &gradient)

// configure classification
#define RC_APPLY_CLASSIFICATION(transferFunc_, value, gradient) \
    applyTF(transferFunc_, value, gradient)

// configure shading mode
#define RC_APPLY_SHADING(samplePos, gradient, ka, kd, ks, lightSource_, cameraPosition_, shininess_) \
    phongShading(samplePos, gradient, ka, kd, ks, lightSource_, cameraPosition_, shininess_)

// configure compositing mode
#define RC_APPLY_COMPOSITING(result, color, t, tDepth_, Samplings) \
    compositeDVR(result, &color, t, &tDepth_, Samplings)
