/*
import 'package:flutter/material.dart';

class CallProgressView extends StatefulWidget {
  final String callEndTime;
  const CallProgressView({super.key, required this.callEndTime});

  @override
  CallProgressViewState createState() => CallProgressViewState();
}

class CallProgressViewState extends State<CallProgressView> {
  late final String _callEndTime;

  @override
  void initState() {
    super.initState();
    _callEndTime = widget.callEndTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calls have been sent!'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                'Calls are scheduled to be finished at $_callEndTime.\nPlease do not close the program.'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
*/
