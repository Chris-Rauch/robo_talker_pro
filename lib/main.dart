//import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/services/fileIOBloc/io_bloc.dart';
import 'package:robo_talker_pro/services/roboBloc/robo_bloc.dart';
import 'package:robo_talker_pro/services/roboBloc/robo_event.dart';
import 'package:robo_talker_pro/views/main_view/main_view.dart';
import 'package:robo_talker_pro/views/progress_view.dart';
import 'package:robo_talker_pro/views/robo_input_view.dart';
import 'package:robo_talker_pro/views/select_file_view.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<FileIoBloc>(
          create: (context) => FileIoBloc(),
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: const ColorScheme.light(),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainView(),
        '/late_payment': (context) =>
            const SelectFileView(projectType: ProjectType.latePayment),
        '/late_payment/robo_input': (context) => const RoboInputView(),
        '/late_payment/robo_input/progress_view': (context) =>
            const ProgressBarView(),
        '/return_mail': (context) =>
            const SelectFileView(projectType: ProjectType.returnMail),
        '/return_mail/progress_view': (context) => const ProgressBarView(),
        '/return_mail/progress_view/robo_input': (context) =>
            const RoboInputView(),
        '/return_mail/progress_view/robo_input/progress_view': (context) =>
            const ProgressBarView(),
      },
    );
  }
}
