import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/auxillary/shared_preferences.dart';
import 'package:robo_talker_pro/services/settingsBloc/settings_bloc.dart';
import 'package:robo_talker_pro/services/settingsBloc/settings_event.dart';
import 'package:robo_talker_pro/services/settingsBloc/settings_state.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  SettingsViewState createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  //SettingsViewState({super.key});

  final _chromePathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData(Keys.chromePath.toLocalizedString()).then((value) {
      _chromePathController.text = value ?? '';
    });

    if (_chromePathController.text == '') {
      _findChrome('C:\\Program Files\\Google').then((value) {
        _chromePathController.text = value ?? '';
      });
    }
  }

  /// Returns a path to the chrome exe. It looks recursively starting at root
  Future<String?> _findChrome(String root) async {
    const fileName = 'chrome.exe';
    final dir = Directory(root);

    if (!dir.existsSync()) {
      return null;
    }

    for (var file in dir.listSync(recursive: true, followLinks: false)) {
      if (file is File && file.path.endsWith(fileName)) {
        return file.path; // File found, return the path
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Software"),
                  _buildSettingRow("Version", Icons.system_update_alt),
                  const SizedBox(height: 20),
                  _buildSectionHeader("Paths"),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chromePathController,
                          decoration: const InputDecoration(
                            hintText: 'Chrome',
                          ),
                          onSubmitted: (value) => saveData(
                              Keys.chromePath.toLocalizedString(),
                              _chromePathController.text),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Select Path'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingRow(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(
            icon,
            size: 30,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement update action for the specific item
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRowCustomImage(
      BuildContext context, label, String iconPath) {
    Update? update;
    if (label == 'Software') {
      update = Update.software;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Image.asset(
            iconPath,
            width: 30,
            height: 30,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement update action for the specific item
              context.read<SettingsBloc>().add(UpdateEvent(update!));
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
