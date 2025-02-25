/*import 'package:bloc/bloc.dart';
import 'package:robo_talker_pro/auxillary/file_pickers.dart';
import 'package:robo_talker_pro/auxillary/shared_preferences.dart';
import 'package:robo_talker_pro/services/settingsBloc/settings_event.dart';
import 'package:robo_talker_pro/services/settingsBloc/settings_state.dart';
import 'package:robo_talker_pro/services/settings_services.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsServices services = SettingsServices();
  SettingsBloc() : super(LoadingSettingsState()) {
    on<FetchSettingsEvent>((event, emit) async {
      try {
        // grab data
        //await services.init();

        // SettingsServices getter functions attempt to pull info from memory
        emit(
          ViewSettingsState(await services.version,
              await services.collectionsPath, await services.pythonPath),
        );
      } catch (e) {
        // TODO must handle all error here. If e is thrown, then the UI is left at a loading state
        emit(ErrorState(e));
      }
    });

    on<SaveDataEvent>(
      (event, emit) async {
        try {
          await services.save(event.key.name, event.data);
          emit(
            ViewSettingsState(await services.version,
                await services.collectionsPath, await services.pythonPath),
          );
        } catch (e) {
          emit(ErrorState(e));
        }
      },
    );

    on<SelectFileEvent>(
      (event, emit) async {
        try {
          // call the File Picker Widget and save
          String? val = await selectFile(event.ext);
          saveData(key, data)
          await services.save(event.key.name, val);
          String? a = await services.collectionsPath;

          // emit the updated state
          emit(
            ViewSettingsState(await services.version,
                await services.collectionsPath, await services.pythonPath),
          );
        } catch (e) {
          emit(ErrorState(e));
        }
      },
    );

    on<CheckForUpdatesEvent>((event, emit) async {
      /*
      Process p;

      if (Platform.isWindows) {
      } else if (Platform.isMacOS) {
        p = await Process.start(
            '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
            ['--version']);
      } else if (Platform.isLinux) {
        p = await Process.start('google-chrome', ['--version']);
      }
      */
    });

    // Initial event that runs when the constructor is called
    add(FetchSettingsEvent());
  }
}
*/