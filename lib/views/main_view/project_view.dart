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
  DateTime _startDate = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 12, 15);
  DateTime _stopDate = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 12, 30);
  Widget? currentWidget;
  //bool _isLoading = true;

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
        } else if (state is ProjectLoadingState) {}
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
          } else if (state is JobCompleteState) {
            currentWidget = _finishedProjectUI(context);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start a Project'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Late Payment'),
              onPressed: () {
                _goNext(context,
                    const ProjectSelectedEvent(ProjectType.latePayment));
                _projectType = ProjectType.latePayment;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Return Mail'),
              onPressed: () {
                _goNext(context,
                    const ProjectSelectedEvent(ProjectType.returnMail));
                _projectType = ProjectType.returnMail;
              },
            ),
          ],
        ),
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
                    "Start Time: ${DateFormat('jm').format(_startDate)}"), // Display selected date and time for start time
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
                    'Stop Time: ${DateFormat('jm').format(_stopDate)}'), // Display selected date and time for stop time
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
    String formattedTime =
        DateFormat('h:mm a, MMMM d, yyyy').format(displayTime);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estimated Completion Time'),
      ),
      body: Center(
        child: Text(
          'Estimated completion time is $formattedTime.',
          style: const TextStyle(fontSize: 20.0),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _progressBarUI(BuildContext context, double progress) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts are being memo\'d'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 100),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LinearProgressIndicator(
              value: progress, // A value between 0.0 and 1.0
              backgroundColor: Colors.grey.shade300,
              color: Colors.green,
              minHeight: 12.0,
            ),
          ),
          Center(
            child: Text('${(progress * 100).toInt()}%'),
          )
        ],
      ),
    );
  }

  Widget _finishedProjectUI(BuildContext context) {
    return const Center(
      child: Text(
        'All done!',
        style: TextStyle(fontSize: 18),
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

        if (_startDate.isAfter(_stopDate)) {
          _stopDate = _startDate.add(const Duration(minutes: 15));
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _startDate.hour, minute: _startDate.minute),
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startDate = DateTime(_startDate.year, _startDate.month,
              _startDate.day, pickedTime.hour, pickedTime.minute);

          // automatically select an end time 15 minutes after start time
          _stopDate = _startDate.add(const Duration(minutes: 15));
        } else {
          _stopDate = DateTime(_stopDate.year, _stopDate.month, _stopDate.day,
              pickedTime.hour, pickedTime.minute);
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
