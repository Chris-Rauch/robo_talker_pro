import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robo_talker_pro/auxillary/error_popup.dart';
import 'package:robo_talker_pro/auxillary/file_pickers.dart';
import 'package:robo_talker_pro/services/projectBloc/project_bloc.dart';
import 'package:robo_talker_pro/services/projectBloc/project_state.dart';
import 'package:robo_talker_pro/views/project_views/project_in_progress_view.dart';
import 'package:robo_talker_pro/views/project_views/select_project_data_view.dart';
import 'package:robo_talker_pro/views/project_views/select_project_view.dart';
import 'package:robo_talker_pro/views/widgets/error.dart';

class ProjectView extends StatelessWidget {
  const ProjectView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectBloc, ProjectState>(
      listener: (context, state) async {
        if (state is ProjectErrorState) {
          showSnackBarAfterBuild(context, state.error);
        } else if (state is ShowFilePicker) {
          String filePath = "";
          Future.microtask(() async {
            filePath = await selectFile();
          });
          stdout.write(filePath);
        }
      },
      buildWhen: (previous, current) {
        return current is! ShowFilePicker;
      },
      builder: (context, state) {
        if (state is SelectProjectState) {
          return const SelectProjectView();
        } else if (state is SelectProjectDataState) {
          return SelectProjectDataView(type: state.type);
        } else if (state is JobCompleteState) {
          return _finishedProjectUI(context);
        } else if (state is RunProjectState) {
          return ProgressView(state.step1InProgress, state.step2InProgress,
              state.step3InProgress, state.jobDone);
        } else {
          return const ErrorWidgetDisplay(message: 'Unknown State');
        }
      },
    );
  }


  // === UI Elements ===========================================================
  // ==========================================================================

  Widget _finishedProjectUI(BuildContext context) {
    return const Center(
      child: Text(
        'All done!',
        style: TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }
}
