import 'dart:convert';
import 'dart:io';
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

    /// The user has chosen a Late Payment File and a directory for the 
    /// project. Parse the file to get contact info and save necessary data
    /// for the project.
    on<FilePathSelectedEvent>((event, emit) async {
      String? filePath = event.filePath;
      String? folderPath = event.folderPath;
      ProjectType projectType = event.projectType;
      String contacts = '';

      try {
        // check user input
        if (filePath == null || folderPath == null) {
          throw Exception('Please make your selections');
        }

        // File Service object will handle all file operations
        var fileServices = FileServices(filePath, folderPath);

        // parse file
        String projectTypeAsString = '';
        if (projectType == ProjectType.latePayment) {
          contacts = await fileServices.handleLatePayment();
          projectTypeAsString = 'Late Payment';
        } else if (projectType == ProjectType.returnMail) {
          // call python process
          projectTypeAsString = 'Return Mail';
        }

        // save contacts, groupName and project type
        String jobName = fileServices.getGroupName();
        String key = Keys.contactList.toLocalizedString();
        await saveData(key, contacts, path: PROJECT_DATA_PATH);
        key = Keys.groupName.toLocalizedString();
        await saveData(key, jobName, path: PROJECT_DATA_PATH);
        key = Keys.projectType.toLocalizedString();
        await saveData(key, projectTypeAsString, path: PROJECT_DATA_PATH);

        // set global variable
        PROJECT_DATA_PATH = fileServices.getProjectFileLocation;

        emit(ChooseCallInfoState(jobName));
      } catch (e) {
        if (e == PathAccessException) {
          emit(ProjectErrorState('The file you selected is already open.'));
        } else {
          emit(ProjectErrorState(e));
        }
      }
    });

    /// All necessary information has been received. Make HTTP request
    on<PostJobEvent>((event, emit) async {
      String jobName = event.jobName;
      DateTime startDate = event.startTime;
      DateTime endDate = event.endTime;

      try {
        RoboServices job = RoboServices(jobName, startDate, endDate);
        String headerAsString = jsonEncode(await job.getHeaders());
        String bodyAsString =
            jsonEncode(await job.getBody(RequestType.multiJobPost));
        String url = job.getUrl(RequestType.multiJobPost).toString();

        // save new data
        saveData(Keys.groupName.toLocalizedString(), jobName,
            path: PROJECT_DATA_PATH);

        // TODO this is going to be dependent on the user's $PATH variable (maybe python.exe too...)
        // post to RoboTalker website
        Process process = await Process.start('python', [
          '/lib/scripts/request.py',
          'POST',
          url,
          headerAsString,
          bodyAsString
        ]);
        int exitCode = await process.exitCode;
        if (exitCode == 0) {
          emit(
            // Bloc will build a widget telling the user to wait for calls to finish
            PollingResourceState(endDate),
          );
        } else {
          throw Exception('Could not post job to RoboTalker website');
        }

        // get request to RoboTalker (wait for calls to finish and grab their info)
        process = await Process.start('python', [
          '/lib/scripts/request.py',
          'GET',
          job.getUrl(RequestType.jobDetails).toString()
        ]);
        // Status code: 200
        // Response: No record found.
        exitCode = await process.exitCode;

        // start memo'ing accounts
        process = await Process.start('python', [
          '/lib/scripts/request.py',
        ]);
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
