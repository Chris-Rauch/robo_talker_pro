/// This class manages saving and loading settings data from a file.
library settings_services;

import 'dart:io';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/auxillary/shared_preferences.dart';

class SettingsServices {
  String? _version;
  String? _collectionsPath;
  String? _pythonPath;

  // getters
  Future<String?> get version async {
    _version ??= await load(Keys.software_version.name);
    //_version ??= await fetchVersionFromGitHub(); // user needs git or this throws an error
    return _version;
  }

  Future<String?> get collectionsPath async {
    _collectionsPath = await load(Keys.collections_path.name);
    return _collectionsPath;
  }

  Future<String?> get pythonPath async {
    _pythonPath = await load(Keys.python_path.name);
    return _pythonPath;
  }

  // setters
  Future<void> setVersion(String? version) async {
    await save(Keys.software_version.name, version);
    _version = version;
  }

  Future<void> setCollectionsPath(String? collectionsPath) async {
    await save(Keys.collections_path.name, collectionsPath);
    _collectionsPath = collectionsPath;
  }

  Future<void> setPythonPath(String? pythonPath) async {
    await save(Keys.python_path.name, pythonPath);
    _pythonPath = pythonPath;
  }

  /// Description: Attempts to fetch data that is outside the stack of this
  ///   program. This data is necessary to run powershell and python HTTP
  ///   scripts. Data is also displayed to the user in SettingsView.
  ///   This data is necessary for the application to run. It sets the following
  ///
  /// - version - The currently installed version of Robo Talker Pro
  /// - chromePath - path to the users chrome application. Necessary to run
  ///   selenium web scraper (python package)
  /// - mempoPath - path to python script. Implements selenium to memo accounts
  /// - requestPath - path to python script. Implements a HTTP Request
  /// - getPath - path to python script. Implements HTTP Get request
  Future<void> init() async {
    // load data from memory
    await version;
    await collectionsPath;
  }

  /// Description: Fetches software version my GitHub repo. If found, save
  ///   version to memory.
  /// Return:
  ///   [Future<String?>] - The version number as a string or null
  Future<String?> fetchVersionFromGitHub() async {
    String version = '';
    String repo = 'https://github.com/Chris-Rauch/robo_talker_pro.git';
    String homeDirPath =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE']!;
    Directory dir = Directory('$homeDirPath/temp_dir_robo_talker_pro');

    if (dir.existsSync()) {
      return '';
    }

    await _pullFromGit(repo, dir.path);

    // read the file
    File markDownFile = File('${dir.path}/README.md');
    if (await markDownFile.exists()) {
      // Read the file content
      String content = await markDownFile.readAsString();
      int start = content.indexOf('(') + 2;
      int end = content.indexOf(')');
      version = content.substring(start, end);
    }

    // delete the dir
    dir.deleteSync(recursive: true);

    // save the data

    await setVersion(version);

    return version;
  }

  /// Description: Uses the Dart Process class to run git clone. RepositoryUrl
  ///   is the repo on GitHub and dir is the destination on the local device
  /// Returns:
  ///   Future<void> - Clones a repo on the local device. Make sure permissions
  ///   for folders are set.
  Future<void> _pullFromGit(String repositoryUrl, String destinationDir) async {
    // Clone the repository to a temporary directory
    var tempDir = Directory.systemTemp.createTempSync();
    var gitCloneCommand = ['git', 'clone', repositoryUrl, tempDir.path];

    // Run the git clone command
    var cloneProcess =
        await Process.start(gitCloneCommand[0], gitCloneCommand.sublist(1));
    await cloneProcess.exitCode;

    // Move the specified file or directory to the desired location

    // pulled succesfully from git
    if (tempDir.existsSync()) {
      Directory(destinationDir).createSync(recursive: true);
      await for (var entity in tempDir.list(recursive: true)) {
        var newPath = entity.path.replaceFirst(tempDir.path, destinationDir);
        if (entity is File) {
          entity.copySync(newPath);
        } else if (entity is Directory) {
          Directory(newPath).createSync(recursive: true);
        }
      }
    } else if (File(tempDir.path).existsSync()) {
      File(tempDir.path).copySync(destinationDir);
    }

    // Clean up the temporary directory
    tempDir.deleteSync(recursive: true);
  }

  /// Description: Custom Data Management class. Used to save user and program
  ///   data. Current implementation saves data to disk.
  Future<void> save(String key, dynamic data, {String? path}) async {
    await saveData(key, data, path: path);
  }

  /// Description: Custom Data Management class. Used to load user and program
  ///   data. Current implementation loads data to disk.
  Future<dynamic> load(String key, {String? path}) async {
    return await loadData(key);
  }
}
