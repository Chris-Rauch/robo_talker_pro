abstract class RoboEvent {}

class RoboSubmittedJobNameEvent extends RoboEvent {}

class RoboMultiJobEvent extends RoboEvent {
  final String folderPath;
  RoboMultiJobEvent(this.folderPath);
}

class RoboErrorEvent extends RoboEvent {
  final Object error;
  RoboErrorEvent(this.error);
}
