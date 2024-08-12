import 'dart:io';
import 'package:flutter/material.dart';
import 'package:robo_talker_pro/auxillary/constants.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/auxillary/shared_preferences.dart';
import 'package:robo_talker_pro/services/file_services.dart';
import 'package:robo_talker_pro/services/robo_services.dart';
import 'project_event.dart';
import 'project_state.dart';
import 'package:bloc/bloc.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc() : super(ProjectInitialState()) {
    on<InitializeProjectEvent>((event, emit) {
      // pop up indicating lost progress
      // reset .project.json data
      emit(ChooseProjectState());
    });

    on<ProjectSelectedEvent>((event, emit) {
      if (event.projectType == ProjectType.latePayment) {
        emit(ChooseFilePathsState()); //TODO include arguments in State
      } else {
        emit(ChooseFilePathsState());
      }
    });

    on<FilePathSelectedEvent>((event, emit) async {
      String? filePath = event.filePath;
      String? folderPath = event.folderPath;
      ProjectType projectType = event.projectType;

      try {
        // check user input
        if (filePath == null || folderPath == null) {
          // no input
          throw Exception('Please make your selections');
        } else if (!File(filePath).existsSync() ||
            !Directory(folderPath).existsSync()) {
          // input file moved
          throw Exception('File or Directory does not exist');
        }

        // File Service object will handle all file operations
        var fileServices = FileServices(filePath, folderPath);

        // check to see if a project already exists
        String projectFile = fileServices.getProjectFile;
        if (File(projectFile).existsSync()) {
          throw Exception('Project already exists in this directory');
        } else {
          PROJECT_DATA_PATH = projectFile;
        }

        // parse file
        String contacts = '';
        if (projectType == ProjectType.latePayment) {
          contacts = await fileServices.handleLatePayment();

          // save project type
          await saveData(Keys.projectType.toLocalizedString(), 'Late Payment',
              path: PROJECT_DATA_PATH);
        }

        // save contacts
        if (contacts.isNotEmpty) {
          String key = Keys.contactList.toLocalizedString();
          await saveData(key, contacts, path: PROJECT_DATA_PATH);
        } else {
          throw Exception('Late Payment Report is empty');
        }

        // move to Call Info View
        String jobName = fileServices.getGroupName();
        emit(ChooseCallInfoState(jobName));
      } catch (e) {
        if (e == PathAccessException) {
          emit(ProjectErrorState(
              'The file you selected is already open. Close it and try again'));
        } /*else if (e == PathAccessException) {
          emit(ProjectErrorState(
              '$e Something might be wrong with the file format'));
        } */
        else {
          emit(ProjectErrorState(e));
        }
      }
    });

    on<PostJobEvent>((event, emit) async {
      String jobName = event.jobName;
      DateTime startDate = event.startDate;
      TimeOfDay startTime = event.startTime;
      TimeOfDay endTime = event.stopTime;
      String contacts = await loadData(Keys.contactList.toLocalizedString(),
          path: PROJECT_DATA_PATH);

      try {
        RoboServices job = RoboServices(event.jobName, event.startDate,
            event.stopTime, LATE_PAYMENT_MESSAGE, contacts);

        // TODO this is going to be dependent on the user's $PATH variable (maybe python.exe too...)
        // post to RoboTalker website
        Process process =
            await Process.start('python', ['path/to/file', job.url]);
        int exitCode = await process.exitCode;
        if (exitCode == 0) {
          emit(
            // Bloc will build a widget telling the user to wait for calls to finish
            PollingResourceState(
              DateTime(
                startDate.year,
                startDate.month,
                startDate.day,
                endTime.hour,
                endTime.minute,
              ),
            ),
          );
        } else if (exitCode == -1) {
          throw Exception('Could not post job to RoboTalker website');
        }

        // get request to RoboTalker (wait for calls to finish and grab their info)
        process = await Process.start('python', ['path/to/file', 'get method']);
        exitCode = await process.exitCode;

        // start memo'ing accounts
        process = await Process.start('python', ['memo_accounts.py']);
        await for (final output in process.stdout) {
          if (output.length == 1) {
            int percentComplete = output.first;
            emit(ProgressState(percentComplete.roundToDouble()));
          }
        }

        exitCode = await process.exitCode;
        if (exitCode == 1) {
          emit(JobCompleteState());
        }
      } catch (e) {
        emit(ProjectErrorState(e));
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
