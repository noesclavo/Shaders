#version 120
//threshold pass, create threshold, grade and tint front, multiply front by threshold

#define FRONTCC adsk_results_pass1
#define STRENGTH adsk_results_pass2

vec3  adsk_hsv2rgb( vec3 hsv );
float adsk_getLuminance( in vec3 color );
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D FRONTCC;
uniform sampler2D STRENGTH;
uniform float threshold;
uniform float falloff;
uniform vec3 tint;
float saturation = 1.0;
uniform float brightness;
float gamma = 1.0;

vec3 getRGB( float hue, float sat) {
    vec3 rgb =  adsk_hsv2rgb( vec3( hue, sat, 1.0 ) );

    rgb = clamp(rgb, 0.0, 1.0);

    return rgb;
}

void main(void) {
    vec2 st = gl_FragCoord.xy / res;

    vec4 frontcc = texture2D(FRONTCC, st);
    float strength = texture2D(STRENGTH, st).r;
    float luma = adsk_getLuminance(frontcc.rgb);

    float t = abs(threshold);

    if (t == 0.0) {
        t = .001;
    }

    float c = clamp(luma, 0.0, t);
    float c_gain = 1 / t * c;
    float c_contrast = (c_gain - 1.0) * (1.0 / falloff) + 1.0;
    float thresh = clamp(c_contrast, 0.0, 1.0);

    if (sign(threshold) == -1) {
        thresh = 1.0 - thresh;
    }

    float alpha = thresh * frontcc.a;

    //Saturation
    vec3 threshold_out = mix(vec3(luma), frontcc.rgb, mix(1.0, saturation, strength));

    //Gamma
    threshold_out = pow(threshold_out, mix(vec3(1.0), vec3(1.0 - (gamma - 1.0)), strength));

    //Tint Hue, Gain and Tint Saturation
    float hue = mix(1.0, tint.x, strength);
    float sat = mix(1.0, tint.y, strength);
    float gain = mix(1.0, tint.z, strength);
    vec3 g_offset = getRGB( hue / 360.0, sat * .01 ) * vec3( gain * 0.05);

    threshold_out *= g_offset;


    threshold_out *= alpha;


    gl_FragColor = vec4(threshold_out, alpha);
}
