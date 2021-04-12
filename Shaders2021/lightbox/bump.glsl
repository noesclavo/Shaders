//*****************************************************************************/
//
// Filename: SimpleLight.glsl
//
// Copyright (c) 2015 Autodesk, Inc.
// All rights reserved.
//
// This computer source code and related instructions and comments are the
// unpublished confidential and proprietary information of Autodesk, Inc.
// and are protected under applicable copyright and trade secret law.
// They may not be disclosed to, copied or used by any third party without
// the prior written consent of Autodesk, Inc.
//*****************************************************************************/

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

vec3 adsk_getBinormal();
vec3 adsk_getTangent();
vec4 adsk_getMaterialDiffuse();
vec4 adsk_getMaterialSpecular();
vec4 adsk_getSpecularMapValue (in vec2 texCoord);
vec3 adsk_getSpecularMapCoord();




float adsk_getAreaLightWidth();
float adsk_getAreaLightHeight();

vec3 adsk_getCameraPosition();

vec3 adsk_getComputedShadowCoefficient();

uniform float adskUID_trans;

const vec3 adskUID_zero = vec3(0);

vec4 adsk_getDiffuseMapValue (in vec2 texCoord);
vec3 adsk_getDiffuseMapCoord();

vec4 adskUID_lightbox( vec4 source ) {
    vec3 vertexPos = adsk_getVertexPosition();
    vec3 lightPos = adsk_getLightPosition();

    vec2 mapcoords = adsk_getSpecularMapCoord().rg / max(adsk_getSpecularMapCoord().b, .0000000001);
    vec3 map = adsk_getSpecularMapValue(mapcoords).rgb;
    vec3 norm = adsk_getNormal();
    vec3 tang = adsk_getTangent();
    vec3 binorm = adsk_getBinormal();
    mat3 m = mat3(tang, binorm, norm);

    vec3 normal = adsk_getNormal();
    vec3 eyeDir = adsk_getCameraPosition() - vertexPos;

    vec3 lightDir = normalize( lightPos - vertexPos );
    vec3 halfDir = normalize( lightDir + eyeDir );

    lightDir *= m;

    float nDotL = max( dot( normal, lightDir ), 0.0 );
    float nDotH = max( dot( normal, halfDir ), 0.0 );

    vec3 diffCol = adsk_getComputedDiffuse();
    vec3 specCol = adsk_getComputedSpecular();
    float shininess = adsk_getShininess();

    vec3 diff = diffCol * nDotL;
    vec3 spec = ( nDotL > 0.0 && shininess > 0.0 ) ?
      specCol * max( pow( nDotH, shininess ), 0.0 ) : adskUID_zero;

    vec3 shadowCoeff = adsk_getComputedShadowCoefficient();
    vec3 res = source.rgb + shadowCoeff * vec3(1.0, .5, 0.) * shadowCoeff * ( diff + spec );

    return vec4( res, 1.0 );
}
