import 'package:flutter/material.dart';

Widget buildButton({
  required String text,
  required VoidCallback onPressed,
  Color color = Colors.blue,
  double width = double.infinity,
  double height = 50.0,
}) {
  return SizedBox(
    width: width,
    height: height,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    ),
  );
}

