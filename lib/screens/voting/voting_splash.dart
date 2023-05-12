import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vote/requests.dart';
import 'package:vote/app_styles.dart';
import 'package:vote/info.dart';
import 'package:vote/size_config.dart';


class VotingSplash extends StatefulWidget {
  const VotingSplash({super.key});

  @override
  State<VotingSplash> createState() => _VotingSplashState();
}

class _VotingSplashState extends State<VotingSplash> {
  double progressValue = 0;
  Timer? timer;

  Future<void> _next() async {
    RequestCubit.isAuthenticated().then((value){
      if(mounted) {
        Navigator.pushReplacementNamed(context,
            (User.voterSpecialNumber != null) ? '/voting_home' : (value
                ? '/rules'
                : '/login'));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<RequestCubit>().connectWebsocket();

    timer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) => setState(() {
      if(progressValue<1) {
        progressValue += 0.2;
      }
      else{
        timer?.cancel();
        _next();
      }
    }));
  }

  @override
  void dispose() {
    timer?.cancel();
    _next();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: paddingHorizontal*5, vertical: paddingHorizontal*9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: SizeConfig.blockSizeVertical! * 10),
              const Text('WELCOME TO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36, color: Colors.green),),
              SizedBox(height: SizeConfig.blockSizeVertical! * 4),
              Image(
                image: const AssetImage('assets/logo.png'),
                width: SizeConfig.screenWidth!*0.6,
              ),
              SizedBox(height: SizeConfig.blockSizeVertical! * 2),
              const Text('MAKERERE UNIVERSITY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
              SizedBox(height: SizeConfig.blockSizeVertical! * 4),
              const Text('E-VOTING ENVIRONMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.green),),
              SizedBox(height: SizeConfig.blockSizeVertical! * 2),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: LinearProgressIndicator(
                  value: progressValue,
                  semanticsLabel: 'Linear progress indicator',
                  backgroundColor: const Color(0xffD3D3D3),
                  color: Colors.green,
                  minHeight: 8,
                ),
              ),
            ],
          )
      ),
    );
  }
}


