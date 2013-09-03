float getAttenuation(float d, l_source lightSource_) {
    float att = 1.0f / (lightSource_.attenuation_.x +
                       lightSource_.attenuation_.y * d +
                       lightSource_.attenuation_.z * d * d);
    return min(att, 1.0f);
}

float3 getAmbientTerm(float3 ka, l_source lightSource_) {
    return ka * lightSource_.ambientColor_;
}

float3 getDiffuseTerm(float3 kd, float3 N, float3 L, l_source lightSource_) {
    float NdotL = max(dot(N, L), 0.0f);
    return kd * lightSource_.diffuseColor_ * NdotL;
}

float3 getLerpDiffuseTerm(float3 kd, float3 N, float3 L, l_source lightSource_) {
    float alpha = 0.5f;
    float3 NV = mix(N, L, alpha);
    float NVdotL = max(dot(NV, L), 0.0f);
    return kd * lightSource_.diffuseColor_ * NVdotL;
}

float3 getSpecularTerm(float3 ks, float3 N, float3 L, float3 V, float alpha, l_source lightSource_) {
    float3 H = normalize(V + L);
    float NdotH = pow(max(dot(N, H), 0.0f), alpha);
    return ks * lightSource_.specularColor_ * NdotH;
}

float3 phongShading(float3 pos, float3 normal, float3 ka, float3 kd, float3 ks, l_source lightSource_, float3 cameraPosition_, float shininess_) {
    float3 N = normalize(normal);
    float3 L = lightSource_.position_ - pos;
    float3 V = normalize(cameraPosition_ - pos);

    // get light source distance for attenuation and normalize light vector
    float d = length(L);
    L /= d;

    float3 shadedColor = (float3)(0.0f, 0.0f, 0.0f);
    shadedColor += getAmbientTerm(ka, lightSource_);
    shadedColor += getDiffuseTerm(kd, N, L, lightSource_);
    shadedColor += getSpecularTerm(ks, N, L, V, shininess_, lightSource_);
    return shadedColor;
}