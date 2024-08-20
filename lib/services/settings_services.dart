import 'dart:convert';
import 'dart:io';
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
      String downloadUrl =
          'https://path_to_chromium_build.zip'; // Replace with actual URL
      String savePath = '/path_to_save/chromium.zip';
      String unzipDir = '/path_to_unzip/chromium';
      String installDir = '/path_to_install/chromium';

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

  String getDefaultInstallPath() {
    if (Platform.isWindows) {
      return r'C:\Program Files\MyApp\Chromium';
    } else if (Platform.isMacOS) {
      return '/Applications/MyApp/Chromium';
    } else if (Platform.isLinux) {
      return '/usr/local/MyApp/Chromium';
    }
    return '';
  }

  Future<void> downloadChromium(String downloadUrl, String savePath) async {}

  Future<void> unzipChromium(String savePath, String unzipDir) async {}

  Future<void> replaceChromiumInstallation(
      String unzipdir, String installDir) async {}
}
