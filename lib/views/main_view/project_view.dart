import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:robo_talker_pro/auxillary/button_styles.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/auxillary/error_popup.dart';
import 'package:robo_talker_pro/services/projectBloc/project_bloc.dart';
import 'package:robo_talker_pro/services/projectBloc/project_event.dart';
import 'package:robo_talker_pro/services/projectBloc/project_state.dart';
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
  ProjectType _projectType = ProjectType.latePayment;
  TimeOfDay _startTime = const TimeOfDay(hour: 12, minute: 15);
  TimeOfDay _stopTime = const TimeOfDay(hour: 12, minute: 30);
  DateTime _startDate = DateTime.now();
  DateTime _stopDate = DateTime.now();
  Widget? currentWidget;

/*
  @override
  void initState() {
    context.read<FileBloc>().add(InitializeEvent());
    super.initState();
  }
  */

  // === build =================================================================
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectBloc, ProjectState>(
      listener: (context, state) {
        if (state is ProjectErrorState) {
          showSnackBarAfterBuild(context, state.error);
        }
      },
      child: BlocBuilder<ProjectBloc, ProjectState>(
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
          } else if (state is PollingResourceState) {
            currentWidget = _waitingUI(context, state.estimatedCompletionTime);
          } else if (state is ProgressState) {
            currentWidget = _progressBarUI(context, state.progress);
          } else if (state is PollingResourceState) {
            currentWidget =
                _pollingResourceUI(context, state.estimatedCompletionTime);
          } else if (state is ProjectErrorState) {
            // 'skip' the rebuild process to show error to user
          } else {
            // when ProjectView is opened for the first time
            currentWidget = _chooseProjectUI(context);
          }
          return currentWidget ?? _chooseProjectUI(context);
        },
      ),
    );
  }

  // === UI Elements ===========================================================
  // ===========================================================================
  Widget _chooseProjectUI(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            child: const Text('Late Payment'),
            onPressed: () {
              _goNext(
                  context, const ProjectSelectedEvent(ProjectType.latePayment));
              _projectType = ProjectType.latePayment;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            child: const Text('Return Mail'),
            onPressed: () {
              _goNext(
                  context, const ProjectSelectedEvent(ProjectType.returnMail));
              _projectType = ProjectType.returnMail;
            },
          ),
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
            ElevatedButton(
              onPressed: () => _selectFile(context),
              child: const Text('Select File'),
            ),
            const SizedBox(height: 16),
            Text(
              _filePath.text,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: () => _selectFolder(context),
              child: const Text('Select Folder'),
            ),
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
                  child: const Text("Back"),
                  onPressed: () => _goNext(context, InitializeProjectEvent()),
                ),
                ElevatedButton(
                  child: const Text('Next'),
                  onPressed: () => _goNext(
                      context,
                      FilePathSelectedEvent(
                          _filePath.text, _folderPath.text, _projectType)),
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
                    ProjectSelectedEvent(_projectType),
                  ),
                  child: const Text('Back'),
                ),
                const Spacer(),
                ElevatedButton(
                  style: enabledButtonStyle,
                  onPressed: () => _goNext(
                    context,
                    PostJobEvent(
                      jobName: _jobName.text,
                      startTime: _startDate,
                      endTime: _stopDate,
                    ),
                  ),
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _waitingUI(BuildContext context, DateTime displayTime) {
    return const Scaffold();
  }

  Widget _progressBarUI(BuildContext context, double progress) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: LinearProgressIndicator(
            value: progress, // A value between 0.0 and 1.0
            backgroundColor: Colors.grey.shade300,
            color: Colors.green,
            minHeight: 12.0,
          ),
        ),
        const SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: () {
            setState(() {
              progress += 0.1;
              if (progress > 1.0) {
                progress = 0.0;
              }
            });
          },
          child: const Text('Increase Progress'),
        ),
      ],
    );
  }

  Widget _pollingResourceUI(BuildContext context, DateTime endDate) {
    String formattedTime = _formatDateTime(endDate);
    return Center(
      child: Text(
        'Calls have been sent. Expected to finish at: $formattedTime',
        style: const TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _loadingUI() {
    return const Center(child: CircularProgressIndicator());
  }

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
        _startDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
            _startDate.hour, _startDate.minute);
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
          _startDate = DateTime(_startDate.year, _startDate.month,
              _startDate.day, _startTime.hour, _startTime.minute);

          // automatically select an end time 15 minutes after start time
          if (_startTime.minute < 45) {
            _stopTime = TimeOfDay(
                hour: pickedTime.hour, minute: (pickedTime.minute + 15));
          } else {
            _stopTime = TimeOfDay(
                hour: (pickedTime.hour + 1), minute: (pickedTime.minute - 45));
          }
        } else {
          _stopTime = pickedTime;
          _stopDate = DateTime(_stopDate.year, _stopDate.month, _stopDate.day,
              _stopTime.hour, _stopTime.minute);
        }
      });
    }
  }

  void _goNext(BuildContext context, ProjectEvent event) {
    context.read<ProjectBloc>().add(event);
  }

  String _formatDateTime(DateTime dateTime) {
    // You can use any formatting package like intl to format the date
    return '${dateTime.toLocal()}'
        .split(' ')[0]; // Adjust this formatting as needed
  }
  
}
