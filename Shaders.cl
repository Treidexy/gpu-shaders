constant int width = 600, height = 600;

kernel void background(global int *pixels, int xOff, int yOff) {
	int y = (int) get_global_id(0) + yOff;
	int x = (int) get_global_id(1) + xOff;
	pixels[y * width + x] += 0x010101;
}