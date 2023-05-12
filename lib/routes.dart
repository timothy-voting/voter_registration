import 'package:vote/screens/init.dart';
import 'package:vote/screens/registration/registration.dart';
import 'package:vote/screens/voting/voting_home.dart';
import 'package:vote/screens/auth/login.dart';
import 'package:vote/screens/voting/rules.dart';
import 'package:vote/screens/voting/voting_splash.dart';
import 'package:vote/screens/voting/vote/candidates.dart';
import 'package:vote/screens/voting/vote/voting_done.dart';
import 'package:vote/screens/voting/voted_candidates.dart';

var routes = {
  '/': (context) => const Init(),
  '/registration': (context) => const Registration(),
  '/voting': (context) => const VotingSplash(),
  '/rules': (context) => const Rules(),
  '/voting_home': (context) => const VotingHome(),
  '/login': (context) => const Login(),
  '/candidates': (context) => const Candidates(),
  '/done': (context) => const VotingDone(),
  '/voted_candidates': (context) => const VotedCandidates()
};