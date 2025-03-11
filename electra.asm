.386
.model flat, stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\gdi32.lib

.data
msgTitle db "Electra", 0
windowClass db "MyWindowClass", 0
editControl db "EDIT", 0

wc WNDCLASSEX <>
msg MSG <>
hwndMain DWORD ?
hwndEdit DWORD ?
hInstance DWORD ?

.code
WndProc PROTO :DWORD, :DWORD, :DWORD, :DWORD

start:
    invoke GetModuleHandle, NULL
    mov hInstance, eax
    
    invoke RtlZeroMemory, addr wc, sizeof WNDCLASSEX
    mov wc.cbSize, sizeof WNDCLASSEX
    mov wc.style, CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc, offset WndProc
    mov wc.lpszClassName, offset windowClass
    mov wc.hInstance, eax
    mov wc.hbrBackground, COLOR_WINDOW+1
    invoke RegisterClassEx, addr wc

    invoke CreateWindowEx, 0, 
                         offset windowClass, 
                         offset msgTitle, 
                         WS_OVERLAPPEDWINDOW, 
                         CW_USEDEFAULT, 
                         CW_USEDEFAULT, 
                         600, 
                         400, 
                         0, 0, hInstance, 0
    mov hwndMain, eax

    invoke CreateWindowEx, WS_EX_CLIENTEDGE, 
                         offset editControl, 
                         0, 
                         WS_CHILD or WS_VISIBLE or WS_VSCROLL or ES_MULTILINE or ES_AUTOVSCROLL, 
                         10, 10, 560, 340, 
                         hwndMain, 101, hInstance, 0
    mov hwndEdit, eax

    invoke SendMessage, hwndEdit, EM_SETLIMITTEXT, 0, 0

    invoke SetWindowPos, hwndMain, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE

    invoke ShowWindow, hwndMain, SW_SHOWNORMAL
    invoke UpdateWindow, hwndMain

    .WHILE TRUE
        invoke GetMessage, addr msg, 0, 0, 0
        .BREAK .IF eax == 0
        invoke TranslateMessage, addr msg
        invoke DispatchMessage, addr msg
    .ENDW

    invoke ExitProcess, 0

WndProc proc hwnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    LOCAL rect:RECT
    
    .if uMsg == WM_SIZE
        invoke GetClientRect, hwnd, addr rect
        
        mov eax, rect.right
        sub eax, 20     
        
        mov ebx, rect.bottom
        sub ebx, 20     
        
        invoke MoveWindow, hwndEdit, 10, 10, eax, ebx, TRUE
        
        invoke SetWindowPos, hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE
        
    .elseif uMsg == WM_DESTROY
        invoke PostQuitMessage, 0
        xor eax, eax
        
    .else
        invoke DefWindowProc, hwnd, uMsg, wParam, lParam
        ret
    .endif
    
    xor eax, eax
    ret
WndProc endp

end start