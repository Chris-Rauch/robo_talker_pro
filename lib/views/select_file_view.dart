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

  void selectFile() async {
    // TODO: Implement file selection logic
    // Example using file_picker package:
    // File file = await FilePicker.getFile();
    // Update displayText or perform other actions based on the selected file.
    setState(() {
      displayText = "File selected!";
    });
  }

  void selectFolder() async {
    // TODO: Implement folder selection logic
    // Example using file_picker package:
    // Directory folder = await FilePicker.getDirectory();
    // Update displayText or perform other actions based on the selected folder.
    setState(() {
      displayText = "Folder selected!";
    });
  }

  void goBack() {
    Navigator.pop(context);
  }

  void goNext() {
    if (projectType == 'Late Payment') {
      Navigator.pushNamed(context, '/late_payment/robo_input/progress_view');
    } else if (projectType == 'Return Mail') {
      Navigator.pushNamed(context, '/return_mail/progress_view');
    } else {
      setState(() {
        displayText = 'Something went wrong';
      });
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
              child: Text("Select File"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: selectFolder,
              child: Text("Select Folder"),
            ),
            SizedBox(height: 16),
            Text(
              displayText,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: goBack,
                  child: Text("Back"),
                ),
                ElevatedButton(
                  onPressed: goNext,
                  child: Text("Next"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
