/// This library defines the states for handling File IO operations in the application.
/// It includes different state classes representing the various stages of File IO,
/// such as loading, success, and error states. These states can be used in conjunction
/// with a BLoC to manage and respond to File IO events in a structured manner.
///
/// The library helps abstract the complexities of File IO management by providing
/// clear state definitions that the rest of the application can respond to.
/// For instance, it can be used to track the progress of a file upload or download,
/// as well as to handle potential errors during these operations.
library project_state_bloc;

//import 'package:robo_talker_pro/auxillary/enums.dart';

abstract class ProjectState {}

class ProjectInitialState extends ProjectState {}

class ChooseProjectState extends ProjectState {}

class ChooseFilePathsState extends ProjectState {}

class ChooseCallInfoState extends ProjectState {
  String jobName;
  ChooseCallInfoState(this.jobName);
}

class ProjectLoadingState extends ProjectState {}

/// This is the state when the program is waiting for Robo Talker to finish
/// call. It will be polling a .ashx resource
class PollingResourceState extends ProjectState {
  DateTime estimatedCompletionTime;
  PollingResourceState(this.estimatedCompletionTime);
}

/// State when to indicate the progress made on python scripts. Currently used
/// for memo_accounts.py
class ProgressState extends ProjectState {
  double progress;
  ProgressState(this.progress);
}

class JobCompleteState extends ProjectState {}

/// Triggers a error dialogue to the user.
/// [error] - message to be displayed
/// [isMajor] - true yields a pop up window. False, a snack bar
class ProjectErrorState extends ProjectState {
  final Object error;
  final bool isMajor;
  ProjectErrorState(this.error, {this.isMajor = false});
}
