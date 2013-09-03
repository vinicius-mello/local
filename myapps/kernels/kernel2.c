const sampler_t samplersrc = CLK_NORMALIZED_COORDS_TRUE | CLK_ADDRESS_REPEAT | CLK_FILTER_LINEAR;

size_t offset(size_t k, size_t i, size_t j, size_t width_, size_t height_) {
    return k*width_*height_+i*width_+j;
}

float get(__global float* data_, size_t k, size_t i, size_t j, size_t width_, size_t height_){
    return data_[offset(k,i,j,width_,height_)];
}

float set(__global float* data_, size_t k, size_t i, size_t j, float v, size_t width_, size_t height_) {
    data_[offset(k,i,j,width_,height_)]=v;
    return v;
}

float bspline(float t){
    t = fabs(t);
    float a = 2.0f - t;

    if (t < 1.0f)
        return 2.0f/3.0f - 0.5f*t*t*a;
    else if (t < 2.0f)
        return a*a*a / 6.0f;
    else
        return 0.0f;
}

float bsplined(float t){
    float c=sign(t); //sgn
    t = fabs(t);
    float a = 2.0f - t;

    if (t < 1.0f)
        return c*t*(3.0f*t-4) / 2.0f;
    else if (t < 2.0f)
        return -c*a*a / 2.0f;
    else
        return 0.0f;
}

void evaldx(__global float* data_, float tx, float ty, float tz, size_t width_, size_t height_, size_t depth_, float *v, float3 *vd){
    float ttx=tx*(width_-1);
    float bx=floor(ttx);
    float deltax=ttx-bx;
    int bix=(int)bx;

    float tty=ty*(height_-1);
    float by=floor(tty);
    float deltay=tty-by;
    int biy=(int)by;

    float ttz=tz*(depth_-1);
    float bz=floor(ttz);
    float deltaz=ttz-bz;
    int biz=(int)bz;

    for(int k=-1;k<=2;++k) {
        int indexz=biz+k;
        if(indexz<0) indexz=-indexz;
        else if(indexz>=depth_) indexz=2*depth_-indexz-2;
        for(int j=-1;j<=2;++j) {
            int indexy=biy+j;
            if(indexy<0) indexy=-indexy;
            else if(indexy>=height_) indexy=2*height_-indexy-2;
            for(int i=-1;i<=2;++i) {
                int indexx=bix+i;
                if(indexx<0) indexx=-indexx;
                else if(indexx>=width_) indexx=2*width_-indexx-2;
                (*v)+=get(data_, indexz, indexx, indexy, width_, height_)*bspline(deltax-(float)i)*bspline(deltay-(float)j)*bspline(deltaz-(float)k);
                                
                (*vd).x+=get(data_, indexz, indexx, indexy, width_, height_)*bsplined(deltax-(float)i)*bspline(deltay-(float)j)*bspline(deltaz-(float)k);
                (*vd).y+=get(data_, indexz, indexx, indexy, width_, height_)*bspline(deltax-(float)i)*bsplined(deltay-(float)j)*bspline(deltaz-(float)k);
                (*vd).z+=get(data_, indexz, indexx, indexy, width_, height_)*bspline(deltax-(float)i)*bspline(deltay-(float)j)*bsplined(deltaz-(float)k);
            }
        }
    }
}

float eval(__global float* data_, float tx, float ty, float tz, size_t width_, size_t height_, size_t depth_){
    float ttx=tx*(width_-1);
    float bx=floor(ttx);
    float deltax=ttx-bx;
    int bix=(int)bx;

    float tty=ty*(height_-1);
    float by=floor(tty);
    float deltay=tty-by;
    int biy=(int)by;

    float ttz=tz*(depth_-1);
    float bz=floor(ttz);
    float deltaz=ttz-bz;
    int biz=(int)bz;

    float v=0.0f;
    for(int k=-1;k<=2;++k) {
        int indexz=biz+k;
        if(indexz<0) indexz=-indexz;
        else if(indexz>=depth_) indexz=2*depth_-indexz-2;
        for(int j=-1;j<=2;++j) {
            int indexy=biy+j;
            if(indexy<0) indexy=-indexy;
            else if(indexy>=height_) indexy=2*height_-indexy-2;
            for(int i=-1;i<=2;++i) {
                int indexx=bix+i;
                if(indexx<0) indexx=-indexx;
                else if(indexx>=width_) indexx=2*width_-indexx-2;
                v+=get(data_, indexz, indexx, indexy, width_, height_)*bspline(deltax-(float)i)*bspline(deltay-(float)j)*bspline(deltaz-(float)k);
            }
        }
    }
    return v;
}

float3 evald(__global float* data_, float tx, float ty, float tz, size_t width_, size_t height_, size_t depth_){
    float ttx=tx*(width_-1);
    float bx=floor(ttx);
    float deltax=ttx-bx;
    int bix=(int)bx;

    float tty=ty*(height_-1);
    float by=floor(tty);
    float deltay=tty-by;
    int biy=(int)by;

    float ttz=tz*(depth_-1);
    float bz=floor(ttz);
    float deltaz=ttz-bz;
    int biz=(int)bz;

    float3 v=0.0f;
    for(int k=-1;k<=2;++k) {
        int indexz=biz+k;
        if(indexz<0) indexz=-indexz;
        else if(indexz>=depth_) indexz=2*depth_-indexz-2;
        for(int j=-1;j<=2;++j) {
            int indexy=biy+j;
            if(indexy<0) indexy=-indexy;
            else if(indexy>=height_) indexy=2*height_-indexy-2;
            for(int i=-1;i<=2;++i) {
                int indexx=bix+i;
                if(indexx<0) indexx=-indexx;
                else if(indexx>=width_) indexx=2*width_-indexx-2;
                v.x+=get(data_, indexz, indexx, indexy, width_, height_)*bsplined(deltax-(float)i)*bspline(deltay-(float)j)*bspline(deltaz-(float)k);
                v.y+=get(data_, indexz, indexx, indexy, width_, height_)*bspline(deltax-(float)i)*bsplined(deltay-(float)j)*bspline(deltaz-(float)k);
                v.z+=get(data_, indexz, indexx, indexy, width_, height_)*bspline(deltax-(float)i)*bspline(deltay-(float)j)*bsplined(deltaz-(float)k);
            }
        }
    }
    return v;
}

float f_cube(float3 w) {
    float v=w.x*w.x+w.y*w.y+w.z*w.z-w.x*w.x*w.x*w.x-w.y*w.y*w.y*w.y-w.z*w.z*w.z*w.z;
    float max_v=0.749173;
    float min_v=0.0;
    return (v-min_v)/(max_v-min_v);
}

float3 f_cube_grad(float3 p) {
    float3 grad=(float3)(
        2.0f*p.x-4.0f*p.x*p.x*p.x,
        2.0f*p.y-4.0f*p.y*p.y*p.y,
        2.0f*p.z-4.0f*p.z*p.z*p.z
    );
    return 1.0f/0.749173f*grad;
}

__kernel void kern(
    __read_only image2d_t entry,
    __read_only image2d_t exit,
    __write_only image2d_t tex,
    __read_only image1d_t transfer,
    __global float * data,
    int width,
    int height,
    int depth
    )
{
    int x = get_global_id(0);
    int y = get_global_id(1);

    int2 coords = (int2)(x,y);
    float2 tcoords = (float2)(x,y)/512.0f;

    const float Samplings = 100.0f;
    const float k = 3.0f;

    float3 a=read_imagef(entry,samplersrc,tcoords).xyz;
    float3 b=read_imagef(exit,samplersrc,tcoords).xyz;

    float3 dir=b-a;
    int steps = (int)(floor(Samplings * length(dir)));
    float3 diff1 = dir / (float)(steps);
    dir=dir*(1.0f/length(dir));
    float delta=1.0f/Samplings;

    float4 result = (float4)(0.0,0.0,0.0,0.0);
    
    //Variables
    l_source lightSource_;
    lightSource_.position_ = (float3)(2.0f, 2.0f, 2.0f);
    lightSource_.ambientColor_ = (float3)(2.0f, 1.0f, 1.0f);    // ambient color (r,g,b)
    lightSource_.diffuseColor_ = (float3)(1.0f, 2.0f, 1.0f);    // diffuse color (r,g,b)
    lightSource_.specularColor_ = (float3)(1.0f, 1.0f, 2.0f);   // specular color (r,g,b)
    //lightSource_.attenuation_ = (float3)(1.0f, 1.0f, 1.0f);     // attenuation (constant, linear, quadratic)
    
    float3 cameraPosition_ = (float3)(0.0f, 0.0f, 2.0f);
    float3 normal = (float3)(0.0f, 0.0f, 0.0f);
    float shininess_ = 2.0f;
    float tDepth_ = -1.0f;
    float t = 0.0f;
    float tIncr = 0.0f;
    float tEnd  = 1.0f;
    float3 dimension = (float3)(1.0f, 1.0f, 1.0f);
    float3 rayDirection;
    
    //raySetup(float3 first, float3 last, float3 dimension, float3 *rayDirection, float *tIncr, float *tEnd, float samplingRate_);
    raySetup(a, b, dimension, &rayDirection, &tIncr, &tEnd, Samplings);
    
    for (int i=0; i<steps; i++) {
        float3 p=a;
        
        float valuex = 0.0f;
        float3 valued = 0.0f;
        
        //Calculate gradients
        evaldx(data, p.x, p.y, p.z, width, height, depth, &valuex, &valued);
        
        float len = length(valued);
        normal = valued/len;
        
        //Apply classification
        float4 color=read_imagef(transfer,samplersrc,valuex);
        
        float3 ka = (float3)(0.1f, 0.1f, 0.1f);
        float3 kd = (float3)(0.4f, 0.4f, 0.4f);
        float3 ks = (float3)(1.0f, 1.0f, 1.0f);
        
        //Apply Shading
        color.xyz = color.xyz * phongShading(p, valued, ka, kd, ks, lightSource_, cameraPosition_, shininess_);
       
        //Apply compositing, if opacity greater zero
        if(color.w > 0.0f){
            result = compositeDVR(result, &color, t, &tDepth_, Samplings);
        }
        
        if(result.w<0.95f) {
            i=steps;
            //result.w=0.0f;
        }
        
        t += tIncr;
        a+=diff1;
    }

    write_imagef(tex, coords, result);

};