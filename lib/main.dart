import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'fingerprint.dart';
import 'vision_detector_views/face_detector_view.dart';
import 'package:http/http.dart' as http;

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
  List<String> imagePaths = [];
  String fingerPrintImagePath = "";
  String _faceValidationText = "";
  String _fingerValidationText = "";
  final TextEditingController _studentNumber = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final neededImages = 5;
  List<int> storedImageIds = [];
  List<int> storedFingerIds = [];
  Map<String, String> headers = {
    "Content-type": "application/json",
    "Accept": "application/json",
    'X-Requested-With': 'XMLHttpRequest'
  };
  final String address = "http://104.248.63.15/api/";

  _reset(){
    setState(() {
      hidePass = true;
      hideConfirmPass = true;
      imagePaths = [];
      fingerPrintImagePath = "";
      _studentNumber.clear();
      _pass.clear();
      _confirmPass.clear();
      storedImageIds = [];
    });
  }

  Future<bool> _checkStudent() async {
    bool isStudent = false;
    try {
      var response = await http.get(
          Uri.parse(address+'is_student?student_no='+_studentNumber.text),
          headers: headers
      );
      if(response.statusCode == 200){
        isStudent = (jsonDecode(response.body) as Map<String, dynamic>)["isStudent"] as bool;
        if(!isStudent)
          _snackBarAlert('The student number is unknown');
      }else{
        _snackBarAlert(response.body);
      }
    } catch(e) {
      _snackBarAlert(e.toString());
    }
    return isStudent;
  }

  Future<void> _sendFaces() async {
    List<int> imageIds = storedImageIds.toList();
    List<String> imgPaths = imagePaths.toList();

    imgPaths.forEach((path) async {
      try {
        var request = http.MultipartRequest(
            'POST', Uri.parse(address+'face'));
        request.files.add(await http.MultipartFile.fromPath('file', path));

        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          Map<String, dynamic> resp = jsonDecode(
              await response.stream.bytesToString()) as Map<String, dynamic>;
          imageIds.add(resp['id'] as int);
          imgPaths.remove(path);
          setState(() {
            storedImageIds = imageIds;
            imagePaths = imgPaths;
          });
        }
        else {
          _snackBarAlert(response.reasonPhrase ?? '');
        }
      }
      catch (e) {
        _snackBarAlert('error: ' + e.toString());
      }
    });
  }

  Future<void> _sendFingerPrint() async {
      try {
        var request = http.MultipartRequest(
            'POST', Uri.parse(address+'fingerprint'));
        request.files.add(await http.MultipartFile.fromPath('file', fingerPrintImagePath));

        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          Map<String, dynamic> resp = jsonDecode(
              await response.stream.bytesToString()) as Map<String, dynamic>;
          setState(() {
            storedFingerIds = [(resp['id'] as int)];
            fingerPrintImagePath = "";
          });
        }
        else {
          _snackBarAlert(response.reasonPhrase ?? '');
        }
      }
      catch (e) {
        _snackBarAlert('error: ' + e.toString());
      }
  }

  _sendCredentials() async {
    try {
      var response = await http.post(
          Uri.parse(address+'register'),
          headers: headers,
          body: jsonEncode({
            'student_no': _studentNumber.text,
            'password': _pass.text,
            'password_confirmation': _confirmPass.text,
            'faces': storedImageIds,
            'fingerprints': storedFingerIds
          })
      );
      if(response.statusCode == 200){
        _snackBarAlert('Student registered successfully');
        _reset();
      }
      else{
        _snackBarAlert(response.body);
      }
    } catch (e) {
      _snackBarAlert(e.toString());
    }
  }

  bool _validate(){
    bool formValidated = _form.currentState!.validate();
    bool facesValidated = imagePaths.length>=neededImages;
    bool fingerPrintValidated = fingerPrintImagePath.length>3;
    setState(() {
      _faceValidationText = facesValidated?'':'Please scan';
      _fingerValidationText = fingerPrintValidated?'':'Please scan';
    });
    return formValidated && facesValidated && fingerPrintValidated;
  }

  _post() async {
    if(_validate()) {
      _checkStudent().then((isStudent) {
        if (isStudent) {
          _sendFingerPrint().then((value){
            _sendFaces().then((value) {
              Timer.periodic(Duration(milliseconds: 500), (timer) {
                if (storedImageIds.length == 5 && storedFingerIds.length == 1) {
                  timer.cancel();
                  _sendCredentials();
                }
              });
            });
            // _sendCredentials(imageIds);
          });
        }
      });
    }
  }

  _snackBarAlert(String message){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

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
                      controller: _studentNumber,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) =>
                                    FaceDetectorView(
                                      neededImages: neededImages,
                                      setPaths: (List<String> imgPaths) {
                                        setState(() {
                                          imagePaths = imgPaths;
                                        });
                                      },))
                            );
                        },
                        child: Column(
                          children: [
                            Image.asset('assets/face.jpeg', width: 100, height: 100,),
                            Text('Scan Face', style: TextStyle(fontSize: 18)),
                            (imagePaths.length>=neededImages)?
                            Icon(Icons.check_circle, color: Colors.green):
                            Icon(Icons.circle_outlined),
                            Text(_faceValidationText, style: TextStyle(fontSize: 14, color: Colors.red)),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      InkWell(
                        onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => FingerPrint(
                                  setFilePath: (String filePath) {
                                      setState(() {
                                        fingerPrintImagePath = filePath;
                                      });
                                  })
                            )
                            );
                        },
                        child: Column(
                          children: [
                            Icon(Icons.fingerprint, color: Color(0xff565656), size: 100,),
                            Text('Scan Fingerprint', style: TextStyle(fontSize: 18),),
                            (fingerPrintImagePath.length>3)?
                            Icon(Icons.check_circle, color: Colors.green):
                            Icon(Icons.circle_outlined),
                            Text(_fingerValidationText, style: TextStyle(fontSize: 14, color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(Colors.blue)
                      ),
                      onPressed: (){
                        _post();
                      },
                      child: Text('Submit', style: TextStyle(color: Colors.white, fontSize: 26))
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
