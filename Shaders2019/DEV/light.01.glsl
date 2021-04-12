#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;

vec2 lightAxis = vec2(.5);
vec3 lightColor = vec3(1, .5, .1);
float lightIntensity = 2;
float lightDecay = 5.0;



void main()
{
   vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );

   //We set the Front RGB input into a vec3 to apply the light to it.
   vec3 resultColor = texture2D(Front, coords).rgb;

   //We apply the light Axis(vec2), Color(vec3), Intensity(float) and Decay(float) to the input texture.
   resultColor = resultColor * pow(1.0-clamp(length(coords-lightAxis),0.0,1.0), lightDecay) * lightColor * lightIntensity;
   resultColor = resultColor * pow(1.0 - length(coords-lightAxis), lightDecay) * lightColor * lightIntensity;


   //Here we combine the resulting RGB channels to a white matte, in order to get an RGBA output.
   gl_FragColor = vec4(resultColor, 1.0);
}
