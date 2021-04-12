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


void main(void) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = xy * texel;

    vec3 front = texture2D(Front, st).rgb;

    vec4 bluish_green = vec4(0.304243, 0.4178, 0.346225978, 1.0);
    vec4 blue_flower = vec4(0.2419361345, 0.2304, 0.3343865546, 1.0);
    vec4 foliage = vec4(0.1090570127, 0.1325, 0.05295287842, 1.0);
    vec4 blue_sky = vec4(0.1680159151, 0.1836, 0.2571374005, 1.0);
    vec4 light_skin = vec4(0.3917872596, 0.3495, 0.1922063301, 1.0);
    vec4 dark_skin = vec4(0.1151847498, 0.1008, 0.05089372518, 1.0);
    vec4 orange_yellow = vec4(0.4878619607, 0.4357, 0.06062597696, 1.0);
    vec4 yellow_green = vec4(0.3536913738, 0.4446, 0.08948817891,1.0);
    vec4 purple = vec4(0.08518142627, 0.0637, 0.1077664384,1.0);
    vec4 moderate_red = vec4(0.2967692026, 0.1938, 0.101548121, 1.0);
    vec4 purplish_blue = vec4(0.1232397911, 0.1126, 0.2988230769, 1.0);
    vec4 orange = vec4(0.407146979, 0.3118, 0.04998027127, 1.0);
    vec4 cyan = vec4(0.1360512736, 0.193, 0.3093873635, 1.0);
    vec4 magenta = vec4(0.3108419271, 0.2009, 0.2356539062, 1.0);
    vec4 yellow = vec4(0.5934253697, 0.5981, 0.07188823405, 1.0);
    vec4 red = vec4(0.2163881926, 0.1257, 0.03847493188, 1.0);
    vec4 green = vec4(0.1498500397, 0.2318, 0.07900178855, 1.0);
    vec4 blue = vec4(0.0685786052, 0.0575, 0.2137559102, 1.0);
    vec4 black2 = vec4(0.02994814815, 0.0311, 0.02687947413, 1.0);
    vec4 neutral_3 = vec4(0.08464157272, 0.0883, 0.07593103157, 1.0);
    vec4 neutral_5 = vec4(0.1843836267, 0.1915, 0.1591820341, 1.0);
    vec4 neutral_6 = vec4(0.3480877967, 0.3632, 0.3029540352, 1.0);
    vec4 neutral_8 = vec4(0.56571875,  0.5894, 0.4894125, 1.0);
    vec4 white_9 = vec4(0.877922367, 0.9131, 0.7397425998, 1.0);

    if (after_2015) {
        bluish_green = vec4(0.304243, 0.4178, 0.346225978, 1.0);
        blue_flower = vec4(0.2419361345, 0.2304, 0.3343865546, 1.0);
        foliage = vec4(0.1090570127, 0.1325, 0.05295287842, 1.0);
        blue_sky = vec4(0.1680159151, 0.1836, 0.2571374005, 1.0);
        light_skin = vec4(0.3917872596, 0.3495, 0.1922063301, 1.0);
        dark_skin = vec4(0.1151847498, 0.1008, 0.05089372518, 1.0);
        orange_yellow = vec4(0.4878619607, 0.4357, 0.06062597696, 1.0);
        yellow_green = vec4(0.3536913738, 0.4446, 0.08948817891,1.0);
        purple = vec4(0.08518142627, 0.0637, 0.1077664384,1.0);
        moderate_red = vec4(0.2967692026, 0.1938, 0.101548121, 1.0);
        purplish_blue = vec4(0.1232397911, 0.1126, 0.2988230769, 1.0);
        orange = vec4(0.407146979, 0.3118, 0.04998027127, 1.0);
        cyan = vec4(0.1360512736, 0.193, 0.3093873635, 1.0);
        magenta = vec4(0.3108419271, 0.2009, 0.2356539062, 1.0);
        yellow = vec4(0.5934253697, 0.5981, 0.07188823405, 1.0);
        red = vec4(0.2163881926, 0.1257, 0.03847493188, 1.0);
        green = vec4(0.1498500397, 0.2318, 0.07900178855, 1.0);
        blue = vec4(0.0685786052, 0.0575, 0.2137559102, 1.0);
        black2 = vec4(0.02994814815, 0.0311, 0.02687947413, 1.0);
        neutral_3 = vec4(0.08464157272, 0.0883, 0.07593103157, 1.0);
        neutral_5 = vec4(0.1843836267, 0.1915, 0.1591820341, 1.0);
        neutral_6 = vec4(0.3480877967, 0.3632, 0.3029540352, 1.0);
        neutral_8 = vec4(0.56571875,  0.5894, 0.4894125, 1.0);
        white_9 = vec4(0.877922367, 0.9131, 0.7397425998, 1.0);
    }


    vec4 outcol = bluish_green;

    gl_FragColor = outcol;
}
