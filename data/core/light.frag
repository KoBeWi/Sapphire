#version 110

uniform sampler2D in_Texture;

varying vec2 var_TexCoord;
varying vec4 var_Color;

uniform float in_Value;

void main()
{
  vec4 color = texture2D(in_Texture, var_TexCoord);
  gl_FragColor = vec4(vec3(max(color.r,in_Value)),color.a);
}
