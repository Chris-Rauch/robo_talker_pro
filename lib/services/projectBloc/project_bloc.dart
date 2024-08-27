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
        emit(ProjectLoadingState());
        // check user input
        if (filePath == null || folderPath == null) {
          throw Exception('Please make your selections');
        }

        // File Service object will handle all file operations
        var fileServices = FileServices(filePath, folderPath);

        // set global variable
        PROJECT_DATA_PATH = fileServices.getProjectFileLocation;

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
        int exitCode = -1;
        bool keepTrying = true;
        DateTime estimatedCompletion = job.endDate;

        startDate = startDate.add(const Duration(hours: 3));
        endDate = endDate.add(const Duration(hours: 3));

        await saveData(Keys.startTime.toLocalizedString(), startDate.toString(),
            path: PROJECT_DATA_PATH);
        await saveData(Keys.endTime.toLocalizedString(), endDate.toString(),
            path: PROJECT_DATA_PATH);
        await saveData(Keys.groupName.toLocalizedString(), jobName,
            path: PROJECT_DATA_PATH);
        String body = jsonEncode(await job.getBody(RequestType.multiJobPost));
        await saveData(Keys.requestBody.toLocalizedString(), body,
            path: PROJECT_DATA_PATH);

        // TODO if the user updates this data, then contactList needs to be altered

        // post to RoboTalker website
        exitCode = await job.start();
        if (exitCode != 0) {
          throw Exception('Could not post job to RoboTalker website');
        }

        // wait for calls to finish and grab their info
        while (keepTrying) {
          print(keepTrying);
          emit(PollingResourceState(
              estimatedCompletion.add(const Duration(minutes: 5))));
          keepTrying = !(await job.getJobDetails());
        }

        // start memo'ing accounts
        Process process = await Process.start('python', [
          "C:\\Users\\rauch\\Projects\\flutter\\robo_talker_pro\\lib\\scripts\\memo.py",
          PROJECT_DATA_PATH!,
          'head',
          await loadData(Keys.teUsername.toLocalizedString()),
          await loadData(Keys.tePassword.toLocalizedString()),
          MEMO_BODY,
          await loadData(Keys.chromePath.toLocalizedString())
        ]);

        // handle stdout
        await for (final output in process.stdout) {
          String pipe = String.fromCharCodes(output);
          List<String> pipeSections = pipe.split('~');

          if (pipeSections.length == 4) {
            double percent = double.parse(pipeSections[0]); // 1.0
            //double estimatedTime = double.parse(pipeSections[1]); // 10 (in minutes)
            //String success = pipeSections[2]; // success/failed
            //String row = pipeSections[3]; // ['Me', '7143290331', 'Answering Machine', '1', '9494709674', '8/26/2024 5:35:00 PM', '80', '8/26/2024 5:36:37 PM', '3021657', '', '', '8/26/2024 5:35:17 PM', '28', '1008603', 'My agency', '1763.46', 'Aug 12, 2024', 'M W F 1 0 1 3 1 4']
            emit(ProgressState(percent));
          }

          print('stdout: $output');
        }

        exitCode = await process.exitCode;
        print('Exit code: $exitCode');
        if (exitCode == 0) {
          emit(JobCompleteState());
        }
      } catch (e) {
        print('error $e');
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
