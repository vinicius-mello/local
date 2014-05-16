  //precision highp float;

  varying vec2 texCoord;

  uniform vec3 colortop;
  uniform vec3 colorbottom;

  void main(void) {
    vec3 c=mix(colortop,colorbottom,texCoord.y);
    gl_FragColor =vec4(c,0.0);
    gl_FragDepth=0.0; 
  }
