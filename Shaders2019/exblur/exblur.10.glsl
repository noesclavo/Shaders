#version 120
//Front and Matte, Front is premultiplied

#define PI 3.1415926535897932

vec3  adsk_hsv2rgb( vec3 hsv );
float adsk_getLuminance( in vec3 color );
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D adsk_results_pass3;
uniform sampler2D adsk_results_pass5;
uniform sampler2D adsk_results_pass7;
uniform sampler2D adsk_results_pass9;
uniform sampler2D Matte;
uniform float blur_amount;
uniform bool lat;
uniform bool is_premult;
uniform bool clamp_input;

uniform int i_colorspace;
uniform int iterations;

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

vec3 adjust_gamma(vec3 col, float gamma) {
    col.r = pow(col.r, gamma);
    col.g = pow(col.g, gamma);
    col.b = pow(col.b, gamma);

    return col;
}

vec3 from_logc(vec3 col) {
    float cut = .010591;
    float a = 5.555556;
    float b = .052272;
    float c = 0.247190;
    float d = 0.385537;
    float e = 5.367655;
    float f = 0.092809;
    float e_cut_f = 0.149658;

    if (col.r > e_cut_f) {
        col.r = (pow(10, (col.r -d) / c) - b) / a;
    } else {
        col.r = (col.r - f) / e;
    }

    if (col.g > e_cut_f) {
        col.g = (pow(10, (col.g -d) / c) - b) / a;
    } else {
        col.g = (col.g - f) / e;
    }

    if (col.b > e_cut_f) {
        col.b = (pow(10, (col.b -d) / c) - b) / a;
    } else {
        col.b = (col.b - f) / e;
    }

    return col;
}

float log10(float c) {
    return log(c) / 2.3026;
}

vec3 to_logc(vec3 col) {
    float cut = .010591;
    float a = 5.555556;
    float b = .052272;
    float c = 0.247190;
    float d = 0.385537;
    float e = 5.367655;
    float f = 0.092809;
    float e_cut_f = 0.149658;

    if (col.r > cut) {
        col.r = c * log10(a * col.r + b) + d;
    } else {
        col.r = e * col.r + f;
    }

    if (col.g > cut) {
        col.g = c * log10(a * col.g + b) + d;
    } else {
        col.g = e * col.g + f;
    }

    if (col.b > cut) {
        col.b = c * log10(a * col.b + b) + d;
    } else {
        col.b = e * col.b + f;
    }

    return col;
}

vec3 do_colorspace(vec3 front, int op) {
    if (op == 0) {
        if (i_colorspace == 0) {
            front = from_rec709(front);
        } else if (i_colorspace == 1) {
            front = from_sRGB(front);
        } else if (i_colorspace == 2) {
            //linear
        } else if (i_colorspace == 3) {
            front = adjust_gamma(front, 2.2);
        } else if (i_colorspace == 4) {
            front = adjust_gamma(front, 1.8);
        } else if (i_colorspace == 5) {
            front = from_logc(front);
        }
    }
    else if (op == 1) {
        if (i_colorspace == 0) {
            front = to_rec709(front);
        } else if (i_colorspace == 1) {
            front = to_sRGB(front);
        } else if (i_colorspace == 2) {
            //linear
        } else if (i_colorspace == 3) {
            front = adjust_gamma(front, 1.0 / 2.2);
        } else if (i_colorspace == 4) {
            front = adjust_gamma(front, 1.0 / 1.8);
        } else if (i_colorspace == 5) {
            front = to_logc(front);
        }
    }

    return front;
}

vec2 repeat_coords(vec2 coords, int repeat) {
    if (repeat == 1) {
        coords = fract(coords);
    } else if (repeat == 2) {
        vec2 xx = vec2(1.0) - step(vec2(0.0), sin(coords * PI));
        coords = abs(xx - fract(coords));
    } else if (repeat == 3) {
        if (any(notEqual(clamp(coords, 0.0, 1.0), coords))) {
            discard;
        }
    }

    return coords;
}

void main(void) {
    vec2 st = gl_FragCoord.xy / res;

    if (lat) {
        st -= vec2(.5);
        st *= 1.0 + blur_amount * 5 * texel;
        st += vec2(.5);
    }

    vec2 mirror = repeat_coords(st, 2);
    vec2 tile = repeat_coords(st, 1);

    st = vec2(tile.x, mirror.y);

    vec4 one = texture2D(adsk_results_pass3, st);
    vec4 two = texture2D(adsk_results_pass5, st);
    vec4 three = texture2D(adsk_results_pass7, st);
    vec4 four = texture2D(adsk_results_pass9, st);

    vec4 outcol = one + two + three + four;

    outcol.rgb = do_colorspace(outcol.rgb, 1);

    gl_FragColor = outcol;
}
