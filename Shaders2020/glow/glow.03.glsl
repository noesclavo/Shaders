#version 120

vec4 adsk_getBlendedValue( int blendType, vec4 srcColor, vec4 dstColor );
vec3    adsk_hsv2rgb( vec3 hsv );
vec3    adsk_scene2log( in vec3 src );
vec3    adsk_log2scene( in vec3 src );
float   adsk_getLuminance( in vec3 color );
float   adsk_highlights( in float pixel, in float halfPoint );
float   adsk_shadows( in float pixel, in float halfPoint );

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D   Front;
uniform sampler2D   Matte;
uniform sampler2D   adsk_results_pass2;

uniform float       width;
uniform bool        front_is_premultiplied;
uniform bool        front_is_equirectangular;
uniform int         i_colorspace;
uniform int         blend_mode;

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
vec3 getRGB( float hue ) {
   return adsk_hsv2rgb( vec3( hue, 1.0, 1.0 ) );
}

void main(void) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = xy * texel;

    if (front_is_equirectangular) {
        st -= vec2(.5);
        st *= 1.0 + width * 5 * texel;
        st += vec2(.5);

        vec2 mirror = repeat_coords(st, 2);
        vec2 tile = repeat_coords(st, 1);

        st = vec2(tile.x, mirror.y);
    }

    vec4 front = texture2D(Front, st);
    float matte = texture2D(Matte, st).r;
    vec4 blurred = texture2D(adsk_results_pass2, st);
    vec4 outcol = vec4(0.0);

    if (front_is_premultiplied && matte > 0.0) {
        if (matte > 0.0) {
            front.rgb /= matte;
        }

        front.rgb = do_colorspace(outcol.rgb, 0);
    }

    if (blend_mode > -1) {
        outcol = adsk_getBlendedValue(blend_mode, front, blurred);
    } else {
        outcol = blurred;
    }

    outcol.rgb = do_colorspace(outcol.rgb, 1);

    gl_FragColor = vec4(outcol.rgb, blurred.a);
}
