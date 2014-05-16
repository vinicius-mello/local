
varying vec2 tcoord;

void main()
{
	tcoord=0.5*(gl_Vertex.xy+1.0);

    // vertex position
    gl_Position = gl_Vertex;
}
