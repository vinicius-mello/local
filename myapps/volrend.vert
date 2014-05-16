//attribute vec2 aCorner;
varying vec2 texCoord;

void main()
{
    texCoord = 0.5*(gl_Vertex.xy+1.0);
    gl_Position = gl_Vertex;
}
