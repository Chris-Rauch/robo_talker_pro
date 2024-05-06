//import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robo_talker_pro/auxillary/error_popup.dart';
import 'package:robo_talker_pro/services/roboBloc/robo_bloc.dart';
import 'package:robo_talker_pro/services/roboBloc/robo_event.dart';
import 'package:robo_talker_pro/services/roboBloc/robo_state.dart';
import 'package:robo_talker_pro/views/progress_view.dart';

import '../auxillary/button_styles.dart';
//import 'package:time_picker_spinner/time_picker_spinner.dart';

class RoboInputView extends StatefulWidget {
  const RoboInputView({super.key});

  @override
  _RoboInputViewState createState() => _RoboInputViewState();
}

class _RoboInputViewState extends State<RoboInputView> {
  final _jobName = TextEditingController();
  bool _goodInput = false;
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay stopTime = TimeOfDay.now();

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTime,
    );
    if (picked != null) {
      picked = TimeOfDay(
        hour: picked.hour,
        minute: (picked.minute / 15).round() * 15,
      );
    }
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked!;
        } else {
          stopTime = picked!;
        }
      });
    }
  }

  void _goNext() {
    context.read<RoboBloc>().add(RoboMultiJobEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoboBloc, RoboState>(
      builder: (context, state) {
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
                Text("Start Time: ${startTime.hour}:${startTime.minute}"),
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
                Text("Stop Time: ${stopTime.hour}:${stopTime.minute}"),
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
