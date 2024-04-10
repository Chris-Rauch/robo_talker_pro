import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProgressBarView extends StatefulWidget {
  final String progressInfo;
  const ProgressBarView({super.key, required this.progressInfo});

  @override
  _ProgressBarViewState createState() => _ProgressBarViewState(progressInfo);
}

class _ProgressBarViewState extends State<ProgressBarView> {
  double _progressValue = 0.0;
  final String progressInfo;
  _ProgressBarViewState(this.progressInfo);

  void _updateProgress() async {
    final response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final progressValue = (jsonResponse.length / 100)
          .toDouble(); // Assuming progress is based on the length of the response
      setState(() {
        _progressValue = progressValue;
      });
    } else {
      print('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(progressInfo),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _updateProgress,
              child: const Text('Update Progress'),
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: _progressValue,
              minHeight: 20,
              backgroundColor: Colors.grey,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
