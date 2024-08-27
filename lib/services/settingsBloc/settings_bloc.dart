import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/services/settingsBloc/settings_event.dart';
import 'package:robo_talker_pro/services/settingsBloc/settings_state.dart';
import 'package:robo_talker_pro/services/settings_services.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(InitialState()) {
    on<CheckForUpdatesEvent>((event, emit) async {
      Process p;

      if (Platform.isWindows) {
      } else if (Platform.isMacOS) {
        p = await Process.start(
            '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
            ['--version']);
      } else if (Platform.isLinux) {
        p = await Process.start('google-chrome', ['--version']);
      }

      emit(InitialState());
    });

    on<UpdateEvent>((event, emit) {
      SettingsServices services = SettingsServices();
      // update code here
      if (event.update == Update.chrome) {
      } else if (event.update == Update.chromium) {
        services.updateChromium();
      } else if (event.update == Update.software) {}
    });
  }
}
