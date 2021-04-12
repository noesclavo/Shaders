#version 120

#define ratio adsk_result_frameratio

vec3  adsk_hsv2rgb( vec3 hsv );
float adsk_getLuminance( vec3 );

uniform float ratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D adsk_results_pass1;
uniform sampler2D Front;
uniform sampler2D Matte;
uniform vec3 bg;

uniform bool usebg;

vec3 getRGB( float hue, float sat) {
    vec3 rgb =  adsk_hsv2rgb( vec3( hue, sat, 1.0 ) );

    rgb = clamp(rgb, 0.0, 1.0);

    return rgb;
}

void main(void) {
    vec2 st = gl_FragCoord.xy / res;
    vec3 front = texture2D(Front, st).rgb;
    float matte = texture2D(Matte, st).r;

    //vec3 b_offset = getRGB( bg.x / 360.0, bg.z * .01 ) * vec3( bg.y * 0.01);
    vec3 b_offset = getRGB( bg.x / 360.0, bg.y * .01 ) * vec3( bg.z * 0.01);
    vec3 bgcol = b_offset;

    vec4 shape = vec4(0.0);

    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            shape += texture2D(adsk_results_pass1, st + texel * vec2(i, j));
        }
    }

    shape /= vec4(9.0);

    float a = clamp(shape.a, 0.0, 1.0);

    shape.rgb /= vec3(max(shape.a, .0000000001));

    vec3 comp = mix(front, shape.rgb, a);

    if (usebg) {
        comp = mix(bgcol, shape.rgb, a);
    }

    comp = mix(front, comp, matte);

    gl_FragColor = vec4(comp, shape.a);
}
