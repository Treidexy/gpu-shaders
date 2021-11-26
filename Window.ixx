export module Window;

#include <Windows.h>
#include <cstring>
#include <cassert>

void Init();
void Draw();

HWND wnd;

using uint = unsigned;

template<typename T>
void memset(T* ptr, T val, size_t len)
{
	for (size_t i = 0; i < len; i++)
		ptr[i] = val;
}

uint* pixels;
HDC bmpDc;

enum
{
	width = 600,
	height = 600,
};

LRESULT MyWndProc(HWND wnd, UINT msg, WPARAM wp, LPARAM lp)
{
	switch (msg)
	{
	case WM_CLOSE:
	case WM_DESTROY:
		ExitProcess(0);
		break;

		//case WM_PAINT:
		//{
		//	PAINTSTRUCT ps;
		//	HDC dc = BeginPaint(wnd, &ps);
		//	BitBlt(dc, 0, 0, width, height, bmpDc, 0, 0, SRCCOPY);
		//	break;
		//}

	default:
		return DefWindowProcW(wnd, msg, wp, lp);
	}

	return 0;
}

void CheckMsg()
{
	static MSG msg;
	while (PeekMessageW(&msg, wnd, 0, 0, PM_REMOVE | PM_NOYIELD))
	{
		TranslateMessage(&msg);
		DispatchMessageW(&msg);
	}
}

export void Exit()
{
	CloseWindow(wnd);
}

int main()
{
	WNDCLASSEXW clazz = {
		.cbSize = sizeof(WNDCLASSEXW),
		.lpfnWndProc = MyWndProc,
		.lpszClassName = L"test",
	};

	RegisterClassExW(&clazz);

	wnd = CreateWindowExW(0, clazz.lpszClassName, L"Gpu Shaders", WS_SYSMENU | WS_MINIMIZEBOX | WS_VISIBLE,
		CW_USEDEFAULT, CW_USEDEFAULT, width, height, NULL, NULL, NULL, NULL);

	BITMAPINFO bmpInfo = {
		.bmiHeader = {
			.biSize = sizeof(BITMAPINFO),
			.biWidth = width,
			.biHeight = -height,
			.biPlanes = 1,
			.biBitCount = 32,
			.biCompression = BI_RGB,
		}
	};

	HDC dc = GetDC(wnd);
	HBITMAP bmp = CreateDIBSection(dc, &bmpInfo, DIB_RGB_COLORS, (void**)&pixels, NULL, 0);
	assert(bmp);
	bmpDc = CreateCompatibleDC(dc);
	assert(bmpDc);
	SelectObject(bmpDc, bmp);

	CheckMsg();
	Init();

	while (true)
	{
		CheckMsg();

		Draw();

		BitBlt(dc, 0, 0, width, height, bmpDc, 0, 0, SRCCOPY);
		Sleep(50);
	}

	DeleteDC(bmpDc);
	ReleaseDC(wnd, dc);
	DestroyWindow(wnd);
	UnregisterClassW(clazz.lpszClassName, NULL);
}