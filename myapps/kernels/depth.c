float calculateDepthValue(float t, float entryPointsDepth, float exitPointsDepth, const_to c_to) {
    // assign front value given in windows coordinates
    float zw_front = entryPointsDepth;
    // and convert it into eye coordinates
    float ze_front = 1.0f/((zw_front - c_to.const_to_z_e_1)*c_to.const_to_z_e_2);

    // assign back value given in windows coordinates
    float zw_back = exitPointsDepth;
    // and convert it into eye coordinates
    float ze_back = 1.0f/((zw_back - c_to.const_to_z_e_1)*c_to.const_to_z_e_2);

    // interpolate in eye coordinates
    float ze_current = ze_front + t*(ze_back-ze_front);

    // convert back to window coordinates
    float zw_current = (1.0f/ze_current)*c_to.const_to_z_w_1 + c_to.const_to_z_w_2;

    return zw_current;
}

float getDepthValueA(float t, float tEnd, float entryPointsDepth, float exitPointsDepth, const_to c_to) {
    if (t >= 0.0f)
        return calculateDepthValue(t/tEnd, entryPointsDepth, exitPointsDepth, c_to);
    else
        return 1.0f;
}

float getDepthValueB(float t, float tEnd, float3 entryPointsDepth, float3 exitPointsDepth, const_to c_to) {
    if (t >= 0.0f)
        return calculateDepthValue(t/tEnd, entryPointsDepth.z, exitPointsDepth.z, c_to);
    else
        return 1.0f;
}    