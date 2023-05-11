import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FingerPrint extends StatefulWidget {
  const FingerPrint({Key? key, required this.setFilePath}) : super(key: key);
  final void Function(String filePath) setFilePath;

  @override
  State<FingerPrint> createState() => _FingerPrintState();
}

class _FingerPrintState extends State<FingerPrint> {
  static const platform = MethodChannel('fingerprint.scanner');

  late Timer messageTimer;
  late Timer logTimer;
  Timer? captureRunningTimer;
  bool _fastFingerDetection = false;
  String _message = "No Device Connected";
  String _logs = '';
  Image _image = Image.asset('assets/finger.png', width: 98, height: 130);
  int _fingerImageQuality = 0;
  String _fingerImageFilePath = "";
  late double _screenWidth = MediaQuery.of(context).size.width;

  @override
  void initState() {
    super.initState();
    messageTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      platform.invokeMethod("getMessage").then((value){
        String message = value.toString();
        if(_message != message){
          setState(() {
            _message = message;
          });
        }
      });
    });

    logTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      platform.invokeMethod("getLogs").then((value){
        String logs = value.toString();
        if(_logs != logs){
          setState(() {
            _logs = logs;
          });
        }
      });
    });
  }

  void _changeFastFingerDetection(bool? value){
    setState(() {
      _fastFingerDetection = value!;
    });
    platform.invokeMethod((value!)?"setFastDetectionTrue":"setFastDetectionFalse");
  }

  void _init(){
    platform.invokeMethod("init");
  }

  void _uninit(){
    platform.invokeMethod("unInit");
  }

  void _capture(){
    platform.invokeMethod('capture');
    captureRunningTimer = Timer.periodic(Duration(milliseconds: 1), (timer) {
      platform.invokeMethod("getCaptureRunning").then((value2){
        String captureRunning = value2.toString();
        if(captureRunning == "false"){
          timer.cancel();
          platform.invokeMethod("checkFingerUuid").then((value3){
            if(value3.toString().length>3){
              platform.invokeMethod("getFingerImage").then((value3){
                setState(() {
                  _image = Image.memory(value3, width: _screenWidth*0.25, height: 130);
                });
              });

              platform.invokeMethod("getFingerQuality").then((value4){
                setState(() {
                  _fingerImageQuality = value4;
                });
                if(value4 < 80){
                  _snackBarAlert('Fingerprint is of poor quality. Scan again');
                }else {
                  platform.invokeMethod("getIsoFilepath").then((value5){
                    setState(() {
                      _fingerImageFilePath = value5;
                    });
                  });
                }
              });
            }
          });
        }
      });
    });
  }

  void _stopCapture(){
    platform.invokeMethod('stopCapture');
  }

  // void _matchISO(){
  //   log('called _matchISO');
  // }
  //
  // void _extractISO(){
  //   log('called _extractISO');
  // }
  //
  // void _extractAnsi(){
  //   log('called _extractAnsi');
  // }
  //
  // void _extractWSQ(){
  //   log('called _extractWSQ');
  // }

  void _clearLog(){
    platform.invokeMethod("clearLogs");
  }

  _snackBarAlert(String message){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _submit(){
    if(_fingerImageQuality >= 80) {
      widget.setFilePath(_fingerImageFilePath);
      Navigator.of(context).pop();
    }
    else if(_fingerImageFilePath.length > 2){
      _snackBarAlert('Fingerprint image has poor quality, please rescan.');
    }
    else{
      _snackBarAlert('Please scan fingerprint');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Fingerprint'),
      ),
      body: Container(
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: 5),
                Container(
                    child: _image,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.green, spreadRadius: 2),
                      ],
                    )
                ),
                SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FingerRow(children: [
                      FingerButton(
                          text: 'INIT',
                          onPressed: _init,
                        width: _screenWidth*0.35,
                      ),
                      FingerButton(
                          text: 'UNINIT',
                          onPressed: _uninit,
                        width: _screenWidth*0.35,
                      ),
                    ]),
                    FingerRow(
                      children: [
                        FingerButton(
                            text: 'CAPTURE',
                            onPressed: _capture,
                          width: _screenWidth*0.35,
                        ),
                        FingerButton(
                            text: 'STOP CAP',
                            onPressed: _stopCapture,
                          width: _screenWidth*0.35,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                            value: _fastFingerDetection,
                            onChanged: _changeFastFingerDetection
                        ),
                        const Text('Fast Finger Detection', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))
                      ],
                    )
                  ],
                )
              ],
            ),
            // FingerRow(
            //   children: [
            //     FingerButton(
            //         text: 'MATCH ISO',
            //         onPressed: _matchISO,
            //       width: _upperGridWidth*1.3,
            //     ),
            //     FingerButton(
            //         text: 'EXTRACT ISO',
            //         onPressed: _extractISO,
            //       width: _upperGridWidth*1.3,
            //     ),
            //   ],
            // ),
            // FingerRow(
            //   children: [
            //     FingerButton(
            //         text: 'EXTRACT ANSI',
            //         onPressed: _extractAnsi,
            //       width: _upperGridWidth*1.3,
            //     ),
            //     FingerButton(
            //         text: 'EXTRACT WSQ',
            //         onPressed: _extractWSQ,
            //       width: _upperGridWidth*1.3,
            //     ),
            //   ],
            // ),
            Container(
              child: Center(child: Text(_message, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400))),
              width: _screenWidth*0.98,
              padding: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.blue, spreadRadius: 2),
                ],
              ),
            ),
            SizedBox(height: 8),
            Expanded(
                child: Container(
                  width: _screenWidth*0.98,
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.blue, spreadRadius: 2),
                    ],
                  ),
                  child: SingleChildScrollView(
                      child: Text(_logs)
                  ),
                )
            )
          ],
        ),
      ),
      bottomNavigationBar: FingerRow(
        children: [
          SizedBox(width: 5),
          FingerButton(
            onPressed: _clearLog,
            text: 'CLEAR LOG'
          ),
          FingerButton(
            onPressed: _submit,
            text: 'FINISH'
          ),
          SizedBox(width: 5),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    messageTimer.cancel();
    logTimer.cancel();
    if(captureRunningTimer != null)
    captureRunningTimer!.cancel();
    _clearLog();
  }
}

class FingerRow extends StatelessWidget {
  const FingerRow({Key? key, required this.children}) : super(key: key);
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 5,
      children: children
    );
  }
}


class FingerButton extends StatelessWidget {
  const FingerButton({Key? key, required String this.text, required this.onPressed, this.width=130}) : super(key: key);
  final String text;
  final void Function() onPressed;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        child: Text(text, style: TextStyle(fontSize: 18)),
      style: ButtonStyle(fixedSize: MaterialStateProperty.all(Size(width, 36))),
    );
  }
}

