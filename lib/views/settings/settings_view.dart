import 'package:flutter/material.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/auxillary/file_pickers.dart';
import 'package:robo_talker_pro/auxillary/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  SettingsViewState createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  final _collectionsController = TextEditingController();
  final _pythonController = TextEditingController();
  String version = '2.0.0';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadData(Keys.collections_path.name).then((value) {
      _collectionsController.text = value ?? '';
    });
    loadData(Keys.python_path.name).then((value) {
      _pythonController.text = value ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return _settingsView(context, version);
  }

  Widget _settingsView(BuildContext context, String? version) {
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
              _buildSettingRow("Version", Icons.system_update_alt, "2.0.0"),
              const SizedBox(height: 20),
              _buildSectionHeader("Paths"),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _collectionsController,
                      decoration: const InputDecoration(
                        hintText: 'Collections Script',
                      ),
                      onSubmitted: (value) async {
                        String? val = await selectFile(["py"]);
                        if(val.isNotEmpty) {
                        saveData(Keys.collections_path.name, val);
                        _collectionsController.text = val;
                      }},
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      String? val = await selectFile(["py"]);
                      if(val.isNotEmpty) {
                      saveData(Keys.collections_path.name, val);
                      _collectionsController.text = val;
                    }},
                    child: const Text('Select Path'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pythonController,
                      decoration: const InputDecoration(
                        hintText: 'Python Script',
                      ),
                      onSubmitted: (value) async {
                        String? val = await selectFile(["exe"]);
                        if (val.isNotEmpty) {
                          saveData(Keys.python_path.name, val);
                          _pythonController.text = val;
                        }
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      String? val = await selectFile(["exe"]);
                      if (val.isNotEmpty) {
                        saveData(Keys.python_path.name, val);
                        _pythonController.text = val;
                      }
                    },
                    child: const Text('Select Path'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
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

  Widget _buildSettingRow(String label, IconData icon, String data) {
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
              '$label $data',
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

  Future<void> _buildPopUp(BuildContext context, String messge) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(messge),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
