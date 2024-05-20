import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robo_talker_pro/services/fileBloc/file_bloc.dart';
import 'package:robo_talker_pro/services/fileBloc/file_event.dart';

class ProjectView extends StatelessWidget {
  const ProjectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildButton('Late Payment', () {
            _startProject(context, '/late_payment');
          }),
          const SizedBox(height: 20),
          _buildButton('Return Mail', () {
            _startProject(context, '/return_mail');
          }),
        ],
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }

  void _startProject(BuildContext context, String projectType) {
    Navigator.pushNamed(context, projectType);
    context.read<FileBloc>().add(const SelectFileViewEvent());
  }
}
