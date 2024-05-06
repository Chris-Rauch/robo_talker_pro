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
      await fileServices.handleLatePayment();
    });

    on<TriggerErrorEvent>((event, emit) {
      emit(FileIoErrorState(event.error));
    });
  }

  /// Returns a contact list in decoded JSON format. Removes 'bad' entries which
  /// will need to handled. JSON data is as follows:
  /// "contactlist" : [
  ///  {
  ///    "name": "Chris rauch"
  ///    "phone": "714-329-0331"
  ///    "var1": ""
  ///    "var2": ""
  ///    "var3": ""
  ///    "var4": ""
  ///  }...
  /// ]
  Future<String> getContacts(File latePaymentReport) async {
    List<Map<String, dynamic>> contactList = [];
    // open the file
    var bytes = latePaymentReport.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows) {
        final agentName = row[0];
        final contractNumber = row[3];
        final insuredName = row[4];
        final phoneNumber = row[5];
        final cancelDate = row[7];
        final amountDue = row[8];

        if (noCallList(agentName) ||
            noNumber(phoneNumber) ||
            duplicateNumber(phoneNumber)) {
          //remove from this file (data) and write to knew file
        } else {
          // Create the main JSON map with the contact list
          Map<String, dynamic> jsonData = {'contactlist': contactList};

          // Encode the JSON map to JSON
          String jsonEncoded = json.encode(jsonData);
          print(jsonEncoded);
        }
      }
    }

    return json.encode(contactList);
  }

  /**
     * Integrating GAAC's late payment report with robotalker.com requires additional formatting:
     *  1. Remove special chars
     *  2. Contract Numbers need to have spaces
     *  3. Dates need to be reformatted
     */

  /// Returns 'bad' entries that can't be posted to robotalker.com. Bad entries
  /// include:
  ///   1. No Call Agreement
  ///   2. No Numbers
  ///   3. Duplicate Numbers
  ///   4. TRK contracts
  Future<String> getBadEntries(File latePaymentReport) async {
    return '';
  }

  Future<bool> doNotCall(List<String> NCA, File file) async {
    return true;
  }

  bool noCallList(Data? data) {
    return true;
  }

  bool noNumber(Data? data) {
    return true;
  }

  bool duplicateNumber(Data? data) {
    return true;
  }
}
