import 'package:flutter/material.dart';
import 'package:vote/info.dart';
import 'package:vote/requests.dart';
import 'package:vote/screens/voting/vote/multiple_choice_group.dart';
import 'package:vote/screens/voting/vote/single_choice_group.dart';

class Candidates extends StatefulWidget {
  const Candidates({Key? key}) : super(key: key);

  @override
  State<Candidates> createState() => _CandidatesState();
}

class _CandidatesState extends State<Candidates> {
  bool agreed = false;
  bool refresh = true;
  List<int> _choices = [];
  Widget _bodyWidget = const Center(child: CircularProgressIndicator(color: Colors.green));

  _voteSingle(int? id){
    setState(() {
      _choices = [id!];
    });
  }

  bool _voteMultiple(int? id){
    if(!_choices.contains(id!) && _choices.length>=CategoryVote.max!) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Not more than ${CategoryVote.max!} candidates allowed.')));
      return false;
    }
    setState(() {
      if (!_choices.remove(id)) {
        _choices.add(id);
      }
    });
    return true;
  }

  _getCandidates(){
    if(refresh) {
      RequestCubit.getCandidates().then((cands) {
        if (cands is String) {
          setState(() {
            refresh = true;
          });
        }
        else if (cands is List<dynamic>) {
          var cands2 = [];
          for (var candidate in cands) {
            cands2.add(candidate);
          }
          setState(() {
            refresh = false;

            if(cands.length<=CategoryVote.max!){
              _choices = [0];
            }

            _bodyWidget = (cands.length<=CategoryVote.max!)?
              const Center(child: Text('None', style: TextStyle(fontSize: 26)))
              :((CategoryVote.max! ==1)?
              SingleChoiceGroup(candidates: cands2, vote: _voteSingle)
              :MultipleChoiceGroup(candidates: cands2, vote: _voteMultiple));
          });
        }
      });
    }
  }

  _submit(){
    CategoryVote.setVotes(_choices);
    Navigator.pop(context);
  }

  _pop(){
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if(CategoryVote.candidates.isEmpty) {
      _getCandidates();
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 36),
          color: Colors.black,
          onPressed: _pop,
        ),
        title: const Text('Choose Your Candidate', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 26),),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: _bodyWidget,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: FilledButton(
          onPressed: _choices.isNotEmpty?_submit:null,
          style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(_choices.isNotEmpty?const Color(0xff008000):Colors.white),
              shape: const MaterialStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))))
          ),
          child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white)),
        ),
      ),
    );
  }
}

