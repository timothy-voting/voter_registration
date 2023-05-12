import 'package:flutter/material.dart';

class Init extends StatelessWidget {
  const Init({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff6f6f6),
      body: SafeArea(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Choose', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InitCard(
                      imgPath: 'assets/reg.png',
                      trailingText: 'Register',
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/registration');
                      },
                    ),
                    SizedBox(width: 20),
                    InitCard(
                      imgPath:
                      'assets/vote.png',
                      trailingText: 'Vote',
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/voting');
                      },
                    )
                  ],
                ),
              ],
            ),
          )
      ),
    );
  }
}

class InitCard extends StatelessWidget {
  const InitCard({Key? key, required this.imgPath, required this.trailingText, required this.onTap}) : super(key: key);
  final String imgPath;
  final String trailingText;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imgPath, width: 98, height: 130),
          Text(trailingText, style: TextStyle(fontSize: 24))
        ],
      ),
      onTap: onTap,
    );
  }
}

