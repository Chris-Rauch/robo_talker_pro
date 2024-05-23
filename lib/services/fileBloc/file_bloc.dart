import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:robo_talker_pro/auxillary/constants.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/auxillary/shared_preferences.dart';
import 'package:robo_talker_pro/services/fileBloc/file_services.dart';
import 'file_event.dart';
import 'file_state.dart';
import 'package:bloc/bloc.dart';
import 'package:path/path.dart' as p;

class FileBloc extends Bloc<FileEvent, FileState> {
  FileBloc() : super(FileInitialState()) {
    on<SelectFileViewEvent>((event, emit) async {
      emit(FileInitialState());
    });

    //Update the UI with the selected file.
    on<PickFileEvent>((event, emit) async {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: false,
          type: FileType.custom,
          allowedExtensions: ['xls', 'xlsx'],
        );

        if ((result != null) && (result.files.single.path != null)) {
          emit(FilePickedSuccessState(result.files.single.path!));
        } else {
          //emit(FileIoErrorState('User exited'));
        }
      } catch (e) {
        emit(FileErrorState(e));
      }
    });

    on<PickFolderEvent>((event, emit) async {
      try {
        String? dirPath = await FilePicker.platform.getDirectoryPath();
        if (dirPath != null) {
          emit(FolderPickedSuccessState(dirPath));
        }
      } catch (e) {
        emit(FileErrorState(e));
      }
    });

    on<ReadFileEvent>((event, emit) async {
      emit(FileLoadingState());
      String contactList = Keys.contactList.toLocalizedString();
      PROJECT_DATA_PATH = p.join(event.folderPath, PROJECT_DATA_FILE_NAME);

      try {
        if (File(PROJECT_DATA_PATH!).existsSync()) {
          throw Exception(
              'A project already exists in this Folder. Please select a new folder');
        }
        FileServices fileServices =
            FileServices(event.filePath, event.folderPath);
        String contacts = await fileServices.handleLatePayment();

        if (contacts.isNotEmpty) {
          await saveData(contactList, contacts, path: PROJECT_DATA_PATH);
          emit(FileReadSuccessState(
              contacts, p.join(event.folderPath, REPORT_FILE_NAME)));
        } else {
          emit(FileErrorState('Something went wrong. Contact list is empty'));
        }
      } catch (e) {
        if (e == PathAccessException) {
          emit(FileErrorState(
              'The file you selected is already open. Close it and try again'));
        } else if (e == PathAccessException) {
          emit(FileErrorState(
              '$e Something might be wrong with the file format'));
        } else {
          emit(FileErrorState(e));
        }
      }
    });

/*
    on<TriggerErrorEvent>((event, emit) {
      emit(FileIoErrorState(event.error));
    });
    */
  }
}
