import 'package:flutter/material.dart';
//import 'package:time_picker_spinner/time_picker_spinner.dart';

class RoboInputView extends StatefulWidget {
  @override
  _RoboInputViewState createState() => _RoboInputViewState();
}

class _RoboInputViewState extends State<RoboInputView> {
  String jobName = "";
  String callerID = "";
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay stopTime = TimeOfDay.now();
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTime,
    );

    if (picked != null) {
      picked = TimeOfDay(
        hour: (picked.hour ~/ 1) * 1,
        minute: (picked.minute / 15).round() * 15,
      );
    }

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked!;
        } else {
          stopTime = picked!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Job Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(labelText: "Job Name"),
              onChanged: (value) {
                setState(() {
                  jobName = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: "Caller ID"),
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                setState(() {
                  callerID = value;
                });
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text("Start Time: ${startTime.hour}:${startTime.minute}"),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _selectTime(context, true),
                  child: Text("Select Time"),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text("Stop Time: ${stopTime.hour}:${stopTime.minute}"),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _selectTime(context, false),
                  child: Text("Select Time"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
