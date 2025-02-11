import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/services/settingsBloc/settings_event.dart';
import 'package:robo_talker_pro/services/settingsBloc/settings_state.dart';
import 'package:robo_talker_pro/services/settings_services.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsServices services = SettingsServices();
  SettingsBloc() : super(LoadingSettingsState()) {
    //this event is called in SettingsBloc constructor
    on<FetchSettingsEvent>((event, emit) async {
      try {
        // grab data
        //await services.init();

        // SettingsServices getter functions attempt to pull info from memory
        emit(
          ViewSettingsState(
            await services.version,
            await services.chromePath,
            await services.memoPath,
            await services.requestPath,
            await services.getPath,
            await services.collectionsPath,
            await services.pythonPath
          ),
        );
      } catch (e) {
        // TODO must handle all error here. If e is thrown, then the UI is left at a loading state
        emit(ErrorState(e));
      }
    });

    on<SaveDataEvent>(
      (event, emit) async {
        try {
          await services.save(event.key.name, event.data, path: event.path);
          emit(
            ViewSettingsState(
              await services.version,
              await services.chromePath,
              await services.memoPath,
              await services.requestPath,
              await services.getPath,
              await services.collectionsPath,
              await services.pythonPath
            ),
          );
        } catch (e) {
          emit(ErrorState(e));
        }
      },
    );

    on<SelectFileEvent>(
      (event, emit) async {
        try {
          // call the File Picker Widget
          String? val;
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            allowMultiple: false,
            type: FileType.custom,
            allowedExtensions: ['py'],
          );
          if ((result != null) && (result.files.single.path != null)) {
            val = result.files.single.path;
          }

          // the event will dictate which key to use
          switch (event.key) {
            case Keys.memo_path:
              await services.setMemoPath(val);
              break;
            case Keys.chrome_path:
              await services.setChromePath(val);
              break;
            case Keys.request_path:
              await services.setRequestPath(val);
              break;
            case Keys.get_path:
              await services.setGetPath(val);
              break;
            case Keys.collections_path:
              await services.setCollectionsPath(val);
              break;
            default:
          }

          // emit the updated state
          emit(
            ViewSettingsState(
              await services.version,
              await services.chromePath,
              await services.memoPath,
              await services.requestPath,
              await services.getPath,
              await services.collectionsPath,
              await services.pythonPath
            ),
          );
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
