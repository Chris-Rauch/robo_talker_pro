import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProgressBarView extends StatefulWidget {
  const ProgressBarView({super.key});

  @override
  _ProgressBarViewState createState() => _ProgressBarViewState();
}

class _ProgressBarViewState extends State<ProgressBarView> {
  _ProgressBarViewState();

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
