import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Center(child: Text('I am Poor Git')),
        backgroundColor: Colors.amber[900],
      ),
      body: Center(
        //child: const Image(
        //    image: NetworkImage(
        //        'https://www.imore.com/sites/imore.com/files/images/stories/2008/08/iamrichscreen_2.jpg')),
        child: const Image(
            image: AssetImage('images/640-close-up-of-empty-wallet.JPG')),
      ),
      backgroundColor: Colors.amber,
    ),
  ));
} // 'images/640-close-up-of-empty-wallet.JPG'
//'images/diamond.png'
