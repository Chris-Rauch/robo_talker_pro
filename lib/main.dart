import 'package:flutter/material.dart';
import 'package:robo_talker_pro/views/main_view/main_view.dart';
import 'package:robo_talker_pro/views/progress_view.dart';
import 'package:robo_talker_pro/views/robo_input_view.dart';
import 'package:robo_talker_pro/views/select_file_view.dart';

void main() {
  runApp(const MyApp());
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
            const SelectFileView(projectType: 'Late Payment'),
        '/late_payment/robo_input': (context) => RoboInputView(),
        '/late_payment/robo_input/progress_view': (context) =>
            ProgressBarView(progressInfo: 'Memo\'ing Accounts'),
        '/return_mail': (context) =>
            const SelectFileView(projectType: 'Return Mail'),
        '/return_mail/progress_view': (context) =>
            ProgressBarView(progressInfo: 'Gathering Phone Numbers'),
        '/return_mail/progress_view/robo_input': (context) => RoboInputView(),
        '/return_mail/progress_view/robo_input/progress_view': (context) =>
            ProgressBarView(progressInfo: 'Memo\'ing Accounts'),
      },
      //home: const MainView(),
    );
  }
}
