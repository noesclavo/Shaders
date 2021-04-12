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
uniform float dif_thresh;
uniform float lit, unlit;


vec4 adskUID_lightbox( vec4 source )
{
   vec3 vertexPos = adsk_getVertexPosition();
   vec3 lightPos = adsk_getLightPosition();

   vec3 normal = adsk_getNormal();
   vec3 eyeDir = adsk_getCameraPosition() - vertexPos;

   vec3 lightDir = normalize( lightPos - vertexPos );
   vec3 halfDir = normalize( lightDir + eyeDir );

   vec3 diffCol = adsk_getComputedDiffuse();
   vec3 specCol = adsk_getComputedSpecular();
   float shininess = adsk_getShininess();

   float d = length(lightPos - vertexPos);
   float attenuation = 1.0 / d;
   vec3 color = vec3(.2);

   if (attenuation * max(0.0, dot(normal, lightDir)) >= dif_thresh) {
       color = adsk_getLightColour() * color;
   }

    if (dot(eyeDir, normal) < mix(unlit, lit, max(0.0, dot(normal, lightDir)))) {
        color = adsk_getLightColour() * vec3(1.0, 0., 0.);
   }

    if (dot(normal, lightDir) > 0.0 && attenuation * pow(max(0.0, dot(reflect(-lightDir, normal), eyeDir)), adsk_getShininess()) > .5) {
            color = adsk_getMaterialSpecular().rgb * adsk_getLightColour() + (1.0 - adsk_getMaterialSpecular().a) * color;
            }

   return vec4( color, 1.0 );
}
