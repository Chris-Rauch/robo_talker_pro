/* Title: Robotalker Pro
 * Author: Chris Rauch
 * Date: 2024-08-13
 * Version: 1.0 (beta)
 * 
 * Overview:
 *  Description - This software was developed for General Agents Acceptance 
 *    Coorporation and to optimize their weekly late payment call reminders to 
 *    clients. With the help of proprietary third party software, 
 *    robotalker.com, Robotalker Pro automates these calls. 
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robo_talker_pro/services/projectBloc/project_bloc.dart';
import 'package:robo_talker_pro/views/main_view/main_view.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ProjectBloc>(
          create: (context) => ProjectBloc(),
        ),
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
      title: 'Robotalker Pro',
      theme: ThemeData(
        colorScheme: ColorScheme(
          primary: Color.fromARGB(255, 7, 0,
              0), // effects Text() elems (the text in my elevated buttons)
          secondary: const Color.fromARGB(255, 168, 189, 49), //nothing
          background:
              const Color.fromARGB(255, 255, 255, 255), // Bottom App Nav Bar
          surface: const Color.fromARGB(
              255, 158, 158, 158), // the header bar in settings
          onPrimary: Color.fromARGB(255, 182, 169, 169)!,
          onSecondary: const Color.fromARGB(
              255, 255, 255, 255), // the icon color on floating action buttons
          onBackground: const Color.fromARGB(255, 0, 0, 0), // nothing
          onSurface:
              const Color.fromARGB(255, 0, 0, 0), // most of the text fields
          error: Colors.red[800]!,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 28.10,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(
                0, 255, 255, 255), // Use white text for headlines
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 0, 0, 0), // text 
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
          hintStyle: TextStyle(
            color: Color.fromARGB(255, 122, 122, 122), // text hint
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(94, 0, 57, 121),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(0, 255, 255, 255),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 66, 69, 75),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(
            255, 230, 230, 230), // Background color for the app
      ),
      home: const MainView(),
    );
  }
}
