import 'package:flutter/material.dart';
import 'package:vote/app_styles.dart';
import 'package:vote/info.dart';
import 'package:vote/size_config.dart';

class VotingDone extends StatelessWidget {
  const VotingDone({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingHorizontal*9),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: SizeConfig.blockSizeVertical! * 8),
                Image(
                  image: const AssetImage('assets/check.png'),
                  width: SizeConfig.screenWidth!*0.6,
                ),
                SizedBox(height: SizeConfig.blockSizeVertical! * 2),
                const Text('Successfully Submitted !', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
                SizedBox(height: SizeConfig.blockSizeVertical! * 2),
                const Text('Your unique voterID is', style: TextStyle(fontSize: 22),),
                SizedBox(height: SizeConfig.blockSizeVertical! * 2),
                Text(User.voterSpecialNumber!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),),
                SizedBox(height: SizeConfig.blockSizeVertical! * 2),
                const Text('Please note it down to verify your vote', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),),
                SizedBox(height: SizeConfig.blockSizeVertical! * 8),
                FilledButton(
                  onPressed: ()=>Navigator.pushReplacementNamed(context, '/voting_home'),
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll<Color>(Color(0xff008000)),
                      shape: MaterialStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))))
                  ),
                  child: const Text('Done >', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white)),
                ),
              ],
            ),
          )
      ),
    );
  }
}
