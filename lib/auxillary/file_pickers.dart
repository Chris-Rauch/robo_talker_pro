import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

Future<String> selectFile() async {
    String? filePath;
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if ((result != null) && (result.files.single.path != null)) {
      filePath = result.files.single.path;
    }
    return filePath ?? "";
  }

  Future<String> selectFolder(String initialDir) async {
    String? dirPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Select a Folder",
      lockParentWindow: false,
      initialDirectory: p.dirname(initialDir),
    );

    return dirPath ?? "";
  }