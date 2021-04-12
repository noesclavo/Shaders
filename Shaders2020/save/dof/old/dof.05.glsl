#version 120

#define FRONTCC adsk_results_pass1
#define THRESHOLD adsk_results_pass3
#define BLURRED adsk_results_pass4

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D Front;
uniform sampler2D FRONTCC;
uniform sampler2D THRESHOLD;
uniform sampler2D KERNEL;
uniform sampler2D BLURRED;

uniform int i_colorspace;
uniform bool show_kernel;
uniform bool show_threshold;
uniform bool is_premult;
uniform float chroma;
vec2 texel = vec2(1.0) / res;

vec3 from_sRGB(vec3 col)
{
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

vec3 from_rec709(vec3 col)
{
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

vec3 to_rec709(vec3 col)
{
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

vec3 to_sRGB(vec3 col)
{
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

vec3 adjust_gamma(vec3 col, float gamma)
{
    col.r = pow(col.r, gamma);
    col.g = pow(col.g, gamma);
    col.b = pow(col.b, gamma);

    return col;
}

vec3 from_logc(vec3 col)
{
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

float log10(float c)
{
    return log(c) / 2.3026;
}

vec3 to_logc(vec3 col)
{
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

vec3 do_colorspace(vec3 front, int op)
{
    if (op == 0)
    {
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
    else if (op == 1)
    {
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

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

    vec4 blurred = vec4(0.0);

	blurred.r = texture2D(BLURRED, st).r;
	blurred.a = texture2D(BLURRED, st).a;

    for (float i = 0.0 ; i <= abs(chroma) ; i++) {
	    blurred.g = texture2D(BLURRED, st + vec2(chroma) * texel * .1).g;
	    blurred.b = texture2D(BLURRED, st + vec2(chroma * 2.0) * texel * .1).b;
    }

    vec4 comp = blurred;

    if (is_premult && comp.a > 0) {
        if (comp.a > 0) {
            comp.rgb /= comp.a;
        }
        comp.rgb = do_colorspace(comp.rgb, 1);
        comp.rgb *= comp.a;
    } else {
	    vec4 front = texture2D(Front, st);
        front.rgb = do_colorspace(front.rgb, 0);
        comp.rgb = mix(front.rgb, blurred.rgb, blurred.a);
        comp.rgb = do_colorspace(comp.rgb, 1);
    }

    if (show_threshold) {
	    comp = texture2D(THRESHOLD, st).aaaa;
        comp.rgb *= blurred.a;
    } else if (show_kernel) {
	    comp = texture2D(BLURRED, st).rgba;
    }

	//comp = texture2D(BLURRED, st);

	gl_FragColor = comp;
}
