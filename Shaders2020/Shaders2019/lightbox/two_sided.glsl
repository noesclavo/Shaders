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
uniform bool adskUID_bla;

const vec3 adskUID_zero = vec3(0);

vec4 adskUID_lightbox( vec4 source )
{
   vec3 vertexPos = adsk_getVertexPosition();
   vec3 lightPos = adsk_getLightPosition();

   vec3 normal = adsk_getNormal();
   vec3 eyeDir = adsk_getCameraPosition() - vertexPos;

   vec3 color = adskUID_lightColor;
   if ((normal.b < 0.0) && (adskUID_bla)) {
       color = vec3(1.0) - color;
   }

   normal.b = abs(normal.b);


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
   vec3 res = source.rgb + shadowCoeff * color * shadowCoeff * ( diff + spec );

   return vec4( res, 1.0 );
}
