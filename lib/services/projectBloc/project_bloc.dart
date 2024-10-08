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
      emit(ProjectLoadingState());
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
        List<dynamic> nca =
            await loadData(Keys.ncaList.toLocalizedString()) ?? [];
        var fileServices = FileServices(filePath, folderPath, nca);

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
        String key = Keys.contactlist.toLocalizedString();
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
      emit(ProjectLoadingState());
      String jobName = event.jobName;
      DateTime startDate = event.startTime.add(const Duration(hours: 3));
      DateTime endDate = event.endTime.add(const Duration(hours: 3));
      int exitCode = -1;
      bool keepTrying = true;
      DateTime estimatedCompletion = endDate.subtract(const Duration(hours: 3));

      try {
        String? username = await loadData(Keys.roboUsername.name);
        String? zKey = await loadData(Keys.z_token.name);
        String? callerId = await loadData(Keys.caller_id.name);
        String? contactList =
            await loadData(Keys.contactlist.name, path: PROJECT_DATA_PATH);
        if (username == null) {
          throw Exception('Username not provided. did you forget to save?');
        } else if (zKey == null) {
          throw Exception('Z Token not provided. did you forget to save?');
        } else if (contactList == null) {
          throw Exception('Couldn\'t find contact list');
        }

        // post to RoboTalker website
        RoboServices job = RoboServices(jobName, startDate, endDate, callerId,
            LATE_PAYMENT_MESSAGE, jsonDecode(contactList), username, zKey);
        String? body = jsonEncode(job.getBody(RequestType.multiJobPost));
        await saveData(Keys.request_body.name, body, path: PROJECT_DATA_PATH);
        exitCode = await job.post();
        if (exitCode != 0) {
          throw Exception('Could not post job to RoboTalker website');
        }

        // wait for calls to finish and grab their info
        //int testingInt = 0;
        while (keepTrying) {
          //print('keep trying loop: ${testingInt++}');
          //print("Estimated completion: ${estimatedCompletion.toString()}");
          emit(PollingResourceState(estimatedCompletion));
          keepTrying = !(await job.getJobDetails());
          estimatedCompletion =
              estimatedCompletion.add(const Duration(minutes: 5));
        }

        // start memo'ing accounts
        String memoPath = await loadData(Keys.memo_path.name);
        Process process = await Process.start('python', [
          memoPath,
          PROJECT_DATA_PATH!,
          'head',
          await loadData(Keys.teUsername.toLocalizedString()),
          await loadData(Keys.tePassword.toLocalizedString()),
          MEMO_BODY,
          await loadData(Keys.chrome_path.toLocalizedString())
        ]);

        // handle stdout
        await for (final output in process.stdout) {
          String pipe = String.fromCharCodes(output);
          List<String> pipeSections = pipe.split('~');
          print("Pipe: $pipe");

          if (pipeSections.length == 4) {
            print("Pipe Sections ${pipeSections[0]}");
            double percent = double.parse(pipeSections[0]); // 1.0
            //double estimatedTime = double.parse(pipeSections[1]); // 10 (in minutes)
            //String success = pipeSections[2]; // success/failed
            //String row = pipeSections[3]; // ['Me', '7143290331', 'Answering Machine', '1', '9494709674', '8/26/2024 5:35:00 PM', '80', '8/26/2024 5:36:37 PM', '3021657', '', '', '8/26/2024 5:35:17 PM', '28', '1008603', 'My agency', '1763.46', 'Aug 12, 2024', 'M W F 1 0 1 3 1 4']
            print("percent: $percent");
            emit(ProgressState(percent));
          }
        }

        exitCode = await process.exitCode;
        if (exitCode == 0) {
          emit(JobCompleteState());
        }
      } catch (e) {
        print('Post Job Event Error: $e');
        emit(ProjectErrorState(e));
      }
    });

    on<LoadingEvent>((event, emit) {
      try {
        emit(ProjectLoadingState());
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
