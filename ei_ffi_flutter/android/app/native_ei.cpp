//#include "edge-impulse-sdk\classifier\ei_run_classifier.h"



//
// By making only one change to the code by uncommenting the above line results in:
//



/*
Launching lib\main.dart on Android SDK built for x86 in debug mode...
Running Gradle task 'assembleDebug'...

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:buildCMakeDebug[arm64-v8a]'.
> Build command failed.

  Error while executing process C:\Users\mmarc\AppData\Local\Android\sdk\cmake\3.10.2.4988404\bin\ninja.exe with arguments {-C C:\Downloads\Code\Flutter\Projects\ei_ffi_flutter\android\app\.cxx\Debug\30h622i1\arm64-v8a app}

  ninja: Entering directory `C:\Downloads\Code\Flutter\Projects\ei_ffi_flutter\android\app\.cxx\Debug\30h622i1\arm64-v8a'

  [1/2] Building CXX object CMakeFiles/app.dir/native_ei.cpp.o

  FAILED: CMakeFiles/app.dir/native_ei.cpp.o

  C:\Users\mmarc\AppData\Local\Android\Sdk\ndk\21.1.6352462\toolchains\llvm\prebuilt\windows-x86_64\bin\clang++.exe
  --target=aarch64-none-linux-android21
  --gcc-toolchain=C:/Users/mmarc/AppData/Local/Android/Sdk/ndk/21.1.6352462/toolchains/llvm/prebuilt/windows-x86_64
  --sysroot=C:/Users/mmarc/AppData/Local/Android/Sdk/ndk/21.1.6352462/toolchains/llvm/prebuilt/windows-x86_64/sysroot
  -Dapp_EXPORTS -I../../../../ei_include
  -g -DANDROID
  -fdata-sections
  -ffunction-sections
  -funwind-tables
  -fstack-protector-strong
  -no-canonical-prefixes
  -D_FORTIFY_SOURCE=2
  -Wformat
  -Werror=format-security
  -frtti -fexceptions
  -std=c++14
  -O0
  -fno-limit-debug-info
  -fPIC
  -std=gnu++14
  -MD
  -MT CMakeFiles/app.dir/native_ei.cpp.o
  -MF CMakeFiles\app.dir\native_ei.cpp.o.d
  -o CMakeFiles/app.dir/native_ei.cpp.o
  -c ../../../../native_ei.cpp

  In file included from ../../../../native_ei.cpp:1:

  In file included from ../../../../ei_include\edge-impulse-sdk\classifier\ei_run_classifier.h:52:

  ../../../../ei_include\edge-impulse-sdk/classifier/inferencing_engines/tflite_eon.h:166:44: error:
  no member named 'post_process_boxes' in namespace 'tflite'
      fill_result_struct_f32(result, tflite::post_process_boxes, tflite::post_process_scores, tflite::post_process_classes, debug);
                                     ~~~~~~~~^

  ../../../../ei_include\edge-impulse-sdk/classifier/inferencing_engines/tflite_eon.h:166:72: error:
  no member named 'post_process_scores' in namespace 'tflite'
      fill_result_struct_f32(result, tflite::post_process_boxes, tflite::post_process_scores, tflite::post_process_classes, debug);
                                                                 ~~~~~~~~^

  ../../../../ei_include\edge-impulse-sdk/classifier/inferencing_engines/tflite_eon.h:166:101: error:
  no member named 'post_process_classes' in namespace 'tflite'
      fill_result_struct_f32(result, tflite::post_process_boxes, tflite::post_process_scores, tflite::post_process_classes, debug);
                                                                                          ~~~~~~~~^
  3 errors generated.
  ninja: build stopped: subcommand failed.



* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.

* Get more help at https://help.gradle.org

BUILD FAILED in 7s
Exception: Gradle task assembleDebug failed with exit code 1
*/

extern "C" {
    double get_version()
    {
        return 0.1f;
    }
}
