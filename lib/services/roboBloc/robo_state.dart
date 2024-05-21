abstract class RoboState {}

class RoboInitialState extends RoboState {}

class RoboCallsActiveState extends RoboState {}

class RoboGoodInputState extends RoboState {
  final bool jobName, startTime, stopTime, enoughFunds;
  RoboGoodInputState(
      {this.jobName = false,
      this.startTime = false,
      this.stopTime = false,
      this.enoughFunds = false});
}

class RoboErrorState extends RoboState {
  RoboErrorState(this.error);
  final Object error;
}

class RoboLoadingState extends RoboState {}
