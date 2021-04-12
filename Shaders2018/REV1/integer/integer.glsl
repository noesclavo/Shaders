#version 120

uniform int hdr;
uniform int maxitems;

void main(void) {
	int HDR = hdr;
	if (HDR > maxitems) {
		HDR = maxitems - 1
	}

	vec4 col = vec4(0.0) + vec4(float(HDR));

	gl_FragColor = col;
}
