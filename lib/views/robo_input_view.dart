import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robo_talker_pro/auxillary/error_popup.dart';
import 'package:robo_talker_pro/services/roboBloc/robo_bloc.dart';
import 'package:robo_talker_pro/services/roboBloc/robo_event.dart';
import 'package:robo_talker_pro/services/roboBloc/robo_state.dart';
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
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay stopTime = TimeOfDay.now();
  DateTime startDate = DateTime.now();
  DateTime stopDate = DateTime.now();
  DateTime startDateTime = DateTime.now();
  DateTime stopDateTime = DateTime.now();

  Future<void> _selectDateTime(BuildContext context, bool isStartTime) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartTime ? startDate : stopDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      if(!mounted) {
        throw Exception('Error in _selectDateTime');
      }
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: isStartTime ? startTime : stopTime,
      );
      if (pickedTime != null) {
        DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          (pickedTime.minute / 15).round() * 15,
        );
        setState(() {
          if (isStartTime) {
            startTime = pickedTime;
            startDate = pickedDate;
            // Use selectedDateTime for the combined date and time
            startDateTime = selectedDateTime;
          } else {
            stopTime = pickedTime;
            stopDate = pickedDate;
            // Use selectedDateTime for the combined date and time
            stopDateTime = selectedDateTime;
          }
        });
      }
    }
  }

  void _goNext() {
    context.read<RoboBloc>().add(RoboMultiJobEvent(_folderPath));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoboBloc, RoboState>(
      builder: (context, state) {
        context.visitAncestorElements((element) => false);
        if (state is RoboInitialState) {
          _goodInput = false;
        } else if (state is RoboGoodInputState) {
          _goodInput = true; //allow user to submit job
        } else if (state is RoboCallsActiveState) {
          return const ProgressBarView();
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
              onEditingComplete: () {
                context.read<RoboBloc>().add(RoboSubmittedJobNameEvent());
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                    "Start Time: ${DateFormat('yyyy-MM-dd HH:mm').format(startDateTime)}"), // Display selected date and time for start time
                const SizedBox(width: 32),
                ElevatedButton(
                  onPressed: () => _selectDateTime(context, true),
                  child: const Text("Select Time"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                    "Stop Time: ${DateFormat('yyyy-MM-dd HH:mm').format(stopDateTime)}"), // Display selected date and time for stop time
                const SizedBox(width: 32),
                ElevatedButton(
                  onPressed: () => _selectDateTime(context, false),
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
                  onPressed: () => (_goodInput) ? _goNext() : null,
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
