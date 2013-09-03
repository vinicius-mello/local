//constant float SAMPLING_BASE_INTERVAL_RCP = 200.0f;
constant float SAMPLING_BASE_INTERVAL_RCP = 4.0f;
constant float SAMPLING_BASE_INTERVAL_SLICE_RCP = 105.0f;

/**
 * Performs regular DVR compositing. Expects the current voxels color
 * and the intermediate result. Returns the result after compositing.
 *
 */
float4 compositeDVR(float4 curResult, float4 *color, float t, float *tDepth, float samplingStepSize_) {
    float4 result = curResult;

    // apply opacity correction to accomodate for variable sampling intervals
    (*color).w = 1.0f - pow(1.0f - (*color).w, samplingStepSize_ * SAMPLING_BASE_INTERVAL_RCP);

    result.xyz = result.xyz + (1.0f - result.w) * (*color).w * (*color).xyz;
    result.w = result.w + (1.0f -result.w) * (*color).w;
    // save first hit ray parameter for depth value calculation
    if ((*tDepth) < 0.0f)
        (*tDepth) = t;
    return result;
}
