import 'package:flutter/material.dart';

class MultipleChoice extends StatefulWidget {
  const MultipleChoice({super.key, required this.name, required this.id, required this.vote, required this.leading});
  final String name;
  final int id;
  final bool Function(int? val) vote;
  final Widget leading;

  @override
  State<MultipleChoice> createState() => _MultipleChoiceState();
}

class _MultipleChoiceState extends State<MultipleChoice> {
  bool _choice = false;

  _vote(){
    setState(() {
      if(widget.vote(widget.id)) {
        _choice = !_choice;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.name),
      leading: widget.leading,
      trailing: Checkbox(
        value: _choice,
        onChanged: (bool? value) { _vote(); },
      ),
      onTap: _vote,
    );
  }
}

// trailing: Radio<int>(
// value: id,
// groupValue: choice,
// onChanged: (int? value) {vote(value);},
// ),
