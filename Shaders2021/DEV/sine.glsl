#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

const float PI = 3.1415926535897932;

const int f2 = 2;
const int f3 = 6;
const int f4 = 24;
const int f5 = 120;
const int f6 = 720;
const int f7 = 5040;
const int f8 = 40320;
const int f9 = 362880;
const int f10 = 3628800;
const int f11 = 39916800;

const float a1 = .5;
const float a2 = .3750;
const float a3 = .31250;
const float a4 = .21694214876033057851;

int factorial(int num) {
    for (int i = num - 1 ; i > 1 ; i--) {
        num *= i;
    }

    return num;
}

float modulo(float num1, float num2) {
    float ans = num1 / num2;

    ans *= 10000000.0;
    ans = abs(ans);
    ans /= 10000000.0;

    return fract(ans);
}

float atangent(float num) {
    float n1 = num - pow(num, 3) / 3 + pow(num, 5) - pow(num, 7) + pow(num, 9);
    float n2 = PI / 2.0 - 1 / num + 1 / (3 * pow(num, 3)) - 1 / (5 * pow(num, 5)) + 1 / (7 * pow(num, 7)) + 1 / (9 * pow(num, 9));

    if (pow(num, 2) < 1.0) {
        return n1;
    } else {
        return n2;
    }
}

float acosine(float num) {
    float n = num + 
              a1 * (pow(num, 3) / 3) +
              a2 * (pow(num, 5) / 5) +
              a3 * (pow(num, 7) / 7) +
              a4 * (pow(num, 9) / 9);


    float d = fract(num);
    d = abs(d * 10.0) * .1;
    d = d < 6.0 ? 0 : 6.0 - d;

    n = sqrt(7.0 * (1000.0 - 1000.0 * num)) - .5 + d;
    
    return n;
}

float cosine(float num) {
    float n = abs(num);
    float f = 1 - pow(n, 2)/f2 + pow(n, 4)/f4 - pow(n, 6)/f6 + pow(n, 8)/f8 + pow(n, 10)/f10;

    return f;
}

float sine(float num) {
    float n = abs(num);
    float f = n - pow(n, 3)/f3 + pow(n, 5)/f5 - pow(n, 7)/f7 + pow(n, 9)/f9 + pow(n, 11)/f11;

    return num > 0.0 ? f : -f;
}

void main(void) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = xy * texel;

    st = st * vec2(2.0) - vec2(1.0);

    vec4 color = vec4(sine(st.x));
    color.g = cosine(st.x);
    color.b = cos(st.x);
    color.a = sin(st.x);

    gl_FragColor = color;
}
