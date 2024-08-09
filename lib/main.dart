import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/services/fileBloc/file_bloc.dart';
import 'package:robo_talker_pro/services/fileBloc/file_state.dart';
import 'package:robo_talker_pro/services/roboBloc/robo_bloc.dart';
import 'package:robo_talker_pro/services/roboBloc/robo_state.dart';
import 'package:robo_talker_pro/views/main_view/main_view.dart';
import 'package:robo_talker_pro/views/progress_view.dart';
import 'package:robo_talker_pro/views/robo_input_view.dart';
import 'package:robo_talker_pro/views/file_view.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<FileBloc>(
          create: (context) => FileBloc(),
        ),
        BlocProvider<RoboBloc>(
          create: (context) => RoboBloc(),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Robo Talker Pro',
      theme: ThemeData(
        //primarySwatch: Colors.blue,
        colorScheme: const ColorScheme.light(),
      ),
      home: const MainView(),
    );
  }
}
