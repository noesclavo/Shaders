vec3 adsk_getNormal();
vec3 adsk_getBinormal();
vec3 adsk_getTangent();

uniform int adskUID_i;

vec4 adskUID_lightbox( vec4 source ) {
    vec3 color = adsk_getNormal();
    if (adskUID_i == 0) {
        color = adsk_getNormal();
    } else if (adskUID_i == 1) {
        color = adsk_getTangent();
    } else if (adskUID_i == 2) {
        color = adsk_getBinormal();
    } else {
        color = adsk_getBinormal() * adsk_getTangent();
    }

    return vec4( color, 1.0 );
}
