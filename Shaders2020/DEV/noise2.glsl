#extension GL_EXT_gpu_shader4: enable

#define PI 3.1415926535897932
#define fratio adsk_result_frameratio
#define pratio adsk_result_pixelratio

const float PI = 3.1415926535897932;

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform sampler2D Matte;

uint hash( uint x ) {
    x += ( x << 10u );
    x ^= ( x >>  6u );
    x += ( x <<  3u );
    x ^= ( x >> 11u );
    x += ( x << 15u );
    return x;
}

float random( float f ) {
    const uint mantissaMask = 0x007FFFFFu;
    const uint one          = 0x3F800000u;

    uint h = hash( floatBitsToUint( f ) );
    h &= mantissaMask;
    h |= one;

    float  r2 = uintBitsToFloat( h );
    return r2 - 1.0;
}

void main(void) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = xy * texel;

    //vec3 front = texture2D(Front, st).rgb;
    //float matte = texture2D(Matte, st).r;

    vec4 outcol = vec4(random(st.x));

    gl_FragColor = outcol;
}
