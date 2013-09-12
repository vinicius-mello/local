/*Kernel*/

float f_cube(float3 w) {
    w=2.0f*w-1.0f;
    float v=w.x*w.x+w.y*w.y+w.z*w.z-w.x*w.x*w.x*w.x-w.y*w.y*w.y*w.y-w.z*w.z*w.z*w.z;
    float max_v=0.749173;
    float min_v=0.0;
    return (v-min_v)/(max_v-min_v);
}

float3 f_cube_grad(float3 p) {
    p=2.0f*p-1.0f;
    float3 grad=(float3)(
        2.0f*p.x-4.0f*p.x*p.x*p.x,
        2.0f*p.y-4.0f*p.y*p.y*p.y,
        2.0f*p.z-4.0f*p.z*p.z*p.z
    );
    return 1.0f/0.749173f*grad;
}

__kernel void kern(__read_only image2d_t entr, __read_only image2d_t exit, __write_only image2d_t tex, __read_only image1d_t transferFunc_, __global float * data, int width, int height, int depth, float vx, float vy, float vz){
    int x = get_global_id(0);
    int y = get_global_id(1);

    int2 coords = (int2)(x,y);
    float2 tcoords = (float2)(x,y)/512.0f;

    float4 result = (float4)(0.0f,0.0f,0.0f,0.0f);

    const float Samplings = 100.0f;
    const float k         = 3.0f;
    float numberOfSkippedSamples;

    float3 entryPoints_ = read_imagef(entr, samplersrc, tcoords).xyz; //first
    float3 exitPoints_ = read_imagef(exit, samplersrc, tcoords).xyz; //last

    float t     = 0.0f;
    float tIncr = 0.0f;
    float tEnd  = 1.0f;
    float3 datasetDimensions_ = (float3)(1.0f, 1.0f, 1.0f); // the dataset's resolution, e.g. [ 256.0, 128.0, 128.0]
    float3 rayDirection;

    const_to c_to;
    c_to.const_to_z_w_1 = 1.0f;
    c_to.const_to_z_w_2 = 1.0f;
    c_to.const_to_z_e_1 = 1.0f;
    c_to.const_to_z_e_2 = 1.0f;

    //Light
    l_source lightSource_;
    lightSource_.position_ = (float3)(0.0f, 0.0f, 4.0f*0.705f);
    lightSource_.ambientColor_ = (float3)(0.4f, 0.4f, 0.4f);    // ambient color (r,g,b)
    lightSource_.diffuseColor_ = (float3)(0.9f, 0.9f, 0.9f);    // diffuse color (r,g,b)
    lightSource_.specularColor_ = (float3)(0.3f, 0.3f, 0.3f);   // specular color (r,g,b)
    lightSource_.attenuation_ = (float3)(1.0f, 0.0f, 0.0f);     // attenuation (constant, linear, quadratic)

    //Material
    float3 ka = (float3)(0.1f, 0.1f, 0.1f);
    float3 kd = (float3)(0.9f, 0.9f, 0.9f);
    float3 ks = (float3)(0.1f, 0.1f, 0.1f);
    float shininess_ = 2.0f;

    float3 cameraPosition_ = (float3)(vx, vy, vz);

    raySetup(entryPoints_, exitPoints_, datasetDimensions_, &rayDirection, &tIncr, &tEnd, Samplings);
    if(tEnd<tIncr) {
        result=(float4)(0.0f,0.0f,0.0f,0.0f);//background
        write_imagef(tex, coords, result);
        return;
    }

    RC_BEGIN_LOOP{
        float3 gradient = (float3)(0.0f, 0.0f, 0.0f);
        float value = 0.0f;
        float3 samplePos = entryPoints_ + t * rayDirection;

        // calculate gradients
        //RC_CALC_GRADIENTS(data, samplePos, width, height, depth, value, gradient);
        value=f_cube(samplePos);
        gradient=f_cube_grad(samplePos);
        // apply classification
        float4 color = RC_APPLY_CLASSIFICATION(transferFunc_, value, gradient);
        //float4 color=(float4)(0.3f,0.4f,0.1f,0.0f);
        // apply shading
        color.xyz = color.xyz*RC_APPLY_SHADING(samplePos, gradient, ka, kd, ks, lightSource_, cameraPosition_, shininess_);

        /*
        if(value<0.7f && value>0.65f) {
            result=color;
            finished=true;
        }
        */

        // compositing

        if(color.w > 0.0f){
            RC_BEGIN_COMPOSITING
            //result = RC_APPLY_COMPOSITING(result, color, t, tDepth, Samplings);
            result = RC_APPLY_COMPOSITING(result, color, t, tDepth,tIncr);
            RC_END_COMPOSITING
        }

    } RC_END_LOOP(result);

    write_imagef(tex, coords, result);
};
