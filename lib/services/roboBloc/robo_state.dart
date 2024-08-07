abstract class RoboState {}

class RoboInitialState extends RoboState {
  String jobName;
  RoboInitialState(this.jobName);
}

class RoboCallsActiveState extends RoboState {
  final String endtime;
  RoboCallsActiveState(this.endtime);
}

class RoboGoodInputState extends RoboState {
  //final bool jobName, startTime, stopTime, enoughFunds;
  //RoboGoodInputState();
}

class RoboErrorState extends RoboState {
  RoboErrorState(this.error);
  final Object error;
}

class RoboLoadingState extends RoboState {}
