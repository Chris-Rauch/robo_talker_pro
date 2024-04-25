import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


// Save data to a file
Future<void> saveData(String key, dynamic data) async {
  Map<String, dynamic> savedData = {};
  try {
    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/preferences.json');

    // if file does not exist, create one
    if (!file.existsSync()) {
      file.create();
    }

    // fetch data from file
    final jsonData = file.readAsStringSync();
    savedData = json.decode(jsonData);

    // Update data with new value
    savedData[key] = data;

    // Write updated data to file
    file.writeAsStringSync(json.encode(savedData));
  } catch (e) {
    print(e);
  }
}

// Load data from a file
Future<String?> loadData(String key) async {
  try {
    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/preferences.json');

    if (!file.existsSync()) {
      // if the file doesn't exist then create one
      file.create();
      return null;
    }

    //if it does exist get its data
    final jsonData = file.readAsStringSync();
    final savedData = json.decode(jsonData);
    return savedData[key] as String;
  } catch (e) {
    print(e);
  }
  return null;
}
