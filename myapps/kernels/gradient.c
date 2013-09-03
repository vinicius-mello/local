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

void evaldx(__global float* data_, float3 samplePos, size_t width_, size_t height_, size_t depth_, float *v, float3 *vd){
    float tx = samplePos.x;
    float ty = samplePos.y;
    float tz = samplePos.z;

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
