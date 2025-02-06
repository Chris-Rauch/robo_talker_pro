import 'dart:convert';
import 'dart:io';
import 'dart:js_interop';
import 'package:path_provider/path_provider.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/auxillary/shared_preferences.dart';

import 'project_event.dart';
import 'project_state.dart';
import 'package:bloc/bloc.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc() : super(SelectProjectState()) {
    on<ProjectSelectedEvent>((event, emit) {
      emit(SelectProjectDataState(event.projectType));
    });

    on<StartProjectEvent>((event, emit) async {
      try {
        String? scriptPath = await loadData(Keys.collections_path.name);
        String dataPath = (await getApplicationSupportDirectory()).path;
        String start = event.startTime.toIso8601String();
        String end = event.endTime.toIso8601String();
        String projectPath = event.filePath;

        if (scriptPath == null) {
          throw Exception("Cannot find project script. Is it set in settings?");
        } else if (!File(dataPath).existsSync()) {
          throw Exception("Can't find saved data file");
        }
        List<String> args = [scriptPath, dataPath, start, end, projectPath];

        // Call script and listen to stdout/stderr
        var pythonScript = await Process.start('python', args);
        pythonScript.stdout.transform(utf8.decoder).listen((data) {
          if (data == 'Checking system requirements') {
            emit(RunProjectState(step1InProgress: true));
          } else if (data == 'Waiting on the calls') {
            emit(RunProjectState(step2InProgress: true));
          } else if (data == 'Memo\'ing accounts') {
            emit(RunProjectState(step3InProgress: true));
          } else if (data == 'Done') {
            emit(RunProjectState(jobDone: true));
          }
        });

        pythonScript.stderr.transform(utf8.decoder).listen((data) {
          if (data.contains("Need collections report")) {
            emit(ShowFilePicker(pythonScript));
          } else {
            emit(ProjectErrorState("Python wrote to stderr: $data",
                isMajor: true));
          }
        });
        final code = await pythonScript.exitCode;
        emit(JobCompleteState(exitCode: code));
      } catch (e) {
        emit(ProjectErrorState("Error caught in ProjectBloc: ${e.toString()}",
            isMajor: true));
      }
    });
  }
}

// TODO process.stdout should return jobID
// save jobID to .project.json

// TODO poll the resource
/*
            JOB DETAILS MAY BE REQUESTED:
            You can get JSON details for each Job accessing: GetJobDetail.ashx
            By groupName :https://robotalker.com/GetJobDetail.ashx?groupName=xxxxxxxxx(hipaa
            requires “&token=xxxxxx”) By jobId and userId
            https://robotalker.com/GetJobDetail.ashx?jobId=XXXXX&userId=xxxxxx(hipaa requires
            “&token=xxxxxx”)
            You may also get details about any job here:
            https://robotalker.com/GetJobDetail.ashx?jobId=1006601&userId=2402

            timeTzOffset	-04:00:00
          */
