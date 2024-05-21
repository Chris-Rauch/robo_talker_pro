import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/services/fileBloc/file_bloc.dart';
import 'package:robo_talker_pro/services/roboBloc/robo_bloc.dart';
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: const ColorScheme.light(),
      ),
      initialRoute: '/late_payment/robo_input',
      routes: {
        '/': (context) => const MainView(),
        '/late_payment': (context) =>
            const FileView(projectType: ProjectType.latePayment),
        '/late_payment/robo_input': (context) => const RoboInputView(),
        '/late_payment/robo_input/progress_view': (context) =>
            const ProgressBarView(),
        '/return_mail': (context) =>
            const FileView(projectType: ProjectType.returnMail),
        '/return_mail/progress_view': (context) => const ProgressBarView(),
        '/return_mail/progress_view/robo_input': (context) =>
            const RoboInputView(),
        '/return_mail/progress_view/robo_input/progress_view': (context) =>
            const ProgressBarView(),
      },
    );
  }
}
