/// This file defines the FileBloc, which handles the business logic related to
/// file picking and file formatting. It processes file picking events and
/// manages the state transitions accordingly.
library file_event_bloc;

import 'package:flutter/material.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';

abstract class FileEvent {
  const FileEvent();
}

class InitializeProjectEvent extends FileEvent {}

class ProjectSelectedEvent extends FileEvent {
  final ProjectType projectType;
  const ProjectSelectedEvent(this.projectType);
}

class FilePathSelectedEvent extends FileEvent {
  final String? filePath;
  final String? folderPath;
  final ProjectType projectType;
  const FilePathSelectedEvent(this.filePath, this.folderPath, this.projectType);
}






class ReadFileEvent extends FileEvent {
  final String filePath;
  final String folderPath;
  final ProjectType projectType;

  const ReadFileEvent(this.filePath, this.folderPath, this.projectType);
}

/*
class TriggerErrorEvent extends FileIoEvent {
  final Object error;
  const TriggerErrorEvent(this.error);
}
*/

class PostJobEvent extends FileEvent {
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
