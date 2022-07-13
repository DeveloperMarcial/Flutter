# ei_ffi_flutter

Test project to see how to include the Edge Impulse C++ library into Flutter.

However, the Edge Impulse C++ library will not compile in.

To reproduce the problem:
In file `"native_ei.cpp"` un-rem line:
`//#include "edge-impulse-sdk\classifier\ei_run_classifier.h"`

The complete error text is in a comment at the top of file `"native_ei.cpp"`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
