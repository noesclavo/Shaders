uniform float     adsk_result_w, adsk_result_h;
uniform sampler2D adsk_texture_grid;

uniform int streaks;
uniform int spikes;
uniform int rings;
uniform int lights;
uniform int iris;
uniform int caustics;
uniform int type;
uniform int selection;
uniform float ratio;

#define HALF_PIXEL 0.5

// These 2 lines define the texture grid resolution and tile resolution
const vec2 tileSize = vec2(1024, 1024);
const vec2 gridSize = vec2(11264, 9216);

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

    return texture2D( adsk_texture_grid, positionInGrid );
}


void main() {
    vec2 resolution = vec2(adsk_result_w, adsk_result_h);
    vec2 position = vec2(gl_FragCoord.xy / resolution.xy);

    position -= vec2(.5);
    position.y *= ratio;
    position += vec2(.5);


    vec4 tileResult = fetchInTile(gridSize, tileSize, getTilePosition(gridSize,tileSize,type), position*tileSize);


    if (type == 93 && streaks != 9) { // Streaks
        tileResult = fetchInTile(gridSize, tileSize, getTilePosition(gridSize,tileSize,streaks), position*tileSize);
    }

    if (type == 92 && spikes != 9) { // Spikes
        tileResult = fetchInTile(gridSize, tileSize, getTilePosition(gridSize,tileSize,spikes), position*tileSize);
    }

    if (type == 91 && rings != 9) { // Rings
        tileResult = fetchInTile(gridSize, tileSize, getTilePosition(gridSize,tileSize,rings), position*tileSize);
    }

    if (type == 90 && lights != 9) { // Light
        tileResult = fetchInTile(gridSize, tileSize, getTilePosition(gridSize,tileSize,lights), position*tileSize);
    }

    if (type == 89 && iris != 9) { // Iris
        tileResult = fetchInTile(gridSize, tileSize, getTilePosition(gridSize,tileSize,iris), position*tileSize);
    }

    if (type == 88 && caustics != 9) { // Caustics
        tileResult = fetchInTile(gridSize, tileSize, getTilePosition(gridSize,tileSize,caustics), position*tileSize);
    }

   gl_FragColor = tileResult;
}
