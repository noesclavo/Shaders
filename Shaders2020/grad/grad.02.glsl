//#version 120

#define fratio adsk_result_frameratio
#define pratio adsk_result_pixelratio

vec3 adsk_rgb2hsv( in vec3 src );
vec3 adsk_hsv2rgb( in vec3 src );


vec3 adsk_rgb2hsv( in vec3 src );
vec3 adsk_hsv2rgb( in vec3 src );

const float PI = 3.1415926535897932;

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D adsk_results_pass1;

uniform vec2 p0;
uniform vec2 p1;
uniform vec2 p2;
uniform vec2 p3;
uniform float threshold;

float gradientNoise(vec2 uv)
{
    const vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
    return fract(magic.z * fract(dot(uv, magic.xy)));
}

void main(void) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = xy * texel;

    vec4 front = texture2D(adsk_results_pass1, st);

    vec4 col0 = texture2D(adsk_results_pass1, p0);
    vec4 col1 = texture2D(adsk_results_pass1, p1);
    vec4 col2 = texture2D(adsk_results_pass1, p2);
    vec4 col3 = texture2D(adsk_results_pass1, p3);

    vec2 v0 = p1 - p0;
    vec2 v1 = st - p0;
    float t0 = clamp(dot(v0, v1) / dot(v0, v0), 0.0, 1.0);

    t0 = mix(0.0, 1.0, clamp(t0, 0.0, 1.0));

    vec4 outcol0 = mix(col0, col1, t0);

    v0 = p3 - p2;
    v1 = st - p2;
    float t1 = clamp(dot(v0, v1) / dot(v0, v0), 0.0, 1.0);

    vec4 outcol1 = mix(col2, col3, t1);

    st.x *= adsk_result_frameratio;

    float d0 = distance(p0 * vec2(adsk_result_frameratio, 1.0), st);
    float d1 = distance(p1 * vec2(adsk_result_frameratio, 1.0), st);
    float d2 = distance(p2 * vec2(adsk_result_frameratio, 1.0), st);
    float d3 = distance(p3 * vec2(adsk_result_frameratio, 1.0), st);


    vec4 outcol = mix(col0, col1, 1.0 - distance(p1 * vec2(adsk_result_frameratio, 1.0), st));
    outcol = mix(outcol, col2, 1.0 - distance(p2 * vec2(adsk_result_frameratio, 1.0), st));
    outcol = mix(outcol, col3, 1.0 - distance(p3 * vec2(adsk_result_frameratio, 1.0), st));


    gl_FragColor = outcol;
}
