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

float adsk_getAreaLightWidth();
float adsk_getAreaLightHeight();

vec3 adsk_getCameraPosition();

vec3 adsk_getComputedShadowCoefficient();

uniform vec3 adskUID_lightColor;

const vec3 adskUID_zero = vec3(0);

vec4 adsk_getDiffuseMapValue (in vec2 texCoord);
vec3 adsk_getDiffuseMapCoord();
vec4 adsk_getNormalMapValue (in vec2 texCoord);
vec3 adsk_getNormalMapCoord();
uniform vec2 adskUID_noffset;


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

    vec3 diffcoords = adsk_getDiffuseMapCoord();
    vec2 uv = diffcoords.xy / max(diffcoords.z, .000001);
    diffCol = adsk_getDiffuseMapValue(uv).rgb;

    vec3 diff = diffCol * nDotL;
    vec3 spec = ( nDotL > 0.0 && shininess > 0.0 ) ?
      specCol * max( pow( nDotH, shininess ), 0.0 ) : adskUID_zero;

    vec3 shadowCoeff = adsk_getComputedShadowCoefficient();
    vec3 res = source.rgb + shadowCoeff * adskUID_lightColor * shadowCoeff * ( diff + spec );


    res.rgb = vec3(.25);

    float here = dot(normal, eyeDir);

    if (here == 0.0) {
        res.r = 1.0;
    }

    res = abs(normalize(cross(eyeDir, normal)));
    if (abs(normal.r) > abs(normal.g) && abs(normal.r) > abs(normal.b)) {
        res = vec3(1.0, 0.0, 0.0);
    }
    if (abs(normal.g) > abs(normal.b) && abs(normal.g) > abs(normal.r)) {
        res = vec3(1.0, 0.0, 0.0);
    }
    if (abs(normal.b) > abs(normal.g) && abs(normal.b) > abs(normal.r)) {
        res = vec3(0.0, 0.0, 0.0);
    }

    //res = normal;



    return vec4( res, 1.0 );
}
