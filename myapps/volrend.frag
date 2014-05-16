  //precision highp float;

  varying vec2 texCoord;

  uniform sampler2D front;
  uniform sampler2D back;



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

  float transfer(float v, float level, float sigma2) {
    float delta=v-level;
    //return 1.0/(1.0+delta*delta/sigma2);
    return exp(-delta*delta/sigma2);
  }

  void main(void) {
	  float step=1.0/256.0;
  	float t=0.0;

    vec4 backgroundColor=vec4(1.0,0.6,0.7,1.0);

    vec3 entry=texture2D(front,texCoord).xyz;
    vec3 exit=texture2D(back,texCoord).xyz;
    vec4 result=vec4(0.0);
    
    if(entry!=exit) {

    vec3 direction=exit-entry;  
    float len=length(direction);
    direction=1.0/len*direction;
    float acu_tau=1.0;
    bool finished=false;
    for (int loop=0; loop<50000; loop++) {
      vec3 p=entry+t*direction;
      float v=f(p);
      //float v=sampleAs3DTexture(volume, p, 16.0).a;
      float tau=1.0-transfer(v,.6,.01);
      result=result+(1.0-tau)*vec4(1.0,0.0,0.0,0.0)*acu_tau*step;
      acu_tau=acu_tau*pow(tau+0.000001,step);
      t=t+step;
      if(acu_tau<0.0001 || t>=len) exit;    
    }
    result.a=1.0-acu_tau;
    }
    gl_FragColor = (1.0-result.a)*backgroundColor+(result.a)*result;

  }

/*
  void main(void) {
    vec3 entry=texture2D(front,texCoord).xyz;
    vec3 exit=texture2D(back,texCoord).xyz;

    gl_FragColor=vec4(0.5*(entry+exit),1.0);
  }
*/