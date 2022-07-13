import 'dart:ffi' as ffi;
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

typedef VersionFunction = Double Function();
typedef VersionFunctionDart = double Function();

class FFIBridge {
  VersionFunctionDart? _getVersion;

  FFIBridge() {
    final dl = Platform.isAndroid
        ? DynamicLibrary.open('libapp.so')
        : DynamicLibrary.process();
    _getVersion =
        dl.lookupFunction<VersionFunction, VersionFunctionDart>('get_version');
  }
  double getAppVersion() => _getVersion!();
}
