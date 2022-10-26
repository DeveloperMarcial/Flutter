import 'package:flutter/material.dart';
import 'package:ei_flutter_tflite/screens/home.dart';
import 'package:camera/camera.dart';

//This code just get the list of all the cameras from the device and put them in a list so that we can use whichever camera we want.
List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyHomePage(
      cameras,
    ),
  ));
}
