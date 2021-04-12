float adsk_getAreaLightWidth();
float adsk_getAreaLightHeight();
vec3 adsk_getNormal();
vec3 adsk_getTangent();

vec3 adsk_getLightDirection();
vec3 adsk_getLightTangent();
vec3 adsk_getLightPosition();

mat4 adsk_getModelViewInverseMatrix();

vec3 adsk_getVertexPosition();

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

float adsk_getSpotlightParametricFalloffOut();
float adsk_getSpotlightParametricFalloffIn();

uniform vec3 adskUID_lightColor;

const vec3 adskUID_zero = vec3(0);
uniform float adskUID_spread;
uniform float adskUID_gain;
uniform float adskUID_relation;
uniform vec3 adskUID_color;
uniform vec3 adskUID_pos;
uniform bool adskUID_x;

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
   vec3 lightTan = adsk_getLightTangent();
   vec3 binormal = adsk_getTangent();
   vec3 normal = adsk_getNormal();
   vec3 tangent = adsk_getTangent();
   vec3 cpos = adsk_getCameraPosition();

   vec3 eyeDir = cpos - vertexPos;

   vec3 worldVertex = (vec4(vertexPos, .0) * adsk_getModelViewInverseMatrix()).xyz;
   vec3 worldNormal = (vec4(normal, 0.0) * adsk_getModelViewInverseMatrix()).xyz;
   vec3 worldCamera = (vec4(cpos, 0.0) * adsk_getModelViewInverseMatrix()).xyz;

   
   /*float nDotL = max( dot( normal, eyeDir ), 0.0 );*/
    
   vec3 reflect_vec = reflect(-normalize(eyeDir), normalize(normal));
   vec3 res = source.rgb + reflect_vec;


   vec3 color = res;

   return vec4( color, 1.0 );
}
