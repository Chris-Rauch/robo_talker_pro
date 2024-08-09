import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:robo_talker_pro/auxillary/button_styles.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/auxillary/error_popup.dart';
import 'package:robo_talker_pro/services/fileBloc/file_bloc.dart';
import 'package:robo_talker_pro/services/fileBloc/file_event.dart';
import 'package:robo_talker_pro/services/fileBloc/file_state.dart';
import 'package:robo_talker_pro/views/main_view/main_view.dart';
import 'package:path/path.dart' as p;

class ProjectView extends StatefulWidget {
  const ProjectView({super.key});

  @override
  ProjectViewState createState() => ProjectViewState();
}

class ProjectViewState extends State<ProjectView> {
  // Variables
  final _jobName = TextEditingController();
  final _filePath = TextEditingController();
  final _folderPath = TextEditingController();
  ProjectType? _projectType;
  TimeOfDay _startTime = const TimeOfDay(hour: 12, minute: 15);
  TimeOfDay _stopTime = const TimeOfDay(hour: 12, minute: 30);
  DateTime _startDate = DateTime.now();
  Widget? currentWidget;

/*
  @override
  void initState() {
    context.read<FileBloc>().add(InitializeEvent());
    super.initState();
  }
  */

  // === UI Elements ===========================================================
  // ===========================================================================
  @override
  //TODO fix the issue when user clicks different view mid project
  Widget build(BuildContext context) {
    return BlocListener<FileBloc, FileState>(
      listener: (context, state) {
        if (state is ProjectErrorState) {
          showSnackBarAfterBuild(context, state.error);
        }
      },
      child: BlocBuilder<FileBloc, FileState>(
        builder: (context, state) {
          if (state is ChooseProjectState) {
            currentWidget = _chooseProjectUI(context);
          } else if (state is ChooseFilePathsState) {
            currentWidget = _chooseFilePathsUI(context);
          } else if (state is ChooseCallInfoState) {
            _jobName.text = state.jobName;
            currentWidget = _chooseCallInfoUI(context);
          } else if (state is ProjectLoadingState) {
            currentWidget = _loadingUI();
          } else if (state is ProjectErrorState) {
            // 'skip' the rebuild process for the snack bar
          } else {
            currentWidget = _chooseProjectUI(
                context); //On start up when a state hasn't been set
          }
          return currentWidget ?? Container();
        },
      ),
    );
  }

  Widget _chooseProjectUI(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildButton('Late Payment', () {
            //_startProject(context, ProjectType.latePayment);
            _goNext(
                context, const ProjectSelectedEvent(ProjectType.latePayment));
            _projectType = ProjectType.latePayment;
          }),
          const SizedBox(height: 20),
          _buildButton('Return Mail', () {
            _goNext(
                context, const ProjectSelectedEvent(ProjectType.returnMail));
            _projectType = ProjectType.returnMail;
          }),
        ],
      ),
    );
  }

  Widget _chooseFilePathsUI(BuildContext context) {
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
            _buildButton("Select File", () {
              _selectFile(context);
            }),
            const SizedBox(height: 16),
            Text(
              _filePath.text,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            _buildButton("Select Folder", () {
              _selectFolder(context);
            }),
            const SizedBox(height: 16),
            Text(
              _folderPath.text,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _goNext(context, InitializeProjectEvent()),
                  child: const Text("Back"),
                ),
                ElevatedButton(
                  style: enabledButtonStyle,
                  onPressed: () => _goNext(
                      context,
                      FilePathSelectedEvent(
                          _filePath.text, _folderPath.text, _projectType!)),
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chooseCallInfoUI(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _jobName,
              decoration: const InputDecoration(
                hintText: "Job Name",
              ),
              /*onEditingComplete: () {
                context.read<RoboBloc>().add(RoboSubmitJobEvent(_jobName.text));
              },*/
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Date: ${DateFormat('EEE, M/d/y').format(_startDate)}'),
                const SizedBox(width: 32),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text("Select Date"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                    "Start Time: ${_startTime.format(context)}"), // Display selected date and time for start time
                const SizedBox(width: 32),
                ElevatedButton(
                  onPressed: () => _selectTime(context, true),
                  child: const Text("Select Time"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                    'Stop Time: ${_stopTime.format(context)}'), // Display selected date and time for stop time
                const SizedBox(width: 32),
                ElevatedButton(
                  onPressed: () => _selectTime(context, false),
                  child: const Text("Select Time"),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: enabledButtonStyle,
                  onPressed: () => _goNext(
                    context,
                    PostJobEvent(
                        jobName: _jobName.text,
                        startDate: _startDate,
                        startTime: _startTime,
                        stopTime: _stopTime),
                  ),
                  child: const Text('Back'),
                ),
                const Spacer(),
                ElevatedButton(
                  style: enabledButtonStyle,
                  onPressed: () => _postCallData(context),
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadingUI() {
    return const Center(child: CircularProgressIndicator());
  }
  // === End of UI Elements ====================================================

  // === Functions =============================================================
  // ===========================================================================
  Future<void> _selectFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if ((result != null) && (result.files.single.path != null)) {
      setState(() {
        _filePath.text = result.files.single.path ?? "";
      });
    }
  }

  Future<void> _selectFolder(BuildContext context) async {
    String? dirPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Select a Folder",
      lockParentWindow: false,
      initialDirectory: p.dirname(_filePath.text),
    );

    if (dirPath != null) {
      setState(() {
        _folderPath.text = dirPath;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _startDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _stopTime,
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
          if (_startTime.minute < 45) {
            _stopTime = TimeOfDay(
                hour: pickedTime.hour, minute: (pickedTime.minute + 15));
          } else {
            _stopTime = TimeOfDay(
                hour: (pickedTime.hour + 1), minute: (pickedTime.minute - 45));
          }
        } else {
          _stopTime = pickedTime;
        }
      });
    }
  }

  void _goNext(BuildContext context, FileEvent event) {
    context.read<FileBloc>().add(event);
  }

  void _postCallData(BuildContext context) {
    context.read<FileBloc>().add(PostJobEvent(
        jobName: _jobName.text,
        startDate: _startDate,
        startTime: _startTime,
        stopTime: _stopTime));
  }
  // === End of Functions ======================================================

  // Builds a generic looking button
  Widget _buildButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
