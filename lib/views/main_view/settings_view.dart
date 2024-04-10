import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Text(
              "Software",
              style: TextStyle(
                fontSize: 36,
              ),
            ),
            Row(
              children: [
                const Text('Version'),
                FloatingActionButton.extended(
                  label: const Text('Update'),
                  onPressed: () {},
                ),
              ],
            ),
            Row(
              children: [
                const Text('Chrome'),
                FloatingActionButton.extended(
                  label: const Text('Update'),
                  onPressed: () {},
                ),
              ],
            ),
            Row(
              children: [
                const Text('Chromium'),
                FloatingActionButton.extended(
                  label: const Text('Update'),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
