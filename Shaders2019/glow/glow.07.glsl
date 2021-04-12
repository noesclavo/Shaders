#version 120
//Front and Matte, Front is premultiplied

#define PI 3.1415926535897932

vec4 adsk_getBlendedValue( int blendType, vec4 srcColor, vec4 dstColor );
vec3 adsk_scene2log( in vec3 src );
vec3 adsk_log2scene( in vec3 src );
float adsk_getLuminance( in vec3 color );
float adsk_highlights( in float pixel, in float halfPoint );
float adsk_shadows( in float pixel, in float halfPoint );

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D adsk_results_pass2;
uniform sampler2D adsk_results_pass3;
uniform sampler2D adsk_results_pass4;
uniform sampler2D adsk_results_pass5;
uniform sampler2D adsk_results_pass6;

uniform sampler2D Front;
uniform sampler2D Matte;
uniform float blur_amount;
uniform bool is_premult;
uniform bool lat;

uniform int i_colorspace;
uniform int passes;
uniform int blend_mode;

vec3 from_sRGB(vec3 col) {
    if (col.r >= 0.0) {
         col.r = pow((col.r +.055)/ 1.055, 2.4);
    }

    if (col.g >= 0.0) {
         col.g = pow((col.g +.055)/ 1.055, 2.4);
    }

    if (col.b >= 0.0) {
         col.b = pow((col.b +.055)/ 1.055, 2.4);
    }

    return col;
}

vec3 from_rec709(vec3 col) {
    if (col.r < .081) {
         col.r /= 4.5;
    } else {
         col.r = pow((col.r +.099)/ 1.099, 1.0 / .45);
    }

    if (col.g < .081) {
         col.g /= 4.5;
    } else {
         col.g = pow((col.g +.099)/ 1.099, 1.0 / .45);
    }

    if (col.b < .081) {
         col.b /= 4.5;
    } else {
         col.b = pow((col.b +.099)/ 1.099, 1.0 / .45);
    }

    return col;
}

vec3 to_rec709(vec3 col) {
    if (col.r < .018) {
         col.r *= 4.5;
    } else if (col.r >= 0.0) {
         col.r = (1.099 * pow(col.r, .45)) - .099;
    }

    if (col.g < .018) {
         col.g *= 4.5;
    } else if (col.g >= 0.0) {
         col.g = (1.099 * pow(col.g, .45)) - .099;
    }

    if (col.b < .018) {
         col.b *= 4.5;
    } else if (col.b >= 0.0) {
         col.b = (1.099 * pow(col.b, .45)) - .099;
    }


    return col;
}

vec3 to_sRGB(vec3 col) {
    if (col.r >= 0.0) {
         col.r = (1.055 * pow(col.r, 1.0 / 2.4)) - .055;
    }

    if (col.g >= 0.0) {
         col.g = (1.055 * pow(col.g, 1.0 / 2.4)) - .055;
    }

    if (col.b >= 0.0) {
         col.b = (1.055 * pow(col.b, 1.0 / 2.4)) - .055;
    }

    return col;
}

vec3 do_colorspace(vec3 front, int op) {

    // convert from working colorspace to linear
    if (op == 0) {
        if (i_colorspace == 0) {
            // recs709 input
            front = from_rec709(front);
        } else if (i_colorspace == 1) {
            // sRGB input
            front = from_sRGB(front);
        } else if (i_colorspace == 2) {
            // linear input
        } else if (i_colorspace == 3) {
            // log input
            front = adsk_log2scene(front);
        }
    }

    // convert from linear to working colorspace
    else if (op == 1) {
        if (i_colorspace == 0) {
            // recs709 input
            front = to_rec709(front);
        } else if (i_colorspace == 1) {
            // sRGB input
            front = to_sRGB(front);
        } else if (i_colorspace == 2) {
            // linear input
        } else if (i_colorspace == 3) {
            // log input
            front = adsk_scene2log(front);
        }
    }

    return front;
}

vec2 repeat_coords(vec2 coords, int repeat) {
    //repeat value of 0 is default
    //default is stretch
    
    //tile
    if (repeat == 1) {
        if (coords.x > 1.0 || coords.x < 0.0) {
            coords.x = fract(coords.x);
        }
        if (coords.y > 1.0 || coords.y < 0.0) {
            coords.y = fract(coords.y);
        }
    //mirror
    } else if (repeat == 2) {
        if (mod(floor(coords.x), 2) != 0) {
            coords.x = 1.0 - fract(coords.x);
        } else {
            coords.x = fract(coords.x);
        }
        if (mod(floor(coords.y), 2) != 0.0) {
            coords.y = 1.0 - fract(coords.y);
        } else {
            coords.y = fract(coords.y);
        }
    //crop
    } else if (repeat == 3) {
        if (coords.x > 1.0 || coords.x < 0.0) {
            discard;
        }
        if (coords.y > 1.0 || coords.y < 0.0) {
            discard;
        }
    }

    return coords;
}

void main(void) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = xy * texel;

    vec3 front = texture2D(Front, st).rgb;
    float matte = texture2D(Matte, st).r;
    if (is_premult) {
        front /= matte;
    }
    front = do_colorspace(front, 0);

    vec4 glowed = vec4(0.0);

    if (passes == 1) {
        glowed = texture2D(adsk_results_pass6, st);
    } else if (passes == 2) {
        glowed = texture2D(adsk_results_pass6, st) + texture2D(adsk_results_pass5, st);
    } else if (passes == 3) {
        glowed = texture2D(adsk_results_pass6, st) + texture2D(adsk_results_pass5, st) + texture2D(adsk_results_pass4, st);
    } else if (passes == 3) {
        glowed = texture2D(adsk_results_pass6, st) + texture2D(adsk_results_pass5, st) + texture2D(adsk_results_pass4, st)
            + texture2D(adsk_results_pass3, st);
    } else if (passes == 4) {
        glowed = texture2D(adsk_results_pass6, st) + texture2D(adsk_results_pass5, st) + texture2D(adsk_results_pass4, st)
            + texture2D(adsk_results_pass3, st) + texture2D(adsk_results_pass2, st);
    }

    //glowed.a = clamp(glowed.a, 0.0, 1.0);

    //glowed.rgb /= passes;
    glowed = clamp(glowed, 0.0, 1.0);


    /*
    Add = 0
    Sub = 1
    Multiply = 2
    LinearBurn = 10
    Spotlight = 11
    Flame_SoftLight = 13
    HardLight = 14
    PinLight = 15
    Screen = 17
    Overlay = 18
    Diff = 19
    Exclusion = 20
    Flame_Max = 29
    Flame_Min = 30
    LinearLight = 32
    LighterColor = 33
    */

    vec4 comp = vec4(0.0);
    vec4 blended = vec4(0.0);
    if (blend_mode > 0) {
        //comp.rgb = mix(front, glowed.rgb, glowed.a);
        //blended = adsk_getBlendedValue(blend_mode, vec4(front, 1.0), comp);
        //comp.rgb = mix(comp.rgb, blended.rgb, glowed.a);
        comp = adsk_getBlendedValue(blend_mode, vec4(front, 1.0), glowed);
    } else {
        comp = glowed; 
    }



    if (is_premult || blend_mode < 0) {
        comp.rgb *= glowed.a;
    }

    comp.rgb = do_colorspace(comp.rgb, 1);

    gl_FragColor = vec4(comp.rgb, glowed.a);
}
