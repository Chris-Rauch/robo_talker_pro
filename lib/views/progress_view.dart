import 'package:flutter/material.dart';


class ProgressBarView extends StatefulWidget {
  const ProgressBarView({super.key});

  @override
  ProgressBarViewState createState() => ProgressBarViewState();
}

class ProgressBarViewState extends State<ProgressBarView> {
  ProgressBarViewState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: null,
              child: Text('Update Progress'),
            ),
            SizedBox(height: 20),
            LinearProgressIndicator(
              value: 25.00,
              minHeight: 20,
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
