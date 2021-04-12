#version 120
//Front and Matte, Front is premultiplied

#define PI 3.1415926535897932

vec3  adsk_hsv2rgb( vec3 hsv );
vec3 adsk_scene2log( in vec3 src );
vec3 adsk_log2scene( in vec3 src );
float adsk_getLuminance( in vec3 color );
float adsk_highlights( in float pixel, in float halfPoint );
float adsk_shadows( in float pixel, in float halfPoint );

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform sampler2D Matte;
uniform float blur_amount;
uniform float threshold;
uniform vec3 color;
uniform float brightness;
uniform float saturation;
uniform bool is_premult;
uniform bool lat;

uniform int i_colorspace;

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
    vec2 st = gl_FragCoord.xy / res;

    if (lat) {
        st -= vec2(.5);
        st *= 1.0 + blur_amount * 5 * texel;
        st += vec2(.5);

        vec2 mirror = repeat_coords(st, 2);
        vec2 tile = repeat_coords(st, 1);

        st = vec2(tile.x, mirror.y);
    }

    vec3 front = texture2D(Front, st).rgb;
    float matte = texture2D(Matte, st).r;

    if (is_premult && matte > 0.0) {
        front /= matte;
    }

    front = do_colorspace(front, 0);

    float luma = adsk_getLuminance(front);
    float t = adsk_highlights(luma, threshold);

    if (threshold < 0.0) {
        t = adsk_shadows(luma, threshold);
    }

    /*
    vec3 offset = getRGB( color.x / 360.0 ) * vec3( color.y * 0.01);
    vec3 outcol = front + offset;
    outcol = outcol * vec3(adsk_getLuminance(front) / max(adsk_getLuminance(outcol), 0.001));
    */

    vec3 outcol = front;
    outcol *= color;
    outcol = mix(vec3(luma), outcol, saturation * .01);
    outcol *= brightness * .01;


    float alpha = t * matte;
    alpha = clamp(alpha, 0.0, 1.0);
    outcol *= alpha;

    gl_FragColor = vec4(outcol, alpha);
}
