/// This library defines the states for handling File IO operations in the application.
/// It includes different state classes representing the various stages of File IO,
/// such as loading, success, and error states. These states can be used in conjunction
/// with a BLoC to manage and respond to File IO events in a structured manner.
///
/// The library helps abstract the complexities of File IO management by providing
/// clear state definitions that the rest of the application can respond to.
/// For instance, it can be used to track the progress of a file upload or download,
/// as well as to handle potential errors during these operations.
library file_state_bloc;

import 'package:robo_talker_pro/auxillary/enums.dart';

abstract class FileState {}

class FileInitialState extends FileState {}

class FileLoadingState extends FileState {}

class FilePickedSuccessState extends FileState {
  final String filePath;
  FilePickedSuccessState(this.filePath);
}

class FolderPickedSuccessState extends FileState {
  final String folderPath;
  FolderPickedSuccessState(this.folderPath);
}

class FileReadSuccessState extends FileState {
  FileReadSuccessState(this.contactList, this.followUp);
  final String contactList;
  final String followUp;
}

class FileErrorState extends FileState {
  final Object error;
  FileErrorState(this.error);
}

// =============================================================================
class ChooseProjectState extends FileState {}

class ChooseFilePathsState extends FileState {
}

class ChooseCallInfoState extends FileState {
  String jobName;
  ChooseCallInfoState(this.jobName);
}

class ProjectLoadingState extends FileState {}

class ProjectErrorState extends FileState {
  final Object error;
  ProjectErrorState(this.error);
}
