/// Shared preferences file manages saving and loading JSON data. Possible keys
/// are: 1. nca_list: [company1, company2...]
library shared_preferences;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// Save data to a file
Future<void> saveData(String key, dynamic data, {String? path}) async {
  Map<String, dynamic> savedData = {};
  Directory directory;
  try {
    if (path == null) {
      directory = await getApplicationSupportDirectory();
    } else {
      directory = Directory(path);
    }
    File file;

    if (Platform.isWindows) {
      file = File('${directory.path}\\preferences.json');
    } else if (Platform.isMacOS || Platform.isLinux) {
      file = File('${directory.path}/preferences.json');
    } else {
      throw 'Unknown Operating System';
    }

    // if file does not exist, create one
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }

    // fetch data from file
    final jsonData = file.readAsStringSync();
    if (jsonData.isNotEmpty) {
      savedData = json.decode(jsonData);
    }

    // Update data with new value
    savedData[key] = data;

    // Write updated data to file
    file.writeAsStringSync(json.encode(savedData));
  } catch (e) {
    log('Could not save user preferences', error: e);
  }
}

// Load data from a file
Future<dynamic> loadData(String key, {Directory? dir}) async {
  try {
    Directory directory;
    if (dir == null) {
      directory = await getApplicationSupportDirectory();
    } else {
      directory = dir;
    }
    File file;

    if (Platform.isWindows) {
      file = File('${directory.path}\\preferences.json');
    } else if (Platform.isMacOS || Platform.isLinux) {
      file = File('${directory.path}/preferences.json');
    } else {
      throw 'Unknown Operating System';
    }

    if (!file.existsSync()) {
      // if the file doesn't exist then create one
      file.createSync(recursive: true);
      return null;
    }

    //if it does exist get its data
    final jsonData = file.readAsStringSync();
    if (jsonData.isNotEmpty) {
      final savedData = json.decode(jsonData);
      return savedData[key];
    }
  } catch (e) {
    print(e);
  }
  return null;
}