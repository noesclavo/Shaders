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
uniform float bias, scale, power;

vec3 Specular_Fresnel_Schlick( in vec3 SpecularColor, in vec3 PixelNormal, in vec3 LightDir )
{
    float NdotL = max( 0.0, dot( PixelNormal, LightDir ) );
    return SpecularColor + ( vec3(1.0) - SpecularColor ) * pow( ( 1.0 - NdotL ), 5.0 );
}

vec3 s(vec3 eyeDir , vec3 normal){
    return adsk_getMaterialSpecular().rgb * max(vec3(0), min(vec3(1), vec3(bias) + vec3(0.0) * (1.0 + eyeDir * normal) * 0.0)) * scale;
}

vec3 rim(vec3 eyeDir, vec3 normal) {
    float vdn = scale - max(dot(normalize(eyeDir), normal), 0.0);        // the rim-shading contribution
    return vec3(vdn);
}

vec4 adskUID_lightbox( vec4 source ) {
   vec3 vertexPos = adsk_getVertexPosition();
   vec3 lightPos = adsk_getLightPosition();

   vec3 normal = adsk_getNormal();
   vec3 eyeDir = adsk_getCameraPosition() - vertexPos;

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

   vec3 color = s(eyeDir, normal) * res;

   vec3 eye = normalize(eyeDir);
   vec3 n = normalize(normal);
   color = vec3(pow(1.0 - dot(eye, n), scale)) * vec3(bias);

   return vec4( color, 1.0 );
}
