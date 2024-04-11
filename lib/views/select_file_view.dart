import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class SelectFileView extends StatefulWidget {
  final String projectType;
  const SelectFileView({super.key, required this.projectType});

  @override
  _SelectFileViewState createState() => _SelectFileViewState(projectType);
}

class _SelectFileViewState extends State<SelectFileView> {
  final String projectType;
  _SelectFileViewState(this.projectType);

  String displayText = "";

  Future<void> selectFile() async {
    // TODO: Implement file selection logic
    // Move this code to a BLoC
    File? pickedFile = await pickExcelFile();
    File readFile;

    print(pickedFile.toString());

    // read selected file
    if (pickedFile != null) {
      readFile = File(pickedFile.toString());
      readExcelFile(readFile);
      print('true');
    }
    else {
      return;
    }
    
    setState(() {
      displayText = "File selected!";
    });
  }

  void selectFolder() async {
    // TODO: Implement folder selection logic

    setState(() {
      displayText = "Folder selected!";
    });
  }

  void goBack() {
    Navigator.pop(context);
  }

  void goNext() {
    if (projectType == 'Late Payment') {
      Navigator.pushNamed(context, '/late_payment/robo_input');
    } else if (projectType == 'Return Mail') {
      Navigator.pushNamed(context, '/return_mail/progress_view');
    } else {
      setState(() {
        displayText = 'Something went wrong';
      });
    }
  }

  Future<File?> pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
    );

    if (result != null) {
      return File(result.files.single.path!);
    } else {
      return null;
    }
  }

  Future<void> readExcelFile(File file) async {
    var bytes = await file.readAsBytes();
    var excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
        print(table);
        print(excel.tables[table]!.maxColumns);
        print(excel.tables[table]!.maxRows);

        for (var row in excel.tables[table]!.rows) {
            print(row);
        }
    }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(projectType),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: selectFile,
              child: const Text("Select File"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: selectFolder,
              child: const Text("Select Folder"),
            ),
            const SizedBox(height: 16),
            Text(
              displayText,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: goBack,
                  child: const Text("Back"),
                ),
                ElevatedButton(
                  onPressed: goNext,
                  child: const Text("Next"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
