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

import 'package:robo_talker_pro/auxillary/enums.dart';

//import 'package:robo_talker_pro/auxillary/enums.dart';

abstract class ProjectState {}

class SelectProjectState extends ProjectState {}

class SelectProjectDataState extends ProjectState {
  ProjectType type;
  SelectProjectDataState(this.type);
}

class RunProjectState extends ProjectState {
  bool step1InProgress;
  bool step2InProgress;
  bool step3InProgress;
  bool jobDone;
  RunProjectState(
      {this.step1InProgress = false,
      this.step2InProgress = false,
      this.step3InProgress = false,
      this.jobDone = false});
}

class JobCompleteState extends ProjectState {}

class ProjectErrorState extends ProjectState {
  final Object error;
  final bool isMajor;
  ProjectErrorState(this.error, {this.isMajor = false});
}
