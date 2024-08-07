import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:robo_talker_pro/auxillary/error_popup.dart';
import 'package:robo_talker_pro/auxillary/shared_preferences.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';

class NoCallAgreementView extends StatefulWidget {
  const NoCallAgreementView({super.key});

  @override
  NoCallAgreementViewState createState() => NoCallAgreementViewState();
}

class NoCallAgreementViewState extends State<NoCallAgreementView> {
  final TextEditingController controller = TextEditingController();
  List<dynamic> items = [];
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    loadData(Keys.ncaList.toLocalizedString()).then((value) {
      if (value != null) {
        setState(() {
          items = value; //TODO protect against unexpected values ie null
        });
      }
    });
  }

  void _filePicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['txt', 'json'],
      );

      if ((result != null) && (result.files.single.path != null)) {
        //open the file
        File file = File(result.files.single.path!);
        String contents = file.readAsStringSync();
        items = jsonDecode(contents);
        if (true) {
          
        }
        setState(() {
          items = jsonDecode(contents);
        });
      } else {
        throw Exception('User Exited');
      }
    } catch (e) {
      log('Error getting NCA List', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text(
            'NCA List',
            style: TextStyle(
              fontSize: 36,
            ),
          ),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "Company Name",
            ),
            onSubmitted: (value) {
              //convert user input to JSON
              Map<String, dynamic> jsonValue = jsonDecode(
                  '{"company":"${value.split(':')[0]}","code":"${value.split(':')[1]}"}');
              // Check if the item already exists in the list
              if (!items.contains(jsonValue)) {
                setState(() {
                  items.insert(0, jsonValue);
                  controller.clear();
                });
              } else {
                // Show a snackbar indicating that the item already exists
                showSnackBarAfterBuild(
                    context, 'That company is already in the list');
              }
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  //TODO make the two tile views look better
                  title: Row(
                    children: [
                      Text(items[index][Keys.company.toLocalizedString()]!),
                      Text(items[index][Keys.agentCode.toLocalizedString()]!),
                    ],
                  ),
                  tileColor: selectedIndex == index ? Colors.blue : null,
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FloatingActionButton(
                onPressed: _filePicker,
                tooltip: 'Add Document',
                child: const Icon(Icons.file_copy_rounded),
              ),
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    items.removeAt(selectedIndex);
                    selectedIndex = -1;
                  });
                },
                tooltip: 'Delete',
                child: const Icon(Icons.remove),
              ),
              FloatingActionButton(
                onPressed: () {
                  saveData(Keys.ncaList.toLocalizedString(), items);
                },
                tooltip: 'Save',
                child: const Icon(Icons.save),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
