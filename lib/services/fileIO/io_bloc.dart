import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'io_event.dart';
import 'io_state.dart';
import 'package:bloc/bloc.dart';

class FileIoBloc extends Bloc<FileIoEvent, FileIoState> {
  FileIoBloc() : super(FileInitialState()) {
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
          emit(FileIoErrorState('User exited'));
        }
      } catch (e) {
        emit(FileIoErrorState(e));
      }
    });

    on<PickFolderEvent>((event, emit) async {
      try {
        String? dirPath = await FilePicker.platform.getDirectoryPath();
        if (dirPath != null) {
          emit(FolderPickedSuccessState(dirPath));
        }
      } catch (e) {
        emit(FileIoErrorState(e));
      }
    });

    on<ReadFileEvent>((event, emit) async {
      File file;

      try {
        // open the file
        file = File(event.filePath);
        var bytes = await file.readAsBytes();
        var excel = Excel.decodeBytes(bytes);

        if (event.projectType == ProjectType.latePayment) {
          //TODO read late payment file
        } else if (event.projectType == ProjectType.returnMail) {
          //TODO read return mail file
        }

        for (var table in excel.tables.keys) {
          print(table);
          print(excel.tables[table]!.maxColumns);
          print(excel.tables[table]!.maxRows);

          for (var row in excel.tables[table]!.rows) {
            print(row);
          }
        }
        emit(FileReadSuccessState());
      } catch (e) {
        emit(FileIoErrorState(e));
      }
    });

    on<TriggerErrorEvent>((event, emit) {
      emit(FileIoErrorState(event.error));
    });
  }
}
