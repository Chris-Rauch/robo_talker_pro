import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class ProgressView extends StatefulWidget {
  const ProgressView({super.key});

  @override
  _ProgressViewState createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Process _pythonScript;
  int _currentDot = 0;
  bool _firstStepInProgress = false;
  bool _secondStepInProgress = false;
  bool _thirdStepInProgress = false;
  bool _firstStepCompleted = false;
  bool _secondStepCompleted = false;
  bool _thirdStepCompleted = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (_controller.status == AnimationStatus.completed) {
          setState(() {
            _currentDot = (_currentDot + 1) % 3;
          });
          _controller.reset();
          _controller.forward();
        }
      });

    _controller.forward();
    _startProcess();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Calls'),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Text('Cancel'), onPressed: () => {}),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLoadingColumn('Grabbing Collections Report',
                _firstStepInProgress, _firstStepCompleted),
            const SizedBox(width: 150),
            _buildLoadingColumn('Scheduling with RoboTalker',
                _secondStepInProgress, _secondStepCompleted),
            const SizedBox(width: 150),
            _buildLoadingColumn('Memo\'ing Accounts', _thirdStepInProgress,
                _thirdStepCompleted),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingColumn(String text, bool inProgress, bool completed) {
    FontWeight weight = (inProgress) ? FontWeight.bold : FontWeight.normal;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(
              text,
              style: TextStyle(fontSize: 18, fontWeight: weight),
            ),
            if (completed) const Icon(Icons.check),
          ],
        ),
        const SizedBox(height: 10),
        if (inProgress)
          Row(
            children: _buildLoadingDots(),
          ),
      ],
    );
  }

  List<Widget> _buildLoadingDots() {
    return List.generate(3, (index) {
      return AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _currentDot == index ? 1.0 : 0.3,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
          width: 8.0,
          height: 8.0,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }

  Future<void> _startProcess() async {
    _pythonScript = await Process.start(
        'python', ['C:\\Users\\rauch\\Projects\\flutter_ui_testing\\test.py']);
    // Listen to the stdout stream
    _pythonScript.stdout.transform(utf8.decoder).listen((data) {
      print('Hello there! Here\'s the data: $data');
      if (data.contains('Grabbing Collections Report')) {
        _firstStepInProgress = true;
        _secondStepInProgress = false;
        _thirdStepInProgress = false;
      } else if (data.contains('Scheduling job with RoboTalker')) {
        _firstStepInProgress = false;
        _secondStepInProgress = true;
        _thirdStepInProgress = false;
      } else if (data.contains('Memo\'ing accounts')) {
        _firstStepInProgress = false;
        _secondStepInProgress = false;
        _thirdStepInProgress = true;
      }

      if (data.contains(" Completed")) {
        _firstStepCompleted = true;
      } else if (data.contains("Step 2 Completed")) {
        _secondStepCompleted = true;
      } else if (data.contains("Step 3 Completed")) {
        _thirdStepCompleted = true;
      }

      setState(() {});
    });
  }
}
