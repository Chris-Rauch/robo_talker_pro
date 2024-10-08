import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/services/settingsBloc/settings_event.dart';
import 'package:robo_talker_pro/services/settingsBloc/settings_state.dart';
import 'package:robo_talker_pro/services/settings_services.dart';
import 'package:robo_talker_pro/views/main_view/settings_view.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsServices services = SettingsServices();
  SettingsBloc() : super(LoadingSettingsState()) {
    //this event is called in SettingsBloc constructor
    on<FetchSettingsEvent>((event, emit) async {
      try {
        // attempt to load variables from memory
        await services.init();

        // if fetch from memory was unsuccessful, fetch from GitHub
        services.version ??= await services.fetchVersionFromGitHub();
        services.chromePath ??= await services.findChrome();

        // SettingsServices getter functions attempt to pull info from memory
        emit(ViewSettingsState(services.version, services.chromePath,
            services.memoPath, services.requestPath, services.getPath));
      } catch (e) {
        // TODO must handle all error here. If e is thrown, then the UI is left at a loading state
        emit(ErrorState(e));
      }
    });

    on<SaveDataEvent>(
      (event, emit) async {
        try {
          await services.save(event.key.name, event.data, path: event.path);
          emit(ViewSettingsState(services.version, services.chromePath,
              services.memoPath, services.requestPath, services.getPath));
        } catch (e) {
          emit(ErrorState(e));
        }
      },
    );

    on<SelectFileEvent>(
      (event, emit) async {
        try {
          String? val;
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            allowMultiple: false,
            type: FileType.custom,
            allowedExtensions: ['py'],
          );

          if ((result != null) && (result.files.single.path != null)) {
            val = result.files.single.path;
          }

          Keys key = event.key;

          switch (event.key) {
            case Keys.memo_path:
              services.memoPath = val;
              break;
            case Keys.chrome_path:
              services.chromePath = val;
              break;
            case Keys.request_path:
              services.requestPath = val;
              break;
            case Keys.get_path:
              services.getPath = val;
              break;
            default:
          }

          emit(ViewSettingsState(services.version, services.chromePath,
              services.memoPath, services.requestPath, services.getPath));
        } catch (e) {
          emit(ErrorState(e));
        }
      },
    );

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

    add(FetchSettingsEvent());
  }
}
