import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/services/settingsBloc/settings_event.dart';
import 'package:robo_talker_pro/services/settingsBloc/settings_state.dart';
import 'package:robo_talker_pro/services/settings_services.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsServices services = SettingsServices();
  SettingsBloc() : super(LoadingSettingsState()) {
    //this event is called in the constructor
    on<FetchSettingsEvent>((event, emit) async {
      try {
        // attempt to fetch data from memory
        String? version = await services.fetchVersionFromMemory();
        String? path = await services.fetchChromePath();

        // if fetch from memory was unsuccessful, fetch from GitHub
        version = await services.fetchVersionFromGitHub() ?? 'Cannot verify';
        path = await services.findChrome() ?? 'Verify before proceeding';

        emit(ViewSettingsState(version, path));
      } catch (e) {
        emit(ErrorState(e));
      }
    });

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
    });

    on<UpdateEvent>((event, emit) {
      SettingsServices services = SettingsServices();
      // update code here
      if (event.update == Update.chrome) {
      } else if (event.update == Update.chromium) {
        services.updateChromium();
      } else if (event.update == Update.software) {}
    });

    add(FetchSettingsEvent());
  }
}
