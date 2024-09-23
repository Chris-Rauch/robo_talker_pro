import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/auxillary/shared_preferences.dart';

class SettingsServices {
  String? _version;
  String? _chromePath;

  // getters and setters
  String get version => _version ?? '';
  String get chromePath => _chromePath ?? '';
  set version(String rhs) {
    _version = rhs;
    save(Keys.software_version.name, version);
  }
  set chromePath(String rhs) {
    _chromePath = rhs;
    save(Keys.chrome_path.name, _chromePath!);
  }

  /// Makes an http get request to check the latest chrome version
  Future<String> fetchLatestChromeVersion() async {
    final response = await http.get(Uri.parse(
        'https://chromium.googlesource.com/chromium/src/+/refs/heads/main/chrome/VERSION'));
    if (response.statusCode == 200) {
      // Parse the response to extract the version number
      // This is an example; the exact implementation will depend on the data format
      final versionData = json.decode(response.body);
      return versionData['version']; // Example key, depends on the response
    } else {
      throw Exception('Failed to load latest Chrome version');
    }
  }

  Future<void> updateChromium() async {
    try {
      // Define paths and URLs
      String username = Platform.environment['USERNAME'] ?? 'Unknown';
      String downloadUrl =
          'https://download-chromium.appspot.com/dl/Win_x64?type=snapshots';
      String savePath = 'C:\\Users\\$username\\Downloads\\chromium.zip';
      String unzipDir = 'C:\\Users\\$username\\AppData\\Local\\Chromium';
      String installDir = 'C:\\Users\\$username\\AppData\\Local\\Chromium';

      // Download the build
      await downloadChromium(downloadUrl, savePath);

      // Unzip the build
      await unzipChromium(savePath, unzipDir);

      // Replace the existing installation
      await replaceChromiumInstallation(unzipDir, installDir);

      print('Chromium has been updated to the latest version.');
    } catch (e) {
      print('Failed to update Chromium: $e');
    }
  }

  String? getDefaultInstallPath() {
    if (Platform.isWindows) {
      return r'C:\Program Files\MyApp\Chromium';
    } else if (Platform.isMacOS) {
      return '/Applications/MyApp/Chromium';
    } else if (Platform.isLinux) {
      return '/usr/local/MyApp/Chromium';
    }
    return null;
  }

  Future<void> downloadChromium(String downloadUrl, String savePath) async {
    var uri = Uri.https(
        'download-chromium.appspot.com', '/dl/Win_x64', {'type': 'snapshots'});
    var response = await http.get(uri);

    if (response.statusCode == 200) {
      File file = File(savePath);
      file.writeAsBytesSync(response.bodyBytes);
    } else {
      print('Exited with status code: ${response.statusCode}');
    }
  }

  Future<void> unzipChromium(String savePath, String unzipDir) async {
    // read zip file from disk
    final file = File(savePath);
    final bytes = file.readAsBytesSync();

    //decode zip file
    final archive = ZipDecoder().decodeBytes(bytes);

    // extract contents
    for (final file in archive) {
      final filename = '$unzipDir/${file.name}';
      if (file.isFile) {
        final outFile = File(filename);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
      } else {
        await Directory(filename).create(recursive: true);
      }
    }
  }

  Future<void> replaceChromiumInstallation(
      String unzipdir, String installDir) async {}

  /// Returns a path to the chrome exe. It looks recursively starting at root
  Future<String?> findChrome() async {
    String? fileName;
    String? root;

    if (Platform.isWindows) {
      fileName = 'chrome.exe';
      root = 'C:\\Program Files\\Google\\Chrome\\Application';
    } else if (Platform.isMacOS) {
      fileName = 'Google Chrome.app';
      root = '/Applications';
    }

    final dir = Directory(root!);

    if (!dir.existsSync()) {
      return '';
    }

    for (var file in dir.listSync(recursive: true, followLinks: false)) {
      if (file is File && file.path.endsWith(fileName!)) {
        return file.path; // File found, return the path
      }
    }

    return '';
  }

  /// Description: Fetches software version from memory. Returns null if it's
  ///   not found.
  /// Return:
  ///   [Future<String?>] - The version number as a string or null
  Future<String?> fetchVersionFromMemory() async {
    return await load(Keys.software_version.name);
  }

  Future<String?> fetchVersionFromGitHub() async {
    String version = '';
    String repo = 'https://github.com/Chris-Rauch/robo_talker_pro.git';
    String homeDirPath =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE']!;
    Directory dir = Directory(homeDirPath);
    if (dir.existsSync()) {
      dir = Directory('$homeDirPath/robo_talker_pro');
    } else {
      return null;
    }

    await pullFromGit(repo, dir.path);

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
  Future<void> pullFromGit(String repositoryUrl, String destinationDir) async {
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
