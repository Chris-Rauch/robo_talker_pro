import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;

class SettingsServices {
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
}
