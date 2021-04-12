#version 120

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
uniform sampler2D Input2;
uniform sampler2D Input3;
uniform sampler2D Input4;
uniform sampler2D Input5;
uniform sampler2D Input6;

uniform int rows;
uniform int cols;

void main(void) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = xy * texel;
    vec2 tile_coords = st;

    float tilew = res.x / float(cols);
    float tileh = res.y / float(rows);

    int tilex = int(xy.x / tilew);
    int tiley = int( (res.y - xy.y) / tileh);
    int tileidx = tiley * cols * tilex;

    vec2 tilecoords = vec2(0.0);
    tilecoords.x = mod(xy.x, tilew) / tilew;
    tilecoords.y = mod(xy.y, tileh) / tileh;

    tilecoords -= vec2(.5);
    float aspectdiff = (tilew / tileh) / (res.x, res.y);

    if (aspectdiff > 1.0) {
        tilecoords.x *= aspectdiff;
    } else {
        tilecoords.y /= aspectdiff;
    }

    tilecoords += vec2(0.5); 

    vec3 outcol = vec3(0.0);
    
    if (tileidx == 0) {
        outcol = texture2D(Front, st).rgb;
    } else if (tileidx == 1) {
        outcol += texture2D(Input2, st).rgb;
    } else if (tileidx == 2) {
        outcol = texture2D(Input3, st).rgb;
    } else if (tileidx == 3) {
        outcol = texture2D(Input4, st).rgb;
    } else if (tileidx == 4) {
        outcol = texture2D(Input5, st).rgb;
    } else if (tileidx == 5) {
        outcol = texture2D(Input6, st).rgb;
    }

    gl_FragColor.rgb = outcol;
}
