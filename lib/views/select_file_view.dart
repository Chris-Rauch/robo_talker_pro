import 'package:flutter/material.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/auxillary/error_popup.dart';
import 'package:robo_talker_pro/services/fileIOBloc/io_bloc.dart';
import 'package:robo_talker_pro/services/fileIOBloc/io_event.dart';
import 'package:robo_talker_pro/services/fileIOBloc/io_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robo_talker_pro/views/robo_input_view.dart';

import '../auxillary/button_styles.dart';

class SelectFileView extends StatefulWidget {
  final ProjectType projectType;
  const SelectFileView({super.key, required this.projectType});

  @override
  _SelectFileViewState createState() => _SelectFileViewState();
}

class _SelectFileViewState extends State<SelectFileView> {
  late final ProjectType _projectType;
  String _filePath = "";
  String _folderPath = "";
  bool _goodInput = false;

  @override
  void initState() {
    super.initState();
    _projectType = widget.projectType;
  }

  void goBack() {
    Navigator.pop(context);
  }

  void _goNext() {
    context
        .read<FileIoBloc>()
        .add(ReadFileEvent(_filePath, _folderPath, _projectType));
    if (_projectType == ProjectType.latePayment) {
      Navigator.pushNamed(context, '/late_payment/robo_input');
    } else if (_projectType == ProjectType.returnMail) {
      Navigator.pushNamed(context, '/return_mail/progress_view');
    } else {
      setState(() {
        _filePath = 'Something went wrong';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FileIoBloc, FileIoState>(
      builder: (context, state) {
        return _buildUI(context, state);
      },
    );
  }

  Widget _buildUI(BuildContext context, FileIoState state) {
    if (state is FileIoLoadingState) {
      return _buildLoadingUI();
    } else if (state is FileInitialState) {
      _filePath = '';
      _folderPath = '';
      return _buildSelectFileUI();
    } else if (state is FilePickedSuccessState) {
      _filePath = state.filePath;
      return _buildSelectFileUI();
    } else if (state is FolderPickedSuccessState) {
      _folderPath = state.folderPath;
      return _buildSelectFileUI();
    } else if (state is FileReadSuccessState) {
      return const RoboInputView();
    } else if (state is FileIoErrorState) {
      showSnackBarAfterBuild(context, state.error);
      return _buildSelectFileUI();
    } else {
      showSnackBarAfterBuild(context, 'Error');
      return _buildSelectFileUI();
    }
  }

  Widget _buildLoadingUI() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildSelectFileUI() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GAAC Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () =>
                  context.read<FileIoBloc>().add(const PickFileEvent()),
              child: const Text("Select File"),
            ),
            const SizedBox(height: 16),
            Text(
              _filePath,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: () =>
                  context.read<FileIoBloc>().add(const PickFolderEvent()),
              child: const Text("Select Folder"),
            ),
            const SizedBox(height: 16),
            Text(
              _folderPath,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: goBack,
                  child: const Text("Back"),
                ),
                ElevatedButton(
                  style: (_filePath.isNotEmpty && _folderPath.isNotEmpty)
                      ? enabledButtonStyle
                      : disabledButtonStyle,
                  onPressed: () =>
                      (_filePath.isNotEmpty && _folderPath.isNotEmpty)
                          ? _goNext()
                          : null,
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //Button Styles
}
