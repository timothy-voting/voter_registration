import 'package:flutter/material.dart';
import 'package:vote/info.dart';
import 'package:vote/size_config.dart';

class Instruction extends StatelessWidget {
  const Instruction(this.text, {Key? key}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(text, style: const TextStyle(fontSize: 18)),
        SizedBox(height: SizeConfig.blockSizeVertical!)
      ],
    );
  }
}


class Rules extends StatelessWidget {
  const Rules({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('INSTRUCTIONS', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 26),),
            Divider(color: Colors.grey,)
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal!*3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Instruction('1. Tick against only one candidate for Guild President.'),
            const Instruction('2. Tick against only one candidate for Guild Representatives for schools per gender.'),
            const Instruction('3. Tick not more than two candidates for Guild Representatives for Male Halls.'),
            const Instruction('4. Tick not more than three candidates for Guild Representatives for Female Halls.'),
            SizedBox(height: SizeConfig.blockSizeVertical! * 4),
            const Text('NOTE', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 26)),
            const Divider(color: Colors.grey),
            const Instruction('Your Vote is kept secret, confidential and end to end encrypted.'),
            const Instruction('This election is guided by the guild elections policy of Makerere University.'),
            SizedBox(height: SizeConfig.blockSizeVertical! * 4),
            const Text('YOUR DETAILS', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 26)),
            const Divider(color: Colors.grey),
            Instruction('NAME: ${Student.name!}'),
            Instruction('STUDENT NUMBER: ${Student.studentNo!}'),
            Instruction('SCHOOL: ${Student.schoolName!}'),
            Instruction('COLLEGE: ${Student.collegeName!}'),
            Instruction('HALL: ${Student.hallName!}'),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: FilledButton(
            onPressed: ()=>Navigator.pushReplacementNamed(context, '/voting_home'),
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll<Color>(Color(0xff008000)),
            shape: MaterialStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))))
          ),
            child: const Text('Start Voting', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white)),
          ),
      ),
    );
  }
}

