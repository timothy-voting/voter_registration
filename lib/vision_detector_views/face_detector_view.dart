import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'camera_view.dart';
import 'painters/face_detector_painter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';


class FaceDetectorView extends StatefulWidget {
  const FaceDetectorView({super.key, required int this.neededImages, required this.setPaths});
  final int neededImages;
  final void Function(List<String> imgPaths) setPaths;

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
  List<String> _imgPaths = [];

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
      onImage: (path, inputImage, isRecording, stop) {
        processImage(path, inputImage, isRecording, stop);
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

    return dir+Uuid().v4()+'.jpg';
  }

  Future<String> saveImage(Uint8List imageData) async {
    String filePath = await getImagePath();
    File file = File(filePath);
    await file.writeAsBytes(imageData);
    return filePath;
  }

  Future<void> processImage(String? imgPath, InputImage inputImage, bool isRecording, Function stop) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });

    final List<Face> faces = await _faceDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = FaceDetectorPainter(
          faces,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);
    }

    if (faces.length == 1 && isRecording) {
      if (imgPath != null) {
        _imgPaths.add(imgPath);
      }
      if (_imgPaths.length >= widget.neededImages) {
        widget.setPaths(_imgPaths);
        stop();
        Navigator.of(context).pop();
      }
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
