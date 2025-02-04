import 'dart:convert';
import 'dart:io';
import 'project_event.dart';
import 'project_state.dart';
import 'package:bloc/bloc.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc() : super(SelectProjectState()) {
    on<InitializeProjectEvent>((event, emit) {
      // pop up indicating lost progress
      // reset .project.json data
      emit(SelectProjectState());
    });

    on<ProjectSelectedEvent>((event, emit) {
      emit(SelectProjectDataState(event.projectType));
    });

    /// All necessary information has been received. Make HTTP request
    on<StartProjectEvent>((event, emit) async {
      print(
          'Starting project with ${event.type}, ${event.filePath}, ${event.startTime}, ${event.endTime}');

      try {
        var pythonScript = await Process.start('python',
            ['C:\\Users\\rauch\\Projects\\flutter_ui_testing\\test.py']);
        // Listen to the stdout stream

        pythonScript.stdout.transform(utf8.decoder).listen((data) {
          print('Hello there! Here\'s the data: $data');
          if (data.contains('Grabbing Collections Report')) {
            emit(RunProjectState(step1InProgress: true));
          } else if (data.contains('Scheduling job with RoboTalker')) {
            emit(RunProjectState(step2InProgress: true));
          } else if (data.contains('Memo\'ing accounts')) {
            emit(RunProjectState(step3InProgress: true));
          } else if (data.contains('Done')) {
            emit(RunProjectState(step3InProgress: true));
          }
        });

        await pythonScript.exitCode;
        emit(RunProjectState());
      } catch (e) {
        print(e);
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
