#version 120

#define PI 3.141592653589793238462643383279502884197969

uniform float adsk_result_w, adsk_result_h;

uniform sampler2D adsk_results_pass1;
uniform bool recombine;

void main(void) {
	// Stolen from Lewis Saunders

	vec2 xy = gl_FragCoord.xy;
	vec2 px = vec2(1.0) / vec2(adsk_result_w, adsk_result_h);

	float sigma = 20.0;
	int support = int(sigma * 3.0);

	// Incremental coefficient calculation setup as per GPU Gems 3
	vec3 g;
	g.x = 1.0 / (sqrt(2.0 * PI) * sigma);
	g.y = exp(-0.5 / (sigma * sigma));
	g.z = g.y * g.y;

	if(sigma == 0.0) {
		g.x = 1.0;
	}

	// Centre sample
	vec4 a = g.x * texture2D(adsk_results_pass1, xy * px);
	float energy = g.x;
	g.xy *= g.yz;

	// The rest
	for(int i = 1; i <= support; i++) {
		a += g.x * texture2D(adsk_results_pass1, (xy - vec2(float(i), 0.0)) * px);
		a += g.x * texture2D(adsk_results_pass1, (xy + vec2(float(i), 0.0)) * px);
		energy += 2.0 * g.x;
		g.xy *= g.yz;
	}

	a /= energy;

	gl_FragColor = a;
}
