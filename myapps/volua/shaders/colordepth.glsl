  //precision highp float;

  varying vec2 texCoord;

  uniform sampler2D color;
  uniform sampler2D depth;
  uniform sampler2D background;

  void main(void) {
    vec4 c=texture2D(color,texCoord);
    gl_FragColor = mix(
      texture2D(background,texCoord),c,c.a);
    gl_FragDepth = texture2D(depth,texCoord).x;
  }
