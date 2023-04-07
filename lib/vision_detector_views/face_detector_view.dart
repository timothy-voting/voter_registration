import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'camera_view.dart';
import 'painters/face_detector_painter.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';


class FaceDetectorView extends StatefulWidget {
  const FaceDetectorView({super.key, required int this.neededImages, required this.setImages});
  final int neededImages;
  final void Function(List<InputImage> confirmedImages) setImages;

  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  List<InputImage> _confirmedImages = [];

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      customPaint: _customPaint,
      text: _text,
      onImage: (inputImage, isRecording, stop) {
        processImage(inputImage, isRecording, stop);
      },
      initialDirection: CameraLensDirection.front,
    );
  }

  Future<String?> getStorageDirectory() async {
      return (await getApplicationDocumentsDirectory()).path;
  }

  Future<String> getImagePath() async {
    final dir = (await getStorageDirectory()).toString()+'/images/';
    if(!(await Directory(dir).exists())) {
      await Directory(dir).create(recursive: true);
    }
    // log((await (await (await new Directory(dir)).list()).length).toString());
    return dir+Uuid().v4()+'.png';
  }

  Future<void> processImage(InputImage inputImage, bool isRecording, Function stop) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final faces = await _faceDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = FaceDetectorPainter(
          faces,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);

      if(faces.length==1 && isRecording){






        //first send this file to server

        // img.Command().executeThread()
        // img.Image? src = ((await img.Command()..decodeImage(inputImage.bytes!)..executeThread()).outputImage);

        // Image src = Image.memory(inputImage.bytes!);

        // -----------
        // File imgFile = File(image_path);
        // imgFile.writeAsBytes(inputImage.bytes!.toList());
        // File('/data/user/0/com.voter_registration.voter_registration/app_flutter/fe49bd0e-7108-4313-8cd1-a1cb8dd087d6.png').readAsBytesSync();
        //------------

        // Image.
        // img.Image destImage = img.copyCrop(img.Image.empty(), x: faces.last.headEulerAngleX!.toInt(), y:faces.last.headEulerAngleY!.toInt(), width: faces.last.boundingBox.width.toInt(), height: faces.last.boundingBox.height.toInt());
        // log((src == null)?'null':'not');


        // ((img.Command()..decodeImage(inputImage.bytes!)).execute());
        // log((inputImage.bytes == null)?'null':'not');
        // pass x and y(offset),width, height value of face bounding box you detected
        // img.Image destImage = img.copyCrop(src!, x: faces.last.headEulerAngleX!.toInt(), y:faces.last.headEulerAngleY!.toInt(), width: faces.last.boundingBox.width.toInt(), height: faces.last.boundingBox.height.toInt());
        // log('message');
        // final png = img.encodePng(destImage);
        // var f = await File(getStorageDirectory().toString()+Uuid().v4()+'.png').writeAsBytes(png);
        // log(f.path);

        // On platforms that support Isolates, execute the image commands asynchronously on an isolate thread.
        // Otherwise, the commands will be executed synchronously.
        // final jk = await cmd.executeThread();
        // jk.

        // final cmd = img.Command()..decodeImage(inputImage.bytes!);
        // img.Command lop = await cmd.executeThread();
        // // cmd.outputImage
        // if(inputImage.bytes == null){
        //   log('null');
        // }else{
        //   log('image exists');
        // }

        //pass x and y(offset),width, height value of face bounding box you detected
        // img.Image destImage = img.copyCrop((img.Command()..decodeImage(inputImage.bytes!)).outputImage!, x: faces.last.headEulerAngleX!.toInt(), y:faces.last.headEulerAngleY!.toInt(), width: faces.last.boundingBox.width.toInt(), height: faces.last.boundingBox.height.toInt());
        // log(destImage.height.toString());


        // _confirmedImages.add(inputImage);
        // if(_confirmedImages.length>=widget.neededImages){
        //   widget.setImages(_confirmedImages);
        //   stop();
        //   Navigator.of(context).pop();
        // }
      }
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
