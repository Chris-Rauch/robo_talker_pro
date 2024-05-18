/// Manages user inputs and integrates data with robotalker.com REST API
library robo_bloc;

import 'package:bloc/bloc.dart';
import 'robo_event.dart';
import 'robo_state.dart';

class RoboBloc extends Bloc<RoboEvent, RoboState> {
  RoboBloc() : super(RoboInitialState()) {
    on<RoboSubmittedJobNameEvent>((event, emit) async {
      // TODO
      // if(all fields are good) then emit RoboGoodInputState
      // else emit RoboErrorState
      //
      // limit name to under 50chars

      emit(RoboGoodInputState());
    });

    ///This event triggers a REST post to robotalker.com
    on<RoboMultiJobEvent>((event, emit) async {
      emit(RoboLoadingState());
      // make REST API post
      //await Job Post
      await Future.delayed(const Duration(seconds: 3));
      emit(RoboCallsActiveState());
    });
  }
}
