constant float width = 600, height = 600;

float r(int col) {
	float x = col >> 16 & 0xFF;
	return x / 255;
}

float g(int col) {
	float x = col >> 8 & 0xFF;
	return x / 255;
}

float b(int col) {
	float x = col >> 0 & 0xFF;
	return x / 255;
}

int rgb(float r, float g, float b) {
	int ir = r * 255;
	int ig = g * 255;
	int ib = b * 255;

	ir = min(max(ir, 0), 255);
	ig = min(max(ig, 0), 255);
	ib = min(max(ib, 0), 255);

	return (ir << 16) | (ig << 8) | (ib << 0);
}

float lerp(float a, float b, float t) {
	return a + t * (b - a);
}

kernel void background(global int *pixels, int xOff, int yOff) {
	float y = get_global_id(0) + yOff;
	float x = get_global_id(1) + xOff;
	int i = y * width + x;

	pixels[i] = rgb(lerp(x / width, 0.12, 0.5), lerp(y / height, 0.12, 0.5), 0.6);
}