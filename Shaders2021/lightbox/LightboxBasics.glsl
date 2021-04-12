uniform float adskUID_gain;


// Here is where the magic happens. 
// The vec4 below is including the RGB result provided from Action rendering as well as the Alpha of the Light which includes all the 3D info of the scene.
// The example below is showing a simple use case where we only modify the RGB data, but preserve the Alpha at the return function, which means we are still leveraging the Action lighting system by doing so.
// Overwriting the Alpha means that any other Lightbox following this one will received the new Alpha and no longer the one provided by the Light they are attached to, so you need to be cautious.
// Also overwriting the Alpha while still preserving 3D data will require to recompute everything yourself using the provided API which might means quite a lot of code.
//
//
//
vec3 adsk_getCameraPosition();
mat4 adsk_getModelViewMatrix();
mat4 adsk_getModelViewInverseMatrix();
vec3 adsk_getLightPosition();
vec3 adsk_getLightColour();
vec3 adsk_getNormal();
bool adsk_isPointSpotLight();
bool adsk_isDirectionalLight();
vec4 adsk_getMaterialAmbient();
vec4 adsk_getMaterialDiffuse();
vec3 adsk_getVertexPosition();
vec4 adsk_getMaterialSpecular();
float adsk_getShininess();

vec4 adskUID_lightbox( vec4 source ) {
    mat4 modelMatrix = adsk_getModelViewMatrix();
    mat4 modelMatrixInverse = adsk_getModelViewInverseMatrix(); // unity_Scale.w is unnecessary because we normalize vectors
    vec3 vertexPos = adsk_getVertexPosition();

    vec3 normalDirection = adsk_getNormal();
    vec3 viewDirection = adsk_getCameraPosition() - vertexPos;
    vec3 lightDirection;
    float attenuation;

    vec3 _WorldSpaceLightPos0 = adsk_getLightPosition();


    if ( adsk_isDirectionalLight() ) {  // directional light?  
        attenuation = 1.0; // no attenuation
        lightDirection = normalize(_WorldSpaceLightPos0 - vertexPos);
    } else {// point or spot light
        vec3 vertexToLightSource = vec3( _WorldSpaceLightPos0 - adsk_getVertexPosition() );
        float distance = length(vertexToLightSource);
        attenuation = 1.0 / distance; // linear attenuation
        lightDirection = normalize(vertexToLightSource);
    }

    vec3 _Color = adsk_getMaterialDiffuse();
    vec3 _LightColor0 = adsk_getLightColour();

    vec3 ambientLighting = adsk_getMaterialAmbient().rgb * _Color;
        
    vec3 diffuseReflection = attenuation * vec3(_LightColor0) * _Color * max(0.0, dot(normalDirection, lightDirection));

    vec3 specularReflection;
    vec4 _SpecColor = adsk_getMaterialSpecular();
    float _Shininess =  adsk_getShininess();
    
    
    if (dot(normalDirection, lightDirection) < 0.0) { // light source on the wrong side?
        specularReflection = vec3(0.0, 0.0, 0.0); // no specular reflection
    } else { // light source on the right side
        specularReflection = attenuation * _LightColor0.rgb * _SpecColor.rgb * pow(max(0.0, dot( reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
    }

    vec4 color = vec4(ambientLighting + diffuseReflection + specularReflection, 1.0);

    return vec4(color.rgb * vec3(source.a), source.a );
}
