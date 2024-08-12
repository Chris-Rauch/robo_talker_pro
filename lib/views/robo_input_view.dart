/*

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robo_talker_pro/auxillary/error_popup.dart';
import 'package:robo_talker_pro/services/roboBloc/robo_bloc.dart';
import 'package:robo_talker_pro/services/roboBloc/robo_event.dart';
import 'package:robo_talker_pro/services/roboBloc/robo_state.dart';
import 'package:robo_talker_pro/views/call_progress_view.dart';
import 'package:robo_talker_pro/views/progress_view.dart';
import 'package:intl/intl.dart';
import '../auxillary/button_styles.dart';

class RoboInputView extends StatefulWidget {
  const RoboInputView({super.key});

  @override
  RoboInputViewState createState() => RoboInputViewState();
}

class RoboInputViewState extends State<RoboInputView> {
  final _jobName = TextEditingController();
  bool _goodInput = false;

  late final String _folderPath;
  TimeOfDay _startTime = const TimeOfDay(hour: 12, minute: 15);
  TimeOfDay _stopTime = const TimeOfDay(hour: 12, minute: 30);
  DateTime _startDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<RoboBloc>().add(RoboInitializeEvent());
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

  void _goNext() {
    context.read<RoboBloc>().add(
        RoboSubmitJobEvent(_jobName.text, _startDate, _startTime, _stopTime));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoboBloc, RoboState>(
      builder: (context, state) {
        context.visitAncestorElements((element) => false);
        if (state is RoboInitialState) {
          _jobName.text = state.jobName;
        } else if (state is RoboGoodInputState) {
          //TODO show summary of outbound calls
          context.read<RoboBloc>().add(RoboMultiJobEvent());
        } else if (state is RoboCallsActiveState) {
          return CallProgressView(
            callEndTime: state.endtime,
          );
        } else if (state is RoboLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RoboErrorState) {
          showSnackBarAfterBuild(context, state.error);
        } else {
          showSnackBarAfterBuild(context, 'Something went wrong');
        }
        return _buildRoboInputUI();
      },
    );
  }

  // State when first build: FileReadSuccessState
  Widget _buildRoboInputUI() {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(),
                ElevatedButton(
                  style:
                      (_goodInput) ? enabledButtonStyle : disabledButtonStyle,
                  onPressed: () => _goNext(),
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _callsActive(String endTime) {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'After the calls are finished I will start the memo\'s',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            'Estimated Completion Time: $endTime',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}


*/