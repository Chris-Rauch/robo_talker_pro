import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/services/fileIO/io_bloc.dart';
import 'package:robo_talker_pro/views/main_view/main_view.dart';
import 'package:robo_talker_pro/views/progress_view.dart';
import 'package:robo_talker_pro/views/robo_input_view.dart';
import 'package:robo_talker_pro/views/select_file_view.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => FileIoBloc(),
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
        primarySwatch: Colors.red,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainView(),
        '/late_payment': (context) =>
            const SelectFileView(projectType: ProjectType.latePayment),
        '/late_payment/robo_input': (context) => const RoboInputView(),
        '/late_payment/robo_input/progress_view': (context) =>
            const ProgressBarView(progressInfo: 'Memo\'ing Accounts'),
        '/return_mail': (context) =>
            const SelectFileView(projectType: ProjectType.returnMail),
        '/return_mail/progress_view': (context) =>
            const ProgressBarView(progressInfo: 'Gathering Phone Numbers'),
        '/return_mail/progress_view/robo_input': (context) =>
            const RoboInputView(),
        '/return_mail/progress_view/robo_input/progress_view': (context) =>
            const ProgressBarView(progressInfo: 'Memo\'ing Accounts'),
      },
      //home: const MainView(),
    );
  }
}
