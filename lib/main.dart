import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'vision_detector_views/face_detector_view.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Voter Registration',
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool hidePass = true;
  bool hideConfirmPass = true;
  late List<InputImage> images = [];
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final neededImages = 5;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Voter Registration'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _form,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.account_circle),
                        border: OutlineInputBorder(),
                        hintText: 'Student number',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _pass,
                      decoration: InputDecoration(
                        suffixIcon: InkWell(
                          child: Icon(hidePass?Icons.visibility_rounded:Icons.visibility_off_rounded),
                          onTap: () {
                            setState(() {
                              hidePass = !hidePass;
                            });
                          },
                        ),

                        border: OutlineInputBorder(),
                        hintText: 'Password',
                      ),
                      obscureText: hidePass,
                      enableSuggestions: true,

                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        else if(value.length<8){
                          return 'At least 8 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _confirmPass,
                      decoration: InputDecoration(
                        suffixIcon: InkWell(
                          child: Icon(hideConfirmPass?Icons.visibility_rounded:Icons.visibility_off_rounded),
                          onTap: () {
                            setState(() {
                              hideConfirmPass = !hideConfirmPass;
                            });
                          },
                        ),

                        border: OutlineInputBorder(),
                        hintText: 'Confirm Password',
                      ),
                      obscureText: hideConfirmPass,
                      enableSuggestions: true,

                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        if(value != _pass.text)
                          return 'Passwords do not match';
                        else if(value.length<8){
                          return 'At least 8 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 5.0),
                  InkWell(
                    onTap: () {
                      if (_form.currentState!.validate()) {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) =>
                                FaceDetectorView(
                                  neededImages: neededImages,
                                  setImages: (List<InputImage> confirmedImages) {
                                    setState(() {
                                      images = confirmedImages;
                                    });
                                  },))
                        );
                      }
                    },
                    child: Column(
                      children: [
                        Image.asset('assets/face.jpeg'),
                        Text('Scan Face', style: TextStyle(fontSize: 18),),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  (images.length>=neededImages && _form.currentState!.validate())?
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(Colors.blue)
                      ),
                      onPressed: (){
                          log(images[4].toJson().toString());
                      },
                      child: Text('Submit', style: TextStyle(color: Colors.white, fontSize: 22))
                  ):Text('')
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
