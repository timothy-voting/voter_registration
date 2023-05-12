import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vote/requests.dart';
import '../../app_styles.dart';
import '../../size_config.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool hidePass = true;
  bool hideConfirmPass = true;
  final TextEditingController _studentNo = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final neededImages = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: const AssetImage('assets/logo.png'),
                  width: SizeConfig.screenWidth!*0.6,
                ),
                SizedBox(height: SizeConfig.blockSizeVertical! * 2),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _studentNo,
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.account_circle),
                      border: OutlineInputBorder(),
                      hintText: 'Student number',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Your Student number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 5.0),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _password,
                    decoration: InputDecoration(
                      suffixIcon: InkWell(
                        child: Icon(hidePass?Icons.visibility_rounded:Icons.visibility_off_rounded),
                        onTap: () {
                          setState(() {
                            hidePass = !hidePass;
                          });
                        },
                      ),

                      border: const OutlineInputBorder(),
                      hintText: 'Password',
                    ),
                    obscureText: hidePass,
                    enableSuggestions: true,

                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Your Password';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          )
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: FilledButton(
          onPressed: () async {
            if (_form.currentState!.validate()) {
              final response = await RequestCubit.login(
                  {
                    'student_no': _studentNo.text,
                    'password': _password.text
                  }
              );
              if(response['error'] == true){
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['res'] as String)));
              }
              else{
                final res = jsonDecode(response['res'] as String);
                (response['code'] == 422)?
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] as String)))
                    :RequestCubit.storageWrite('token', res['token']);
                RequestCubit.isAuthenticated().then((value) {
                  if(value) {
                    Navigator.pushReplacementNamed(context, '/rules');
                  }
                });
              }
            }
          },
          style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(Color(0xff008000)),
              shape: MaterialStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))))
          ),
          child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white)),
        ),
      ),
    );
  }
}
