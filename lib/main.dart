import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vote/requests.dart';
import 'routes.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RequestCubit>(create: (context)=>RequestCubit(""))
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mak E-Voting',
        routes: routes,
        initialRoute: '/',
      ),
    );
  }
}


