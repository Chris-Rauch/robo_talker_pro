import 'package:flutter/material.dart';

abstract class RoboEvent {}

class RoboInitializeEvent extends RoboEvent {}

class RoboSubmitJobEvent extends RoboEvent {
  final String jobName;
  final DateTime startDate;
  final TimeOfDay startTime;
  final TimeOfDay stopTime;
  RoboSubmitJobEvent(this.jobName, this.startDate, this.startTime, this.stopTime);
}

class RoboMultiJobEvent extends RoboEvent {
  final String folderPath;
  RoboMultiJobEvent(this.folderPath);
}

class RoboErrorEvent extends RoboEvent {
  final Object error;
  RoboErrorEvent(this.error);
}
