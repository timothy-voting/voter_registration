import 'package:flutter/material.dart';
import 'package:vote/screens/voting/vote/single_choice.dart';

class SingleChoiceGroup extends StatefulWidget {
  const SingleChoiceGroup({super.key, required this.candidates, required this.vote});
  final List<dynamic> candidates;
  final Function(int? id) vote;

  @override
  State<SingleChoiceGroup> createState() => _SingleChoiceGroupState();
}

class _SingleChoiceGroupState extends State<SingleChoiceGroup> {
  int? _choice;

  _vote(int? id){
    setState(() {
      _choice = id;
    });
    widget.vote(id);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 22.0),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: widget.candidates.length,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            SingleChoice(
              name: widget.candidates[index]['name'] as String,
              id: widget.candidates[index]['id'] as int,
              vote: _vote,
              leading: const Icon(Icons.account_circle),
              choice: _choice,
            ),
            if(index+1<widget.candidates.length)
              const Divider(color: Colors.grey, thickness: 1,)
          ],
        );
      },
    );
  }
}
