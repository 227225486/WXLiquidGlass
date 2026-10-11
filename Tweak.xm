Run export THEOS="$HOME/theos"
==> Cleaning…
==> Notice: Build may be slow as Theos isn’t using all available CPU cores on this computer. Consider upgrading GNU Make: https://theos.dev/docs/parallel-building
> Making all for tweak LiquidGlassHook…
==> Preprocessing Tweak.xm…
==> Compiling Tweak.xm (arm64)…
In file included from Tweak.xm:28:
/Users/runner/theos/vendor/include/rootless.h:1:1: error: redundant #include of module '_DarwinFoundation1.TargetConditionals' appears within function 'lg_loadPrefs' [-Wmodules-import-nested-redundant]
    1 | #include <TargetConditionals.h>
      | ^
Tweak.xm:25:1: note: function 'lg_loadPrefs' begins here
   25 | static void lg_loadPrefs(void) {
      | ^
In file included from Tweak.xm:28:
/Users/runner/theos/vendor/include/rootless.h:5:1: fatal error: import of module 'libroot' appears within function 'lg_loadPrefs'
    5 | #include <libroot/libroot.h>
      | ^
Tweak.xm:25:1: note: function 'lg_loadPrefs' begins here
   25 | static void lg_loadPrefs(void) {
      | ^
2 errors generated.
make[3]: *** [/Users/runner/work/WXLiquidGlass/WXLiquidGlass/.theos/obj/arm64/Tweak.xm.c2f0d895.o] Error 1
rm /Users/runner/work/WXLiquidGlass/WXLiquidGlass/.theos/obj/arm64/Tweak.xm.mm
make[2]: *** [/Users/runner/work/WXLiquidGlass/WXLiquidGlass/.theos/obj/arm64/LiquidGlassHook.dylib] Error 2
make[1]: *** [internal-library-all_] Error 2
make: *** [LiquidGlassHook.all.tweak.variables] Error 2
Error: Process completed with exit code 2.