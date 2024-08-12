import 'package:bloc/bloc.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/services/settingsBloc/settings_event.dart';
import 'package:robo_talker_pro/services/settingsBloc/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(InitialState()) {
    on<CheckForUpdatesEvent>((event, emit) {
      // get request or curl command goes here
      emit(InitialState());
    });

    on<UpdateEvent>((event, emit) {
      // update code here
      if(event.update == Update.chrome) {

      } else if(event.update == Update.chromium) {

      } else if(event.update == Update.software) {
        
      }

    });
  }
}
