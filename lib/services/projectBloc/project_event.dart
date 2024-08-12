/// This file defines the FileBloc, which handles the business logic related to
/// file picking and file formatting. It processes file picking events and
/// manages the state transitions accordingly.
library project_event_bloc;

import 'package:flutter/material.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';

abstract class ProjectEvent {
  const ProjectEvent();
}
// Emitted on start-up
class InitializeProjectEvent extends ProjectEvent {}

// Emitted when the user clicks on a project
class ProjectSelectedEvent extends ProjectEvent {
  final ProjectType projectType;
  const ProjectSelectedEvent(this.projectType);
}

// Emitted when the user selects both a file and directory
class FilePathSelectedEvent extends ProjectEvent {
  final String? filePath;
  final String? folderPath;
  final ProjectType projectType;
  const FilePathSelectedEvent(this.filePath, this.folderPath, this.projectType);
}

// Emmited after user provides job information
class PostJobEvent extends ProjectEvent {
  final String jobName;
  final DateTime startDate;
  final TimeOfDay startTime;
  final TimeOfDay stopTime;
  PostJobEvent(
      {required this.jobName,
      required this.startDate,
      required this.startTime,
      required this.stopTime});
}
