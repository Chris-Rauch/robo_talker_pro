abstract class RoboEvent {}

class RoboSubmittedJobNameEvent extends RoboEvent {}

class RoboMultiJobEvent extends RoboEvent {}

class RoboErrorEvent extends RoboEvent {
  RoboErrorEvent(this.error);
  final Object error;
}
