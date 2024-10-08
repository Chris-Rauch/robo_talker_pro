import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
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
  final _chromePathController = TextEditingController();
  final _memoPathController = TextEditingController();
  final _requestPathController = TextEditingController();
  final _getPathController = TextEditingController();
  String version = '';

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is ErrorState) {
          _buildPopUp(context, state.e.toString());
        }
      },
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is ViewSettingsState) {
            _chromePathController.text = state.chromePath ?? '';
            _memoPathController.text = state.memoPath ?? '';
            _requestPathController.text = state.requestPath ?? '';
            _getPathController.text = state.getPath ?? '';
            return _settingsView(context, state.version);
          } else if (state is LoadingSettingsState) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Scaffold();
          }
        },
      ),
    );
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
              _buildSettingRow("Version", Icons.system_update_alt,
                  version ?? 'Could not resolve version number'),
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
                      onSubmitted: (value) {},
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => context
                        .read<SettingsBloc>()
                        .add(SelectFileEvent(Keys.chrome_path)),
                    child: const Text('Select Path'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _memoPathController,
                      decoration: const InputDecoration(
                        hintText: 'Memo Accounts',
                      ),
                      onSubmitted: (value) {},
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => context
                        .read<SettingsBloc>()
                        .add(SelectFileEvent(Keys.memo_path)),
                    child: const Text('Select Path'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _requestPathController,
                      decoration: const InputDecoration(
                        hintText: 'HTTP request',
                      ),
                      onSubmitted: (value) {},
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => context
                        .read<SettingsBloc>()
                        .add(SelectFileEvent(Keys.request_path)),
                    child: const Text('Select Path'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _getPathController,
                      decoration: const InputDecoration(
                        hintText: 'HTTP get',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => context
                        .read<SettingsBloc>()
                        .add(SelectFileEvent(Keys.get_path)),
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
    final result = await showDialog(
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
