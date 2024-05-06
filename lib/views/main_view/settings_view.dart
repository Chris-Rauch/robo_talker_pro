import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              _buildSettingRowCustomImage("Chrome", 'lib/icons/chrome.png'),
              _buildSettingRowCustomImage("Chromium", 'lib/icons/chromium.png'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Implement check for updates
                },
                child: Text("Check for Updates"),
              ),
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
          const Icon(Icons.arrow_forward_ios),
        ],
      ),
    );
  }

  Widget _buildSettingRowCustomImage(String label, String iconPath) {
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
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
  }
}
