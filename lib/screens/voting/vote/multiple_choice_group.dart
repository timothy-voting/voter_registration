import 'package:flutter/material.dart';
import 'package:vote/screens/voting/vote/multiple_choice.dart';

class MultipleChoiceGroup extends StatefulWidget {
  const MultipleChoiceGroup({super.key, required this.candidates, required this.vote});
  final List<dynamic> candidates;
  final bool Function(int? id) vote;

  @override
  State<MultipleChoiceGroup> createState() => _MultipleChoiceGroupState();
}

class _MultipleChoiceGroupState extends State<MultipleChoiceGroup> {
  bool _vote(int? id){
    return widget.vote(id);
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
            MultipleChoice(
              name: widget.candidates[index]['name'] as String,
              id: widget.candidates[index]['id'] as int,
              vote: _vote,
              leading: const Icon(Icons.account_circle),
            ),
            if(index+1<widget.candidates.length)
              const Divider(color: Colors.grey, thickness: 1,)
          ],
        );
      },
    );
  }
}
