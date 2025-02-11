/// This file defines the FileBloc, which handles the business logic related to
/// file picking and file formatting. It processes file picking events and
/// manages the state transitions accordingly.
library project_event_bloc;

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
/*
class FilePathSelectedEvent extends ProjectEvent {
  final String? filePath;
  final String? folderPath;
  final ProjectType projectType;
  const FilePathSelectedEvent(this.filePath, this.folderPath, this.projectType);
}
*/
// Emmited after user provides job information
class StartProjectEvent extends ProjectEvent {
  final ProjectType type;
  final String filePath;
  final String folderPath;
  final DateTime startTime;
  final DateTime endTime;
  DateTime? downloadFrom;
  DateTime? downloadTo;
  StartProjectEvent(
      {required this.type,
      required this.filePath,
      required this.folderPath,
      required this.startTime,
      required this.endTime,
      this.downloadFrom,
      this.downloadTo});
}

class StartOverEvent extends ProjectEvent {}

class LoadingEvent extends ProjectEvent {}
