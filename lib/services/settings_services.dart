//import 'dart:convert';
import 'dart:io';
//import 'package:archive/archive.dart';
//import 'package:http/http.dart' as http;
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/auxillary/shared_preferences.dart';
import 'package:robo_talker_pro/services/settingsBloc/settings_bloc.dart';

class SettingsServices {
  String? _version;
  String? _chromePath;
  String? _memoPath;
  String? _requestPath;
  String? _getPath;

  // === getters and setters ===
  // Getters will search for the variable using the this->load function
  String? get version {
    load(Keys.software_version.name).then((value) {
      _version = value;
    });

    return _version;
  }

  String? get chromePath {
    if (_chromePath == null) {
      load(Keys.chrome_path.name).then((value) {
        _chromePath = value;
      });
    }
    return _chromePath;
  }

  String? get memoPath {
    if (_memoPath == null) {
      load(Keys.memo_path.name).then((value) {
        _memoPath = value;
      });
    }
    return _memoPath;
  }

  String? get requestPath {
    if (_requestPath == null) {
      load(Keys.request_path.name).then((value) {
        _requestPath = value;
      });
    }
    return _requestPath;
  }

  String? get getPath {
    if (_getPath == null) {
      load(Keys.get_path.name).then((value) {
        _getPath = value;
      });
    }
    return _getPath;
  }

  // Setters will try attempt to save the data using this->save function
  set version(String? rhs) {
    _version = rhs;
    save(Keys.software_version.name, _version).then((value) => null);
  }

  set chromePath(String? rhs) {
    _chromePath = rhs;
    save(Keys.chrome_path.name, _chromePath);
  }

  set memoPath(String? rhs) {
    _memoPath = rhs;
    save(Keys.memo_path.name, _memoPath);
  }

  set requestPath(String? rhs) {
    _requestPath = rhs;
    save(Keys.request_path.name, _requestPath);
  }

  set getPath(String? rhs) {
    _getPath = rhs;
    save(Keys.get_path.name, _getPath);
  }

  /// Description: Attempts to initialize all the variable from memory.
  Future<void> init() async {
    version = await load(Keys.software_version.name);
    chromePath = await load(Keys.chrome_path.name);
    memoPath = await load(Keys.memo_path.name);
    requestPath = await load(Keys.request_path.name);
    getPath = await load(Keys.get_path.name);
  }

  /// Desription: Returns a path to the chrome exe. It looks recursively
  ///   starting at root. This path is needed for the memo.py script
  /// Returns:
  ///   Future<String?> - A path to the chrome executable. Null if not found.
  Future<String?> findChrome() async {
    String? fileName;
    List<String> roots;
    String? version;

    if (Platform.isWindows) {
      fileName = 'chrome.exe';
      roots = [
        'C:\\Program Files\\Google\\Chrome\\Application',
        'C:\\Program Files (x86)\\Google\\Chrome\\Application'
      ];
    } else if (Platform.isMacOS) {
      fileName = 'Google Chrome.app';
      roots = ['/Applications'];
    } else {
      roots = [];
    }

    for (var root in roots) {
      final dir = Directory(root);
      if (dir.existsSync()) {
        for (var file in dir.listSync(recursive: true, followLinks: false)) {
          if (file is File && file.path.endsWith(fileName!)) {
            chromePath = file.path;
            return file.path; // File found, return the path
          }
        }
      }
    }

    return version; // file not found
  }

  /// Description: Fetches software version from memory. Returns null if it's
  ///   not found.
  /// Return:
  ///   [Future<String?>] - The version number as a string or null
  Future<String?> fetchVersionFromMemory() async {
    return await load(Keys.software_version.name);
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

    this.version = version;

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
    } else {
      print(
          'The specified file or directory does not exist in the repository.');
    }

    // Clean up the temporary directory
    tempDir.deleteSync(recursive: true);
  }

  Future<String?> fetchChromePath() async {
    return await load(Keys.chrome_path.name);
  }

  Future<void> save(
    String key,
    dynamic data, {
    String? path,
  }) async {
    saveData(key, data, path: path);
  }

  Future<dynamic> load(String key, {String? path}) async {
    return await loadData(key);
  }
}
