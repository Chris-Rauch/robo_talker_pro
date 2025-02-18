import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class ProgressView extends StatefulWidget {
  const ProgressView(this.step1InProgress, this.step2InProgress,
      this.step3InProgress, this.jobCompleted,
      {super.key});
  final bool step3InProgress;
  final bool step2InProgress;
  final bool step1InProgress;
  final bool jobCompleted;
  @override
  ProgressViewState createState() => ProgressViewState();
}

class ProgressViewState extends State<ProgressView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Process _pythonScript;
  int _currentDot = 0;

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
        title: const Text('Job Progress'),
      ),
      /* sigkill and taskkill are not stoping the execution of the script
      floatingActionButton: FloatingActionButton(
        child: const Text('Cancel'),
        onPressed: () async {
          bool cancel = await showPopup(context,
              'If the calls have already been scheduled then you\'ll need to cancel them on robotalker.com.\nData may be lost and the accounts won\'t be memo\'d');
          if (cancel) {
            bool stop = _pythonScript.kill(ProcessSignal.sigkill);
            Process.run('taskkill', ['/F', '/PID', '${_pythonScript.pid}']);
          }
        },
      ),
      */
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLoadingColumn('Checking System Requirements',
                widget.step1InProgress, widget.step2InProgress),
            const SizedBox(width: 150),
            _buildLoadingColumn('Waiting on RoboTalker', widget.step2InProgress,
                widget.step3InProgress),
            const SizedBox(width: 150),
            _buildLoadingColumn('Memo\'ing Accounts', widget.step3InProgress,
                widget.jobCompleted),
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
      //print('Hello there! Here\'s the data: $data');
      if (data.contains('Grabbing Collections Report')) {
      } else if (data.contains('Scheduling job with RoboTalker')) {
      } else if (data.contains('Memo\'ing accounts')) {}

      if (data.contains(" Completed")) {
      } else if (data.contains("Step 2 Completed")) {
      } else if (data.contains("Step 3 Completed")) {}

      setState(() {});
    });
  }
}
