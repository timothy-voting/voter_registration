import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vote/requests.dart';
import 'package:vote/screens/voting/vote/vote.dart';
import 'package:vote/info.dart';
import 'live.dart';


class VotingHome extends StatefulWidget {
  const VotingHome({Key? key}) : super(key: key);

  @override
  State<VotingHome> createState() => _VotingHomeState();
}

class _VotingHomeState extends State<VotingHome> {
  late int _selectedIndex;
  bool _showSubmit = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = (User.voterSpecialNumber == null)?1:2;
  }

  void toggleSubmitButton(){
    setState(() {
      _showSubmit = (CategoryVote.enabledCategories.every((element) => !element) && (_selectedIndex == 1));
    });
  }

  late final List<Widget> _widgetOptions = <Widget>[
    const Center(
      child: Text(
        'Home',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    ),
    Vote(toggle: toggleSubmitButton ),
    const Live(),
  ];

  void _onItemTapped(int index) {
    toggleSubmitButton();
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: _showSubmit?FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          context.read<RequestCubit>().sendToWebsocket(jsonEncode(CategoryVote.votes)).toString();
        },
        child: const Icon(Icons.check, size: 30),
      ):null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_vote),
            label: 'Vote',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download),
            label: 'Live Updates',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
