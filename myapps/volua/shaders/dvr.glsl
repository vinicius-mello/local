  //precision highp float;

  varying vec2 texCoord;

  uniform sampler2D front;
  uniform sampler2D back;
  uniform sampler2D frontDepth;
  uniform sampler2D backDepth;
  uniform sampler1D transfer;
  uniform sampler3D volume;
  uniform float Step;

  float f(vec3 p) {
    p = 2.0 * p - 1.0;
    //return (p.x*p.x+p.y*p.y+p.z*p.z)/3.0;
    float px2=p.x*p.x;
    float py2=p.y*p.y;
    float pz2=p.z*p.z;
    float v = px2 * (1.0-px2) + py2 * (1.0-py2) + pz2 * (1.0-pz2);
    float max_v = 0.749173;
    float min_v = 0.0;
    return (v-min_v)/(max_v-min_v);
  }


  void main(void) {
  	float t=0.0;
    float tdepth=-1.0;

    //vec4 backgroundColor=vec4(1.0,0.6,0.7,1.0);

    vec3 entry=texture2D(front,texCoord).xyz;
    vec3 exit=texture2D(back,texCoord).xyz;
    float entryDepth=texture2D(frontDepth,texCoord).z;
    float exitDepth=texture2D(backDepth,texCoord).z;
    
    vec4 result=vec4(0.0);
    vec3 direction=exit-entry;  
    float len=length(direction);
    direction=1.0/len*direction;
    
    if(len>0.0) {
      float acu_tau=1.0;
      bool finished=false;
      for (int loop=0; loop<50000; loop++) {
        vec3 p=entry+t*direction;
        float v=texture3D(volume,p).r;
        vec4 color=texture1D(transfer,v);
        float tau=1.0-color.a;
        //float tau=1.0-transferf(v,0.6,0.01);
        result=result+(1.0-tau)*(color)*acu_tau*Step;
        acu_tau=acu_tau*pow(tau+0.000001,Step);
        t=t+Step;
        if(tdepth<0.0 && acu_tau<0.9) tdepth=t;
        if(acu_tau<0.001 || t>=len) exit;
      }
      result.a=1.0-acu_tau;
    }
  
    //gl_FragColor = mix(backgroundColor,result,result.a);
    gl_FragColor = result;
    if(tdepth>0.0)
      gl_FragDepth = mix(entryDepth,exitDepth,tdepth/len);
    else
      gl_FragDepth = 1.0;
  }

