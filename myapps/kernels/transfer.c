float4 applyTF(image1d_t transfer, float intensity, float3 gradient) {
    return read_imagef(transfer, samplersrc, intensity);
}