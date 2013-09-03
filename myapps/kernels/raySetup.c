/***
 * Calculates the direction of the ray and returns the number
 * of steps and the direction.
 ***/
void raySetup(float3 first, float3 last, float3 dimension, float3 *rayDirection, float *tIncr, float *tEnd, float samplingRate_) {
    // calculate ray parameters
    *rayDirection = last - first;
    *tEnd = length(*rayDirection);
    *rayDirection = normalize(*rayDirection);
    //*tIncr = 1.0f/(samplingRate_*length(*rayDirection));
    *tIncr = 1.0f/(samplingRate_);
    #ifdef ADAPTIVE_SAMPLING
        directionWithStepSize = *rayDirection * *tIncr;
    #endif
}

/***
 * Applies early ray termination. The current opacity is compared to
 * the maximum opacity. In case it is greater, the opacity is set to
 * 1.0 and true is returned, otherwise false is returned.
 ***/
bool earlyRayTermination(float opacity, float maxOpacity) {
    if (opacity >= maxOpacity) {
        opacity = 1.0f;
        return true;
    } else {
        return false;
    }
}
