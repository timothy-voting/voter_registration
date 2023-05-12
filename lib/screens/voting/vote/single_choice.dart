import 'package:flutter/material.dart';

class SingleChoice extends StatelessWidget {
  const SingleChoice({super.key, required this.name, required this.id, this.choice, required this.vote, required this.leading});
  final String name;
  final int id;
  final int? choice;
  final Function(int? val) vote;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      leading: leading,
      trailing: Radio<int>(
        value: id,
        groupValue: choice,
        onChanged: (int? value) {vote(value);},
      ),
      onTap: () {vote(id);},
    );
  }
}
