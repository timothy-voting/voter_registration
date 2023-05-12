import 'dart:convert';
import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:vote/info.dart';
import 'package:web_socket_client/web_socket_client.dart';

class RequestCubit extends Cubit<String>{
  RequestCubit(super.initialState);
  static const addr = "104.248.63.15";
  static const baseUrl = 'http://$addr/api/';
  static const webSocketUrl = 'ws://$addr:8080/';
  static const storage = FlutterSecureStorage();


  static Uri getUrl(String url) => Uri.parse(baseUrl+url);
  static Uri getWebSocketUrl(String url) => Uri.parse(webSocketUrl+url);
  static WebSocket? channel;
  static Map<String, String>headers = {
    "Content-type": "application/json",
    "Accept": "application/json",
    'X-Requested-With': 'XMLHttpRequest',
  };


  static setHeader(String key, String value){
    headers[key] = value;
  }

  static Future<Map<String, Object>> login(Map<String, String> credentials) async {
    try {
      var response = await http.post(
          getUrl('login'),
          headers: {
            "Content-type": "application/json",
            "Accept": "application/json",
            'X-Requested-With': 'XMLHttpRequest'
          },
          body: jsonEncode(credentials));
      return {'error':false, 'res':response.body, 'code':response.statusCode};
    } catch(e) {
      return {'error':true, 'res':e.toString()};
    }
  }

  static void storageWrite(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  static Future<String?> storageRead(String key) async{
    return await storage.read(key: key);
  }

  static Future<bool> getStudent() async {
    try {
      var response = await http.get(getUrl('student'), headers: headers);
      if(response.statusCode==200){
        final student = jsonDecode(response.body);
        Student.id = student['id'];
        Student.studentNo = student['student_no'].toString();
        Student.name = student['name'].toString();
        Student.school = student['school'] as int;
        Student.schoolName = student['school_name'].toString();
        Student.college = student['college'] as int;
        Student.collegeName = student['college_name'].toString();
        Student.hall = student['hall'] as int;
        Student.hallName = student['hall_name'].toString();
        return true;
      }
      return false;
    } catch(e) {
      return false;
    }
  }

  static Future<bool> isAuthenticated() async {
    if(await storage.containsKey(key: 'token')){
      final token = await storage.read(key: 'token');
      final special = await storage.read(key: 'special');
      try {
        setHeader('Authorization', 'Bearer $token');
        var response = await http.get(getUrl('user'), headers: headers);
        if(response.statusCode==200){
          final user = jsonDecode(response.body);
          User.id = user['id'];
          User.token = token;
          User.email = user['email'].toString();
          User.name = user['name'].toString();
          User.studentNo = user['student_no'].toString();
          User.voterSpecialNumber = special;
          return getStudent();
        }

        await storage.delete(key: 'token');
        return false;
      } catch(e) {
        log(e.toString());
        return false;
      }
    }
    return false;
  }

  static Future<Object> getCandidates() async {
    if(CategoryVote.candidates.isEmpty) {
      try {
        var response = await http.get(getUrl(
            'candidates?affiliation=${CategoryVote
                .affiliation!}&position=${CategoryVote.id!}&affiliation_id=${CategoryVote.affiliationId}'),
            headers: headers);
        CategoryVote.candidates = jsonDecode(response.body) as List<dynamic>;
      } catch (e) {
        return e.toString();
      }
    }
    return CategoryVote.candidates;
  }

  static Future<Object> getCategories() async {
    if(CategoryVote.categories.isEmpty) {
      try {
        var response = await http.get(getUrl('positions'), headers: headers);
        CategoryVote.categories = jsonDecode(response.body) as List<dynamic>;
      } catch (e) {
        return e.toString();
      }
    }
    return CategoryVote.categories;
  }

  void connectWebsocket() async {
    if(channel != null) return;
    final uri = getWebSocketUrl('vote');
    const backoff = ConstantBackoff(Duration(seconds: 1));
    channel = WebSocket(uri, backoff: backoff);
    await Future<void>.delayed(const Duration(seconds: 3));


    Timer? timer;
    timer = Timer.periodic(const Duration(milliseconds: 2000), (Timer t) {
      if(!Position.candidatesReceived){
        sendToWebsocket('"candidates"');
      }else{
        timer?.cancel();
      }
    });

    channel?.messages.listen((message) {
      Map<String, dynamic> msg = jsonDecode(message) as Map<String, dynamic>;
      if(msg.containsKey('voter_special_number')){
        afterVote(msg);
      }

      if(msg.containsKey('candidates')){
        timer?.cancel();
        Position.setCandidates(msg);
      }
    });
  }

  void afterVote(Map<String, dynamic> message){
    RequestCubit.storageWrite('special', message['voter_special_number']);
    User.voterSpecialNumber = message['voter_special_number'];
    emit('voted');
  }

  int sendToWebsocket(String msg) {
    String message = '{"token": "${User.token!}", "message":$msg}';
    int code = channel!.connection.state.hashCode;
    if(code == 1 || code == 3){
      channel!.send(message);
      return 1;
    }
    return 0;
  }

  void disconnectWebsocket() async {
   RequestCubit.channel!.close();
   channel = null;
  }
}