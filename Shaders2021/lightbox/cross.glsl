vec3 adsk_getNormal();
vec3 adsk_getCameraPosition();
vec3 adsk_getVertexPosition();
vec3 adsk_getBinormal();
vec3 adsk_getTangent();
vec4 adsk_getMaterialDiffuse();

vec4 adskUID_lightbox( vec4 source ) {
    //bumpNormal = (bumpMap.x * input.tangent) + (bumpMap.y * input.binormal) + (bumpMap.z * input.normal);

    vec3 map = adsk_getMaterialDiffuse().rgb;
    vec3 cam = normalize(adsk_getCameraPosition() - adsk_getVertexPosition());

    vec3 norm = adsk_getNormal();
    vec3 tang = adsk_getTangent();
    vec3 binorm = adsk_getBinormal();

    vec3 bump =  normalize(map.x * tang + map.y * binorm + map.z * norm);

    vec3 color = bump;

    return vec4( color, 1.0 );
}
