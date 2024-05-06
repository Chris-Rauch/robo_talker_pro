/// Two button styles to convey a dead button
library button_styles;

import 'package:flutter/material.dart';

ButtonStyle enabledButtonStyle = ButtonStyle(
  backgroundColor: MaterialStateProperty.all(
      const Color.fromARGB(255, 243, 33, 215)), // Set background color
  foregroundColor: MaterialStateProperty.all(Colors.black87), // Set text color
  textStyle: MaterialStateProperty.all(const TextStyle(
      fontWeight: FontWeight
          .normal)), // Adjust text style // Text color for disabled state
);

ButtonStyle disabledButtonStyle = ButtonStyle(
  backgroundColor:
      MaterialStateProperty.all(Colors.grey), // Set background color to grey
  foregroundColor: MaterialStateProperty.all(Colors.black87), // Set text color
  textStyle: MaterialStateProperty.all(const TextStyle(
      fontWeight: FontWeight
          .normal)), // Adjust text style // Text color for disabled state
);
