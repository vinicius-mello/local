//
// Bui Tuong Phong shading model (per-pixel) 
// 
// by 
// Massimiliano Corsini
// Visual Computing Lab (2006)
// 

attribute float attr;
varying vec3 normal;
varying vec3 vpos;
varying float atr;

void main()
{	
	// vertex normal
	normal = normalize(gl_NormalMatrix * gl_Normal);
	
	// vertex position
	vpos = vec3(gl_ModelViewMatrix * gl_Vertex);
  
	atr=attr;

	// vertex position
	gl_Position = ftransform();
}
