#ifndef NO_CGO_LIB

__pragma(comment(lib, "legacy_stdio_definitions.lib"));

// https://github.com/golang/go/issues/42190#issuecomment-1507839987
void _rt0_amd64_windows_lib();

__pragma(section(".CRT$XCU", read));
__declspec(allocate(".CRT$XCU")) void (*init_lib)() = _rt0_amd64_windows_lib;

__pragma(comment(linker, "/include:init_lib"));

#endif