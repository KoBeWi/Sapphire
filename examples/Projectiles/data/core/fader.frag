#version 110

uniform sampler2D in_Texture;

varying vec2 var_TexCoord;
varying vec4 var_Color;

uniform bool in_Solid;
uniform float in_Value;

void main()
{
  vec4 color = texture2D(in_Texture, var_TexCoord);
  float alpha;
  if (in_Solid)
  {alpha = in_Value < color.r ? 1.0 : 0.0;}
  else
  {alpha = color.r - in_Value;}
  
  gl_FragColor = vec4(0, 0, 0, alpha);
}
