import 'dart:convert';

class User{
  static int? id;
  static String? name;
  static String? email;
  static String? studentNo;
  static String? token;
  static String? voterSpecialNumber;
}

class Student{
  static int? id;
  static String? studentNo;
  static String? name;
  static int? school;
  static String? schoolName;
  static int? college;
  static String? collegeName;
  static int? hall;
  static String? hallName;
}

class CategoryVote{
  static int? id;
  static String? name;
  static String? affiliation;
  static int? affiliationId;
  static int? max;
  static bool? done;
  static Map<String, List<int>> votes = {};
  static List<dynamic> candidates = [];
  static List<dynamic> categories = [];
  static List<bool> enabledCategories = [];

  static void set(int id, String name, String affiliation, int max){
    CategoryVote.unset();
    CategoryVote.id = id;
    CategoryVote.name = name;
    CategoryVote.affiliation = affiliation;
    CategoryVote.affiliationId = {
      'university':0, 'college':Student.college, 'school':Student.school, 'hall':Student.hall
    }[affiliation];
    CategoryVote.max = max;
  }

  static void setVotes(List<int> votes){
    CategoryVote.votes["${CategoryVote.id!}"] = (votes[0] == 0)?[]:votes;
    CategoryVote.done = true;
  }

  static void unset(){
    id = null;
    name = null;
    affiliation = null;
    max = null;
    done = null;
    candidates.clear();
    affiliationId = null;
  }
}

class FetchedCandidate{
  FetchedCandidate(
      this.candidateId,
      this.positionId,
      this.hallId,
      this.schoolId,
      this.collegeId,
      this.studentId,
      this.votes,
      this.position,
      this.affiliation,
      this.student,
      this.college,
      this.school,
      this.hall
      );

  final int candidateId;
  final int positionId;
  final int hallId;
  final int schoolId;
  final int collegeId;
  final String position;
  final String affiliation;
  final int studentId;
  final String student;
  late int votes;
  final String college;
  final String school;
  final String hall;
}

class Position{
  Position(
    this.name,
    this.affiliation
  );

  static Map<int, String> halls = {};
  static Map<int, String> schools = {};
  static Map<int, String> colleges = {};
  static bool candidatesReceived = false;
  static int currentPosition = 0;

  final String name;
  final String affiliation;
  Map<int, FetchedCandidate> candidates = {};
  Map<int, List<int>> affiliationToCandidate = {};

  Map<int, String> get affiliationIds{
    switch(affiliation){
      case "school":
        return schools;
      case "college":
        return colleges;
      case "hall":
        return halls;
    }
    return {};
  }

  static Map<int, Position> positions = {};

  static setCandidates(Map<String, dynamic> response){
    candidatesReceived = true;
    Map<String, dynamic> cands = response['candidates'];
    cands.forEach((key, value) {
      String affiliation = value["affiliation"] as String;
      int positionId = value["position_id"] as int;
      int hallId = value["hall_id"] as int;
      int schoolId = value["school_id"] as int;
      int collegeId = value["college_id"] as int;
      int candidateId = value["candidate_id"] as int;
      String college = value["college"] as String;
      String school = value["school"] as String;
      String hall = value["hall"] as String;
      String positionName = value["position"] as String;

      if(!Position.halls.containsKey(hallId)){
        Position.halls[hallId] = hall;
      }

      if(!Position.schools.containsKey(hallId)){
        Position.schools[schoolId] = school;
      }

      if(!Position.colleges.containsKey(hallId)){
        Position.colleges[collegeId] = college;
      }

      if(!positions.containsKey(positionId)){
        positions[positionId] = Position(positionName, affiliation);
      }

      Position? position = positions[positionId];

      if(position != null){

        position.candidates[candidateId] = FetchedCandidate(
            candidateId,
            positionId,
            hallId,
            schoolId,
            collegeId,
            value["student_id"] as int,
            value["votes"] as int,
            positionName,
            affiliation,
            value["student"] as String,
            college,
            school,
            hall
        );

        int affiliationId = 0;
        switch(affiliation){
          case "hall":
            affiliationId = hallId;
            break;
          case "school":
            affiliationId = schoolId;
            break;
          case "college":
            affiliationId = collegeId;
            break;
        }

        position.affiliationToCandidate[affiliationId] =
        (position.affiliationToCandidate.containsKey(affiliationId))?
        [...?position.affiliationToCandidate[affiliationId], candidateId]
            :[candidateId];
      }
    });
  }
}