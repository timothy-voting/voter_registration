import 'package:flutter/material.dart';

class Category extends StatelessWidget {
  Category({Key? key, required this.category, required this.categoryIndex, required this.enabled, required this.getCandidates}) : super(key: key);
  final String category;
  final int categoryIndex;
  late final bool enabled;
  final Function getCandidates;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: !enabled,
        onChanged: null,
      ),
      title: Text(category, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 20)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 20,),
      onTap: ()=>getCandidates(categoryIndex),
      splashColor: Colors.green[200],
      iconColor: Colors.black,
      contentPadding: const EdgeInsets.all(0),
      visualDensity: const VisualDensity(vertical: -4),
    );
  }
}