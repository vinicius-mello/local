/*Kernel*/
__kernel void kern(__read_only image2d_t entr,
                   __read_only image2d_t exit, 
                   __write_only image2d_t tex,
                   __read_only image1d_t transferFunc_,
                   __global float * data, int width, int height, int depth,
				   float ka_r, float ka_g, float ka_b,
				   float kd_r, float kd_g, float kd_b,
				   float ks_r, float ks_g, float ks_b,
				   float shininess_
				   )
{
	//Material
	float3 ka = (float3)(ka_r, ka_g, ka_b); 
	float3 kd = (float3)(kd_r, kd_g, kd_b); 
	float3 ks = (float3)(ks_r, ks_g, ks_b); 
	/*
	ka = (float3)(0.1f, 0.1f, 0.1f);
	kd = (float3)(0.4f, 0.4f, 0.4f);
	ks = (float3)(1.0f, 1.0f, 1.0f);
	float shininess_ = 2.0f;*/

    int x = get_global_id(0);
    int y = get_global_id(1);

    int2 coords = (int2)(x,y);
    float2 tcoords = (float2)(x,y)/512.0f;

    const float Samplings = 100.0f;
    const float k         = 3.0f;
    float numberOfSkippedSamples;

    float3 entrPoints_ = read_imagef(entr, samplersrc, tcoords).xyz; //first
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
    
    l_source lightSource_;
    lightSource_.position_ = (float3)(2.0f, 2.0f, 2.0f);
    lightSource_.ambientColor_ = (float3)(0.4f, 0.4f, 0.4f);   // ambient color (r,g,b)
    lightSource_.diffuseColor_ = (float3)(0.9f, 0.9f, 0.9f);     // diffuse color (r,g,b)
    lightSource_.specularColor_ = (float3)(0.3f, 0.3f, 0.3f);   // specular color (r,g,b)
    lightSource_.attenuation_ = (float3)(1.0f, 0.0f, 0.0f);      // attenuation (constant, linear, quadratic)
	    
    float3 cameraPosition_ = (float3)(0.0f, 0.0f, 2.0f);    

    float4 result = (float4)(0.0f,0.0f,0.0f,0.0f);
    
    raySetup(entrPoints_, exitPoints_, datasetDimensions_, &rayDirection, &tIncr, &tEnd, Samplings);
	
	if(tEnd < tIncr){
		result = (float4)(0.0f,0.0f,0.0f,0.0f);
		write_imagef(tex, coords, result);
		return;
	}
    
    RC_BEGIN_LOOP{
        float3 gradient = (float3)(0.0f, 0.0f, 0.0f);
        float value = 0.0f;
        float3 samplePos = entrPoints_ + t * rayDirection;
        
        // calculate gradients
        RC_CALC_GRADIENTS(data, samplePos, width, height, depth, value, gradient);
        
        // apply classification
        float4 color = RC_APPLY_CLASSIFICATION(transferFunc_, value, gradient);
        
        // apply shading
        color.xyz = color.xyz * RC_APPLY_SHADING(samplePos, gradient, ka, kd, ks, lightSource_, cameraPosition_, shininess_);
        
        // compositing
        if(color.w > 0.0f){
            RC_BEGIN_COMPOSITING
            result = RC_APPLY_COMPOSITING(result, color, t, tDepth, tIncr);
            RC_END_COMPOSITING
        }
    }RC_END_LOOP(result);
    
    write_imagef(tex, coords, result);
};