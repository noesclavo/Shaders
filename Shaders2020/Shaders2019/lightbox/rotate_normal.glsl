float adsk_getAreaLightWidth();
float adsk_getAreaLightHeight();
vec3 adsk_getNormal();
vec3 adsk_getLightDirection();
vec3 adsk_getLightTangent();

vec3 adsk_getVertexPosition();
vec3 adsk_getLightPosition();
vec3 adsk_getComputedDiffuse();
vec3 adsk_getComputedSpecular();
float adsk_getShininess();
vec4 adsk_getMaterialSpecular();
vec4 adsk_getMaterialDiffuse();

float adsk_getAreaLightWidth();
float adsk_getAreaLightHeight();
vec3 adsk_getLightColour();

vec3 adsk_getCameraPosition();

vec3 adsk_getComputedShadowCoefficient();

uniform vec3 adskUID_lightColor;

const vec3 adskUID_zero = vec3(0);
uniform float adskUID_spread;
uniform float adskUID_gain;
uniform float adskUID_relation;
uniform vec3 adskUID_rotation;

float adsk_getIBLDiffuseOffset( in int idx );


vec3 rotate_coords(vec3 coords, vec3 rot) {
    mat3 rmx = mat3(
        1.0, 0.0, 0.0,
        0.0, cos(rot.x), sin(rot.x),
        0.0, -sin(rot.x), cos(rot.x)
    );

    mat3 rmy = mat3(
        cos(rot.y), 0.0, sin(rot.y),
        0.0, 1.0, 0.0,
        -sin(rot.y), 0.0, cos(rot.y)
    );

    mat3 rmz = mat3(
        cos(rot.z), sin(rot.z), 0.0,
        -sin(rot.z), cos(rot.z), 0.0,
        0.0, 0.0, 1.0
    );

    coords *= rmx;
    coords *= rmy;
    coords *= rmz;

    return coords;
}

vec4 adskUID_lightbox( vec4 source ) {
   vec3 vertexPos = adsk_getVertexPosition();
   vec3 lightPos = adsk_getLightPosition();

   vec3 normal = adsk_getNormal();
   normal = rotate_coords(normal, adskUID_rotation);
   //vec3 eyeDir = adsk_getCameraPosition() - vertexPos;
   vec3 cpos = mix(adsk_getCameraPosition(), vec3(vertexPos.x, vertexPos.y, adsk_getCameraPosition().z), adskUID_relation);
   vec3 eyeDir = cpos - vertexPos;

   vec3 lightDir = normalize( lightPos - vertexPos );
   vec3 halfDir = normalize( lightDir + eyeDir );

   float nDotL = max( dot( normal, lightDir ), 0.0 );
   float nDotH = max( dot( normal, halfDir ), 0.0 );

   vec3 diffCol = adsk_getComputedDiffuse();
   vec3 specCol = adsk_getComputedSpecular();
   float shininess = adsk_getShininess();

   vec3 diff = diffCol * nDotL;
   vec3 spec = ( nDotL > 0.0 && shininess > 0.0 ) ?
      specCol * max( pow( nDotH, shininess ), 0.0 ) : adskUID_zero;

   vec3 shadowCoeff = adsk_getComputedShadowCoefficient();
   vec3 res = source.rgb + shadowCoeff * adsk_getLightColour() * shadowCoeff * ( diff + spec );

   vec3 eye = normalize(eyeDir);
   vec3 n = normalize(normal);
   vec3 rim = vec3(pow(1.0 - dot(eye, n), 1.0 / adskUID_spread)) * vec3(adskUID_gain * 10.0);
   vec3 color = smoothstep(.1, 1.0, rim);
   color =  source.rgb + color;
   color - normal;

   //color = mix(res, res+res, color);
   //color = res;
   //color = mix(vec3(1.0), res, color);

   return vec4( color, 1.0 );
}
