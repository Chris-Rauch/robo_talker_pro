abstract class RoboState {}

class RoboInitialState extends RoboState {}

class RoboCallsActiveState extends RoboState {}

class RoboGoodInputState extends RoboState {}

class RoboErrorState extends RoboState {
  RoboErrorState(this.error);
  final Object error;
}

class RoboLoadingState extends RoboState {}
