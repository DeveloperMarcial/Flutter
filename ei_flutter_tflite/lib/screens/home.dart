// https://medium.com/analytics-vidhya/integrating-tensorflowlite-with-flutter-for-computer-vision-6c82d1e5bccd
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'camerascreen.dart';

// The app has a simple app bar and a bottom bar which shows the predictions.
class MyHomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  MyHomePage(this.cameras);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String predOne = '';

  @override
  void initState() {
    super.initState();
    loadTfliteModel();
  }

/*
  loadTfliteModel() async {
    print("Loading TF Model...........................................................");
    String? res;
    res = await Tflite.loadModel(
      model: "assets/ei-cup-transfer-learning-tensorflow-lite-int8-quantized-model.tflite",
      labels: "assets/Labels.txt",
    );
    String result = "---------------------------------------" + res!;
    print("Response: TF Model Load $res");
    //print(result);
  }
  */
  Future loadTfliteModel() async {
    Tflite.close();
    try {
      String? res;
      res = await Tflite.loadModel(
        model: "assets/ei-cup-transfer-learning-tensorflow-lite-int8-quantized-model.tflite",
        labels: "assets/Labels.txt",
      );
      print(res);
    } on PlatformException {
      print('Failed to load model..............................');
    }
  }

  setRecognitions(outputs) {
    setState(() {
      predOne = outputs[0]['label'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "TensorFlow Lite App",
        ),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          // We pass this widget the “setRecognitions” callback,
          // as we want to pass the output to the home page where
          // we assign the label to a variable and then display that variable as the prediction.
          Camera(widget.cameras, setRecognitions),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100.0,
              decoration: BoxDecoration(color: Colors.blueGrey, boxShadow: [BoxShadow(color: Colors.black, blurRadius: 20.0)], borderRadius: BorderRadius.only(topLeft: Radius.circular(50.0), topRight: Radius.circular(50.0))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 30.0,
                  ),
                  Text(
                    "$predOne",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
