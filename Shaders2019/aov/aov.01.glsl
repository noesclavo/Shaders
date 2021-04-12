#version 120

//vec4 adsk_getBlendedValue( int blendType, vec4 srcColor, vec4 dstColor );

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D ID1, ID2, ID3, ID4, ID5, ID6, ID7, ID8;
uniform int id1_r, id2_r, id3_r, id4_r, id5_r, id6_r, id7_r, id8_r;
uniform int id1_g, id2_g, id3_g, id4_g, id5_g, id6_g, id7_g, id8_g;
uniform int id1_b, id2_b, id3_b, id4_b, id5_b, id6_b, id7_b, id8_b;
uniform int id2_layer_op, id3_layer_op, id4_layer_op, id5_layer_op, id6_layer_op, id7_layer_op, id8_layer_op;
uniform bool id1_neg, id2_neg, id3_neg, id4_neg, id5_neg, id6_neg, id7_neg, id8_neg;

uniform float id1_r_gain, id1_g_gain, id1_b_gain;
uniform float id2_r_gain, id2_g_gain, id2_b_gain;
uniform float id3_r_gain, id3_g_gain, id3_b_gain;
uniform float id4_r_gain, id4_g_gain, id4_b_gain;
uniform float id5_r_gain, id5_g_gain, id5_b_gain;
uniform float id6_r_gain, id6_g_gain, id6_b_gain;
uniform float id7_r_gain, id7_g_gain, id7_b_gain;
uniform float id8_r_gain, id8_g_gain, id8_b_gain;

float is_on(float val, float chan) {
    if (val == 2) {
        return 1.0 - chan;
    } else {
        return chan;
    }
}

float do_screen(float col1, float col2)
{
    //A or B ≤1? A+B-AB: max(A,B)
    if (col1 <= 1.0 || col2 <= 1.0) {
        return col1 + col2 - col1 * col2;
    } else {
        return max(col1, col2);
    }
}

float do_op(float col1, float col2, float op) {
    float matte = 0.0;
    op = int(op);

    if (op == 0) {
        matte = col1 + col2;
    } else if (op == 1) {
        //matte = adsk_getBlendedValue(17, vec4(col1), vec4(col2)).r;
        matte = do_screen(col1, col2);
    } else if (op == 2) {
        matte = col2 * col1;
    } else if (op == 3) {
        matte = col2 - col1;
    } else if (op == 4) {
        matte = col1 - col2;
    } else if (op == 5) {
        matte = max(col1, col2);
    } else if (op == 6) {
        matte = min(col1, col2);
    }

    matte = clamp(matte, 0.0, 1.0);

    return matte;
}

float checkit(float val[3], sampler2D ID, float gain[3]) {
    vec2 st = gl_FragCoord.xy / res;

    float matte = 0.0;
    float x = 0.0;

    vec3 source = texture2D(ID, st).rgb;
    float chan[3] = float[](source.r, source.g, source.b);

    for (int i = 0; i < 3; i++) {
        if (val[i] > 0) {
            x = is_on(val[i], chan[i]);
            matte = do_op(x * gain[i], matte, 0.0);
        }
    }

    return matte;
}

bool any_on(float val[3])
{
    bool on = bool(0);
    float total = val[0] + val[1] + val[2];

    if (total > 0.0) {
        on = bool(1);
    }

    return on;
}

void main(void) {
    int id1_layer_op = 0;
    float layer_op = 0.0;

    float matte = 0.0;

    float val[3];
    float gain[3];

    val = float[](id1_r, id1_g, id1_b);
    gain = float[](id1_r_gain, id1_g_gain, id1_b_gain);

    layer_op = float(id1_layer_op);
    float m1 = checkit(val, ID1, gain);
    matte = abs(float(id1_neg) - do_op(matte, m1, layer_op));

    val = float[](id2_r, id2_g, id2_b);
    gain = float[](id2_r_gain, id2_g_gain, id2_b_gain);
    layer_op = float(id2_layer_op);
    if (any_on(val)) {
        float m2 = checkit(val, ID2, gain);
        matte = abs(float(id2_neg) - do_op(matte, m2, layer_op));
    }


    val = float[](id3_r, id3_g, id3_b);
    gain = float[](id3_r_gain, id3_g_gain, id3_b_gain);
    layer_op = float(id3_layer_op);
    if (any_on(val)) {
        float m3 = checkit(val, ID3, gain);
        matte = abs(float(id3_neg) - do_op(matte, m3, layer_op));
    }

    val = float[](id4_r, id4_g, id4_b);
    gain = float[](id4_r_gain, id4_g_gain, id4_b_gain);
    layer_op = float(id4_layer_op);
    if (any_on(val)) {
        float m4 = checkit(val, ID4, gain);
        matte = abs(float(id4_neg) - do_op(matte, m4, layer_op));
    }

    val = float[](id5_r, id5_g, id5_b);
    gain = float[](id5_r_gain, id5_g_gain, id5_b_gain);
    layer_op = float(id5_layer_op);
    if (any_on(val)) {
        float m5 = checkit(val, ID5, gain);
        matte = abs(float(id5_neg) - do_op(matte, m5, layer_op));
    }

    val = float[](id6_r, id6_g, id6_b);
    gain = float[](id6_r_gain, id6_g_gain, id6_b_gain);
    layer_op = float(id6_layer_op);
    if (any_on(val)) {
        float m6 = checkit(val, ID6, gain);
        matte = abs(float(id6_neg) - do_op(matte, m6, layer_op));
    }


    // 7 - 8

    val = float[](id7_r, id7_g, id7_b);
    gain = float[](id7_r_gain, id7_g_gain, id7_b_gain);
    layer_op = float(id7_layer_op);
    if (any_on(val)) {
        float m7 = checkit(val, ID7, gain);
        matte = abs(float(id7_neg) - do_op(matte, m7, layer_op));
    }

    val = float[](id8_r, id8_g, id8_b);
    gain = float[](id8_r_gain, id8_g_gain, id8_b_gain);
    layer_op = float(id8_layer_op);
    if (any_on(val)) {
        float m8 = checkit(val, ID8, gain);
        matte = abs(float(id8_neg) - do_op(matte, m8, layer_op));
    }

    gl_FragColor = vec4(matte);
}
