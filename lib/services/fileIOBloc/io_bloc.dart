import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/services/fileIOBloc/io_services.dart';
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
      FileServices fileServices =
          FileServices(event.filePath, event.folderPath);
      String contacts;
      contacts = await fileServices.handleLatePayment();
      //await Future.delayed(const Duration(seconds: 10));
      //List<dynamic> jsonData = json.decode(contacts);
      //print(jsonData.length);
      contacts = contacts.replaceAll(',', ',\n');
      contacts = contacts.replaceAll('},', '\n},');

      File file = File('${event.folderPath}\\json.txt');
      await file.writeAsString(contacts);
      print(contacts);
    });

    on<TriggerErrorEvent>((event, emit) {
      emit(FileIoErrorState(event.error));
    });
  }
}
