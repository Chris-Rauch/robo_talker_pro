import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/auxillary/file_pickers.dart';
import 'package:robo_talker_pro/services/projectBloc/project_bloc.dart';
import 'package:robo_talker_pro/services/projectBloc/project_event.dart';
import 'package:robo_talker_pro/services/projectBloc/project_state.dart';

class SelectProjectDataView extends StatefulWidget {
  final ProjectType type;
  const SelectProjectDataView({super.key, required this.type});

  @override
  SelectDataState createState() => SelectDataState();
}

class SelectDataState extends State<SelectProjectDataView> {
  late bool showDates;
  final _filePath = TextEditingController();
  final _folderPath = TextEditingController();
  DateTime _startDate = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 12, 15);
  DateTime _stopDate = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 12, 30);
  // ignore: non_constant_identifier_names
  DateTime _download_from = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day - 7);
  // ignore: non_constant_identifier_names
  DateTime _download_to = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day - 7);

  @override
  void initState() {
    super.initState();
    showDates = (widget.type == ProjectType.latePayment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFileSelectors(context),
            const SizedBox(height: 32),
            _buildDateSelectors(context),
            const SizedBox(height: 32),
            _buildNavButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelectors(BuildContext context) {
    String fileText = "";
    if (widget.type == ProjectType.latePayment) {
      fileText = "Late Payment";
    } else if (widget.type == ProjectType.returnMail) {
      fileText = "Return Mail";
    } else if (widget.type == ProjectType.collections) {
      fileText = "Collections";
    }
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$fileText File',
              style: const TextStyle(fontSize: 30),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Center(
              child: Tooltip(
                message:
                    "Leave this blank and it will be automatically downloaded",
                child: ElevatedButton(
                  onPressed: () async {
                    _filePath.text = await selectFile(["xlsx", "xls"]);
                    setState(() {});
                  },
                  child: const Text('Select File'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _filePath.text,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            if (showDates)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          'Date: ${DateFormat('EEE, M/d/y').format(_download_from)}'),
                      const SizedBox(width: 32),
                      ElevatedButton(
                        onPressed: () async {
                          DateTime? date = await _selectDownloadDate(context);
                          if (date != null) {
                            setState(() {
                              _download_from = date;
                            });
                          }
                        },
                        child: const Text("Select Date"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          'Date: ${DateFormat('EEE, M/d/y').format(_download_to)}'),
                      const SizedBox(width: 32),
                      ElevatedButton(
                        onPressed: () async {
                          DateTime? date = await _selectDownloadDate(context);
                          if (date != null) {
                            setState(() {
                              _download_to = date;
                            });
                          }
                        },
                        child: const Text("Select Date"),
                      ),
                    ],
                  ),
                ],
              ),
            /*
            const SizedBox(height: 8),
            if (widget.type == ProjectType.latePayment)
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    _folderPath.text = await selectFolder("");
                  },
                  child: const Text('Select Folder'),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              _folderPath.text,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            */
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelectors(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Call Times',
          style: TextStyle(fontSize: 30),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
          mainAxisAlignment: MainAxisAlignment.center,
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
          mainAxisAlignment: MainAxisAlignment.center,
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
      ],
    );
  }

  Widget _buildNavButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () => _goNext(context, StartOverEvent()),
          child: const Text('Back'),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () {
            final projBloc = BlocProvider.of<ProjectBloc>(context);
            if (projBloc.state is SelectProjectDataState) {
              DateTime? to;
              DateTime? from;

              // if the project is late payment then pass non-null values to event
              if (widget.type == ProjectType.latePayment) {
                from = _download_from;
                to = _download_to;
              }
              _goNext(
                context,
                StartProjectEvent(
                    type: widget.type,
                    filePath: _filePath.text,
                    folderPath: _folderPath.text,
                    startTime: _startDate,
                    endTime: _stopDate,
                    downloadFrom: from,
                    downloadTo: to),
              );
            }
          },
          child: const Text('Next'),
        ),
      ],
    );
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

  // Date selector for download file
  Future<DateTime?> _selectDownloadDate(BuildContext context) async {
    DateTime start = _startDate.subtract(const Duration(days: 14));
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: start,
      lastDate: DateTime(2100),
    );
    return pickedDate;
  }
}
