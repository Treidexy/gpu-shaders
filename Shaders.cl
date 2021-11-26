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

float3 __attribute__((overloadable)) rgb(float r, float g, float b) {
	return (float3) { r, g, b };
}

float3 __attribute__((overloadable)) rgb(int col) {
	return rgb(r(col), g(col), b(col));
}

int  __attribute__((overloadable)) color(float r, float g, float b) {
	int ir = r * 255;
	int ig = g * 255;
	int ib = b * 255;

	ir = min(max(ir, 0), 255);
	ig = min(max(ig, 0), 255);
	ib = min(max(ib, 0), 255);

	return (ir << 16) | (ig << 8) | (ib << 0);
}

int  __attribute__((overloadable)) color(float3 rgb) {
	return color(rgb.x, rgb.y, rgb.z);
}

float __attribute__((overloadable)) lerp(float a, float b, float t) {
	return a + t * (b - a);
}

float3 __attribute__((overloadable)) lerp(float3 a, float3 b, float t) {
	return a + t * (b - a);
}

uint hash(uint n) {
	n ^= 2747636419;
	n *= 2654435769;

	n ^= n >> 16;
	n *= 2654435769;

	n ^= n >> 16;
	n *= 2654435769;
	return n;
}

kernel void background(global int *pixels, int xOff, int yOff) {
	float y = get_global_id(0) + yOff;
	float x = get_global_id(1) + xOff;
	int i = y * width + x;

	pixels[i] = color(lerp(x / width, 0.12, 0.5), lerp(y / height, 0.12, 0.5), 0.6);
}

kernel void stars(global int *pixels, int xOff, int yOff, float2 delta, uint chance, float size) {
	float y = get_global_id(0) + yOff;
	float x = get_global_id(1) + xOff;
	int i = y * width + x;
	
	float dx = width / 2 - x;
	float dy = height / 2 - y;
	float d = dx*dx*dx * dy*dy*dy;
	float szo2 = (width + height) / 3.0f;
	float szcubed = szo2 * szo2 * szo2;
	if (fabs(d) < szcubed)
		pixels[i] = 0xFFFFFF;
	
/*
	float2 pos = (float2) { x + delta.x, y + delta.y };
	float2 localPos = fmod(pos, size);
	float2 scaledPos = pos - localPos + 1.0f;
	
	uint hx = hash(scaledPos.x);
	uint hy = hash(scaledPos.y);
	if (hx + hy < chance) {
		float dx = size / 2.0f - localPos.x;
		float dy = size / 2.0f - localPos.y;
		float dist = (dx * dx * dx * dx * dy * dy * dy * dy);
		float szo2 = size / 2.0f;
		float szcubed = szo2 * szo2 * szo2;
		if (dist < szcubed)
			pixels[i] = 0xFFFFFF;
	}
*/
}

kernel void waves(global int *pixels, int xOff, int yOff, float time, float surface, float nWaves, float waveHeight, float4 surfCol, float4 botmCol) {
	float y = get_global_id(0) + yOff;
	float x = get_global_id(1) + xOff;
	int i = y * width + x;

	float surf = surface + sin((x / width + time) * nWaves) * waveHeight;
	if (y < surf)
		return;

	float t = (y - surface) / (height - surface);
	pixels[i] = color(lerp(rgb(pixels[i]), lerp(surfCol.xyz, botmCol.xyz, t), lerp(surfCol.w, botmCol.w, t)));
}