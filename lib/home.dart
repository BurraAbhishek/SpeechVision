import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = true;
  File _image;
  List _output;
  final picker = ImagePicker();
  @override
  void initState(){
    super.initState();
    loadModel().then((value){
      setState(() {});
    });
  }
  @override
  // Dispose the image and prepare for the next instance
  void dispose() {
    super.dispose();
    Tflite.close();
  }
  // Classify the image using the trained model
  classifyImage(File image) async {
    var output = await Tflite.detectObjectOnImage(
        path: image.path,       // required
        //path: "assets/download.jpeg",
        model: "SSDMobileNet",
        imageMean: 127.5,
        imageStd: 127.5,
        threshold: 0.4,       // defaults to 0.1
        numResultsPerClass: 2,// defaults to 5
        asynch: true          // defaults to true
    );
    setState(() {
      _output = output;
      _loading = false;
    });
  }
  // Load the model into the running instance
  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/ssd_mobilenet_v1_1_metadata_1.tflite',
      labels: 'assets/ssd_mobilenet_labels.txt',
    );
  }
  // Capture an image from the camera
  pickImage() async {
    var image = await picker.getImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
    });
    classifyImage(_image);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
        'SpeechVision',
        style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 24,
        letterSpacing: 0.8),
    ),),
        body: Container(
        color: Colors.blue.withOpacity(0.9),
    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 50),
    child: Container(
    alignment: Alignment.center,
    padding: EdgeInsets.all(30),
    decoration: BoxDecoration(
    color: Color(0xFF2A363B),
    borderRadius: BorderRadius.circular(30),
    ),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Container(
    child: Center(
    child: _loading == true
    ? null //show nothing if no picture selected
        : Container(
    child: Column(
    children: [
    Container(
    height: 250, width: 250,
    child: ClipRRect(       borderRadius:
    BorderRadius.circular(30),
      child: Image.file(
        _image,
        fit: BoxFit.fill,
      ),),),
      Divider(
        height: 25,thickness: 1,
      ),
      _output != null
          ? Text(
        'The object is: ${_output[0]['detectedClass']}!',
        //'The object is: ${jsonEncode(_output)}',
        style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight:
            FontWeight.w400),
      )
          : Container(),
      Divider(
        height: 25,
        thickness: 1,
      ),],),),),),
      Container(
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage, //no parenthesis
              child: Container(
                width:
                MediaQuery.of(context).size.width - 200,
                alignment: Alignment.center,
                padding:
                EdgeInsets.symmetric(horizontal: 24,
                    vertical: 17),
                decoration: BoxDecoration(
                    color: Colors.blueGrey[600],
                    borderRadius:
                    BorderRadius.circular(15)),
                child: Text(
                  'Take A Photo',
                  style: TextStyle(color: Colors.white,
                      fontSize: 16),
                ),),),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    ],),
    ),
        ),
    );
  }
}