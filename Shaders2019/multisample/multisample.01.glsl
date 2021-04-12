#version 120

#define PI 3.1415926535897932
#define fratio adsk_result_frameratio
#define pratio adsk_result_pixelratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform vec2 lower_left, upper_left, lower_right, upper_right;
uniform float thresh;

uniform  vec2 p0;
uniform  vec2 p1;
uniform  vec2 p2;
uniform  vec2 p3;
uniform float scale;

void main(void) {
    vec2 st = gl_FragCoord.xy / res;

    vec4 color0 = texture2D(Front, p0);
    vec4 color1 = texture2D(Front, p1);
    vec4 color2 = texture2D(Front, p2);
    vec4 color3 = texture2D(Front, p3);



    vec2 Q = p0 - p2;
    vec2 R = p1 - p0;
    vec2 S = R + p2 - p3;
    vec2 T = p0 - st;

    float u;
    float t;

    if(Q.x == 0.0 && S.x == 0.0) {
        u = -T.x / R.x;
        t = (T.y + u * R.y) / (Q.y + u * S.y);
    } else if (Q.y == 0.0 && S.y == 0.0) {
        u = -T.y / R.y;
        t = (T.x + u * R.x) / (Q.x + u * S.x);
    } else {
        float A = S.x * R.y - R.x * S.y;
        float B = S.x * T.y - T.x * S.y + Q.x * R.y - R.x * Q.y;
        float C = Q.x * T.y - T.x * Q.y;
        // Solve Au^2 + Bu + C = 0
        if (abs(A) < 0.0001) {
            u = -C/B;
        } else {
            u = (-B+sqrt(B*B-4.0*A*C))/(2.0*A);
            t = (T.y + u*R.y) / (Q.y + u*S.y);
        }

    }

    u = clamp(u,0.0,1.0);
    t = clamp(t,0.0,1.0);

    // These two lines smooth out t and u to avoid visual 'lines' at the boundaries.  They can be removed to improve performance at the cost of graphics quality.
    t = smoothstep(0.0, 1.0, t);
    u = smoothstep(0.0, 1.0, u);

    vec4 colorA = mix(color0,color1,u);
    vec4 colorB = mix(color2,color3,u);

    gl_FragColor = mix(colorA, colorB, t);
}
