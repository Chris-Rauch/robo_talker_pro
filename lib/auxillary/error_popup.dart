import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

SnackBar customSnackBar(BuildContext context, String errorMessage) {
  return SnackBar(
    content: Text(errorMessage),
    backgroundColor: Colors.red,
    duration:
        const Duration(seconds: 5), // Duration the SnackBar should be visible
  );
}

void showSnackBarAfterBuild(BuildContext context, Object error) {
  SnackBar snackBar = SnackBar(
    content: Text(error.toString()),
    backgroundColor: Colors.red,
    duration:
        const Duration(seconds: 10), // Duration the SnackBar should be visible
  );

  SchedulerBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  });
}

void showErrorPopup(BuildContext context, String errorMessage) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Error", style: TextStyle(color: Colors.red)),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}

