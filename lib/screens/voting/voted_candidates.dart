import 'package:flutter/material.dart';
import 'package:vote/info.dart';

class VotedCandidates extends StatefulWidget {
  const VotedCandidates({Key? key}) : super(key: key);

  @override
  State<VotedCandidates> createState() => _VotedCandidatesState();
}

class _VotedCandidatesState extends State<VotedCandidates> {
  Position? position = Position.positions[Position.currentPosition];
  Map<int, FetchedCandidate>? candidates;
  Widget _bodyWidget = const Center(child: CircularProgressIndicator(color: Colors.green));

  _pop(){
    Navigator.pop(context);
  }

  build1(){
    setState(() {
      _bodyWidget = ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 0),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: candidates?.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(candidates?[index]?.student ?? ''),
            trailing: Text(candidates?[index]?.votes.toString() ?? ''),
          );
        },
      );
    });
  }

  @override
  void initState() {
    super.initState();
    candidates = position?.candidates;
    build1();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 36),
          color: Colors.black,
          onPressed: _pop,
        ),
        title: const Text('', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 26),),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: _bodyWidget
      )
    );
  }
}

