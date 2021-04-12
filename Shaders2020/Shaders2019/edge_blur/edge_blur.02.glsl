#version 120

//get the edge of the alpha

#define PI 3.1415926535897932
#define fratio adsk_result_frameratio
#define pratio adsk_result_pixelratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D adsk_results_pass1;
uniform float blur_amount;

#define top .5
#define bottom .175

float sobel(vec2 st, sampler2D Input) {
    vec4 col = vec4(0.0);
    float sx = 0.0;
    float sy = 0.0;

    mat3 gx = mat3(
        -bottom, 0.0, bottom,
        -top, 0.0, top,
        -bottom, 0.0, bottom
    );
    
    mat3 gy = mat3(
        -bottom, -top, -bottom,
        0.0, 0.0, 0.0,
        bottom, top, bottom
    );

    for(int i = -1; i <= 1; i++) {
        for(int j = -1; j <= 1; j++) {
            float col_in = texture2D(Input, st + vec2(i, j) * texel).a;
            sx += col_in * float(gx[1 + i][1 + j]);
            sy += col_in * float(gy[1 + i][1 + j]);
        }
    }

    float g = abs(sx) + abs(sy);

    return g * (blur_amount + 1.0);
}

void main(void) {
    vec2 st = gl_FragCoord.xy / res;

    vec3 front = texture2D(adsk_results_pass1, st).rgb;
    float edge = sobel(st, adsk_results_pass1);

    gl_FragColor = vec4(front, edge);
}
