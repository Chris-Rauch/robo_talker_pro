import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/services/settingsBloc/settings_bloc.dart';
import 'package:robo_talker_pro/services/settingsBloc/settings_event.dart';
import 'package:robo_talker_pro/services/settingsBloc/settings_state.dart';
import 'package:robo_talker_pro/views/widgets/error.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  SettingsViewState createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  final _collectionsController = TextEditingController();
  final _pythonController = TextEditingController();
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
            _collectionsController.text = state.collectionsPath ?? '';
            _pythonController.text = state.pythonPath ?? '';
            return _settingsView(context, state.version);
          } else if (state is LoadingSettingsState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ErrorState) {
            return ErrorWidgetDisplay(message: state.e.toString());
          } else {
            return const ErrorWidgetDisplay(message: "Unknown State");
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
                  "2.0.0"),
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
                      onSubmitted: (value) {
                        context
                            .read<SettingsBloc>()
                            .add(SaveDataEvent(Keys.collections_path, value));
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => context
                        .read<SettingsBloc>()
                        .add(SelectFileEvent(Keys.collections_path)),
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
                      onSubmitted: (value) {
                        context
                            .read<SettingsBloc>()
                            .add(SaveDataEvent(Keys.python_path, value));
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => context
                        .read<SettingsBloc>()
                        .add(SelectFileEvent(Keys.python_path)),
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
