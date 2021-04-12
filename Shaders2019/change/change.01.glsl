#version 120

#define PI 3.1415926535897932
#define fratio adsk_result_frameratio
#define pratio adsk_result_pixelratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Grid;
uniform int start_amount;
uniform int x;
uniform vec2 bla;

#define HALF_PIXEL 0.5
const vec2 tileSize = vec2(512.0, 512.0);
const vec2 gridSize = vec2(512.0 * 10.0, 512.0);

vec2 getTilePosition( vec2 gridSize, vec2 tileSize, int tileNum ) {
   // compute the actual number of tiles per grid row and column
   ivec2 nbTiles = ivec2(gridSize)/ivec2(tileSize);
   
   // compute the tile position in the grid from its index
   vec2 tile = vec2(mod(float(tileNum), float(nbTiles.x)),float(tileNum/nbTiles.x));
   
   return tile*tileSize;
}

vec4 fetchInTile( vec2 gridSize, vec2 tileSize, vec2 tilePosition, vec2 positionInTile ) {
   // add a slack of HALF_PIXEL to prevent fetching the border of the tile
   // it avoids interpolatingon with the adjacent tile
    if ( any(greaterThan(positionInTile,tileSize-vec2(1.0+HALF_PIXEL))) ||
        any(greaterThan(vec2(HALF_PIXEL),positionInTile)) ) {
        return vec4(0.0);
    }

    // compute the normalized coords of tile pixel to be
    // fetched within the grid
    vec2 positionInGrid = (tilePosition+positionInTile)/gridSize;

    return texture2D( Grid, positionInGrid );
}


void main() {
    vec2 resolution = vec2(adsk_result_w, adsk_result_h);
    vec2 position = vec2(gl_FragCoord.xy / resolution.xy);

    position -= vec2(.5);
    position.y *= 1.0/adsk_result_frameratio;
    position += vec2(.5);

    vec4 tileResult = vec4(0.0);

    float k = 512.0 * texel.x;
    vec2 tile_pos = vec2(0.0);

    int start = int(start_amount * .001);
    tile_pos =  getTilePosition(gridSize,tileSize,start - 1);
    tileResult = fetchInTile(gridSize, tileSize, tile_pos, position * tileSize);
    
    gl_FragColor = tileResult;
}


