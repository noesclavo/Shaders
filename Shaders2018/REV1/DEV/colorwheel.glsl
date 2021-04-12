#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;

vec3  adsk_hsv2rgb( vec3 hsv );
vec3 adsk_hsv2rgb( in vec3 src );

/*
<Uniform Inc="0.1" Tooltip="Background Color. Adjust Hue / Gain / Saturation to liking." Row="0" Col="1" Page="0" IconType="None" ValueType="ColourWheel" Type="vec3" DisplayName="Tint" Name="tint" HueShift="False" AngleName="Hue" IntensityName1="Gain" IntensityName2="Sat">
	<SubUniform ResDependent="None" Max="1000.0" Min="-1000.0" Default="190.0" Inc="1.0">
		</SubUniform>
	<SubUniform ResDependent="None" Max="1000.0" Min="-1000.0" Default="25.0" Inc="1.0">
		</SubUniform>
	<SubUniform ResDependent="None" Max="100.0" Min="0.0" Default="0.0" Inc="10.0">
		</SubUniform>
</Uniform>
*/

vec3 getRGB( float hue, float sat)
{
    vec3 rgb =  adsk_hsv2rgb( vec3( hue, sat, 1.0 ) );

    rgb = clamp(rgb, 0.0, 1.0);

    return rgb;
}


void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec3 g_offset = getRGB( tint.x / 360.0, tint.z * .01 ) * vec3( tint.y * 0.05);

	vec3 front = texture2D(Front, st).rgb;
	front *= g_offset;

	gl_FragColor.rgb = front;
}
